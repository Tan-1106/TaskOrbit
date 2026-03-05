const { onSchedule } = require('firebase-functions/v2/scheduler');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp();

/**
 * Scheduled Cloud Function: runs every 15 minutes.
 * Deletes all Firebase Auth users that:
 *   - Have NOT verified their email
 *   - Have a `pending_verifications/{uid}` document in Firestore
 *   - Were created more than 15 minutes ago
 */
exports.deleteUnverifiedUsers = onSchedule('every 15 minutes', async (_event) => {
  const auth = getAuth();
  const db = getFirestore();

  const EXPIRY_MS = 15 * 60 * 1000; // 15 minutes in milliseconds
  const now = Date.now();

  const snapshot = await db.collection('pending_verifications').get();

  if (snapshot.empty) {
    console.log('No pending verifications found.');
    return;
  }

  const deletePromises = [];

  for (const doc of snapshot.docs) {
    const uid = doc.id;
    const data = doc.data();

    // createdAt is a Firestore Timestamp
    const createdAt = data.createdAt ? data.createdAt.toMillis() : null;

    if (!createdAt) {
      console.warn(`User ${uid} has no createdAt, skipping.`);
      continue;
    }

    const ageMs = now - createdAt;

    if (ageMs < EXPIRY_MS) {
      console.log(`User ${uid} is only ${Math.round(ageMs / 1000)}s old, skipping.`);
      continue;
    }

    // Double-check: only delete if still unverified in Firebase Auth
    deletePromises.push(
      auth.getUser(uid)
        .then(async (userRecord) => {
          if (userRecord.emailVerified) {
            console.log(`User ${uid} is already verified, removing pending doc only.`);
            await doc.ref.delete();
            return;
          }

          console.log(`Deleting unverified user ${uid} (age: ${Math.round(ageMs / 1000)}s, email: ${data.email})`);
          await auth.deleteUser(uid);
          await doc.ref.delete();
          console.log(`Deleted user ${uid} and pending_verifications doc.`);
        })
        .catch(async (err) => {
          if (err.code === 'auth/user-not-found') {
            // Auth user already gone, just clean up Firestore doc
            console.log(`Auth user ${uid} not found, cleaning up pending doc.`);
            await doc.ref.delete();
          } else {
            console.error(`Error processing user ${uid}:`, err);
          }
        })
    );
  }

  await Promise.all(deletePromises);
  console.log(`Processed ${deletePromises.length} pending verification(s).`);
});

