const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');
const nodemailer = require('nodemailer');

// ─── Firebase Secrets ──────────────────────────────────────────────────────────
// Run these commands once to set your secrets:
//   firebase functions:secrets:set GMAIL_USER
//   firebase functions:secrets:set GMAIL_PASS
// Or use any SMTP provider (SendGrid, Mailgun, etc.)
const GMAIL_USER = defineSecret('GMAIL_USER');
const GMAIL_PASS = defineSecret('GMAIL_PASS');

initializeApp();

// ─── Email Templates ───────────────────────────────────────────────────────────

/**
 * HTML template for Email Verification
 * @param {string} verificationLink
 * @param {string} userName
 * @returns {string} HTML string
 */
function buildVerificationEmailHtml(verificationLink, userName = '') {
  const greeting = userName ? `Xin chào <strong>${userName}</strong>,` : 'Xin chào,';
  return `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xác thực Email - TaskOrbit</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f2f5;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f2f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08);max-width:600px;">
          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#6750A4 0%,#9C72D8 100%);padding:40px 48px;text-align:center;">
              <div style="font-size:48px;margin-bottom:8px;">🚀</div>
              <h1 style="color:#ffffff;margin:0;font-size:28px;font-weight:700;letter-spacing:-0.5px;">TaskOrbit</h1>
              <p style="color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px;">Quản lý công việc thông minh</p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:48px;">
              <h2 style="color:#1a1a2e;margin:0 0 16px;font-size:22px;font-weight:600;">✉️ Xác thực địa chỉ email</h2>
              <p style="color:#555;margin:0 0 12px;font-size:15px;line-height:1.7;">${greeting}</p>
              <p style="color:#555;margin:0 0 24px;font-size:15px;line-height:1.7;">
                Cảm ơn bạn đã đăng ký tài khoản <strong>TaskOrbit</strong>! Để hoàn tất quá trình đăng ký, vui lòng xác thực địa chỉ email của bạn bằng cách nhấn vào nút bên dưới.
              </p>
              <!-- CTA Button -->
              <table cellpadding="0" cellspacing="0" style="margin:32px 0;">
                <tr>
                  <td style="background:linear-gradient(135deg,#6750A4 0%,#9C72D8 100%);border-radius:10px;text-align:center;">
                    <a href="${verificationLink}" style="display:inline-block;padding:16px 40px;color:#ffffff;font-size:16px;font-weight:600;text-decoration:none;letter-spacing:0.3px;">
                      ✅ Xác thực Email ngay
                    </a>
                  </td>
                </tr>
              </table>
              <!-- Warning box -->
              <div style="background:#fff8e1;border-left:4px solid #f59e0b;border-radius:6px;padding:16px 20px;margin-bottom:24px;">
                <p style="margin:0;font-size:13px;color:#78550a;line-height:1.6;">
                  ⏰ <strong>Lưu ý:</strong> Link xác thực có hiệu lực trong <strong>24 giờ</strong>. Nếu không xác thực trong 15 phút, tài khoản sẽ bị xóa tự động.
                </p>
              </div>
              <p style="color:#888;font-size:13px;line-height:1.6;margin:0;">
                Nếu bạn không thực hiện đăng ký này, vui lòng bỏ qua email này. Tài khoản sẽ tự động bị xóa sau 15 phút.
              </p>
              <!-- Fallback link -->
              <hr style="border:none;border-top:1px solid #f0f0f0;margin:24px 0;">
              <p style="color:#aaa;font-size:12px;margin:0;line-height:1.8;">
                Nếu nút không hoạt động, copy và dán link sau vào trình duyệt:<br>
                <a href="${verificationLink}" style="color:#6750A4;word-break:break-all;font-size:11px;">${verificationLink}</a>
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#f8f7ff;padding:24px 48px;text-align:center;border-top:1px solid #eeebff;">
              <p style="color:#999;font-size:12px;margin:0 0 4px;">© 2026 TaskOrbit. All rights reserved.</p>
              <p style="color:#bbb;font-size:11px;margin:0;">
                Bạn nhận được email này vì đã đăng ký tài khoản tại TaskOrbit.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

/**
 * HTML template for Password Reset
 * @param {string} resetLink
 * @returns {string} HTML string
 */
function buildPasswordResetEmailHtml(resetLink) {
  return `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đặt lại mật khẩu - TaskOrbit</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f2f5;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f2f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08);max-width:600px;">
          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#1e3a5f 0%,#2d6a9f 100%);padding:40px 48px;text-align:center;">
              <div style="font-size:48px;margin-bottom:8px;">🔐</div>
              <h1 style="color:#ffffff;margin:0;font-size:28px;font-weight:700;letter-spacing:-0.5px;">TaskOrbit</h1>
              <p style="color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px;">Quản lý công việc thông minh</p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:48px;">
              <h2 style="color:#1a1a2e;margin:0 0 16px;font-size:22px;font-weight:600;">🔑 Đặt lại mật khẩu</h2>
              <p style="color:#555;margin:0 0 12px;font-size:15px;line-height:1.7;">Xin chào,</p>
              <p style="color:#555;margin:0 0 24px;font-size:15px;line-height:1.7;">
                Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản <strong>TaskOrbit</strong> liên kết với email này. Nhấn nút bên dưới để tạo mật khẩu mới.
              </p>
              <!-- CTA Button -->
              <table cellpadding="0" cellspacing="0" style="margin:32px 0;">
                <tr>
                  <td style="background:linear-gradient(135deg,#1e3a5f 0%,#2d6a9f 100%);border-radius:10px;text-align:center;">
                    <a href="${resetLink}" style="display:inline-block;padding:16px 40px;color:#ffffff;font-size:16px;font-weight:600;text-decoration:none;letter-spacing:0.3px;">
                      🔑 Đặt lại mật khẩu
                    </a>
                  </td>
                </tr>
              </table>
              <!-- Warning box -->
              <div style="background:#fef2f2;border-left:4px solid #ef4444;border-radius:6px;padding:16px 20px;margin-bottom:24px;">
                <p style="margin:0;font-size:13px;color:#7f1d1d;line-height:1.6;">
                  🚨 <strong>Quan trọng:</strong> Nếu bạn <strong>không</strong> yêu cầu đặt lại mật khẩu, hãy bỏ qua email này. Mật khẩu của bạn vẫn an toàn và sẽ không bị thay đổi.
                </p>
              </div>
              <p style="color:#888;font-size:13px;line-height:1.6;margin:0;">
                ⏰ Link đặt lại mật khẩu có hiệu lực trong <strong>1 giờ</strong>.
              </p>
              <!-- Fallback link -->
              <hr style="border:none;border-top:1px solid #f0f0f0;margin:24px 0;">
              <p style="color:#aaa;font-size:12px;margin:0;line-height:1.8;">
                Nếu nút không hoạt động, copy và dán link sau vào trình duyệt:<br>
                <a href="${resetLink}" style="color:#2d6a9f;word-break:break-all;font-size:11px;">${resetLink}</a>
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#f7f9fc;padding:24px 48px;text-align:center;border-top:1px solid #e8eef5;">
              <p style="color:#999;font-size:12px;margin:0 0 4px;">© 2026 TaskOrbit. All rights reserved.</p>
              <p style="color:#bbb;font-size:11px;margin:0;">
                Bạn nhận được email này vì có người yêu cầu đặt lại mật khẩu cho tài khoản này.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

// ─── Cloud Function: Send Verification Email ───────────────────────────────────

/**
 * Callable Cloud Function: sendVerificationEmail
 *
 * Called from Flutter after user registers.
 * Generates a Firebase email verification link and sends a custom HTML email.
 *
 * Flutter usage:
 *   final callable = FirebaseFunctions.instance.httpsCallable('sendVerificationEmail');
 *   await callable.call({'userName': 'John'});
 */
exports.sendVerificationEmail = onCall(
  { secrets: [GMAIL_USER, GMAIL_PASS] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated.');
    }

    const uid = request.auth.uid;
    const email = request.auth.token.email;
    const userName = request.data?.userName || '';

    if (!email) {
      throw new HttpsError('invalid-argument', 'User email not found.');
    }

    try {
      const auth = getAuth();

      // Generate Firebase email verification link
      const verificationLink = await auth.generateEmailVerificationLink(email);

      // Configure transporter (Gmail example)
      // To use SendGrid: replace with sendgrid transport
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: GMAIL_USER.value(),
          pass: GMAIL_PASS.value(),
        },
      });

      await transporter.sendMail({
        from: `"TaskOrbit" <${GMAIL_USER.value()}>`,
        to: email,
        subject: '✅ [TaskOrbit] Xác thực địa chỉ email của bạn',
        html: buildVerificationEmailHtml(verificationLink, userName),
      });

      console.log(`Verification email sent to ${email} (uid: ${uid})`);
      return { success: true, message: 'Verification email sent.' };
    } catch (error) {
      console.error('Error sending verification email:', error);
      throw new HttpsError('internal', `Failed to send verification email: ${error.message}`);
    }
  }
);

// ─── Cloud Function: Send Password Reset Email ─────────────────────────────────

/**
 * Callable Cloud Function: sendPasswordResetEmail
 *
 * Called from Flutter when user requests password reset.
 * Generates a Firebase password reset link and sends a custom HTML email.
 *
 * Flutter usage:
 *   final callable = FirebaseFunctions.instance.httpsCallable('sendPasswordResetEmail');
 *   await callable.call({'email': 'user@example.com'});
 */
exports.sendPasswordResetEmailCustom = onCall(
  { secrets: [GMAIL_USER, GMAIL_PASS] },
  async (request) => {
    const email = request.data?.email;

    if (!email) {
      throw new HttpsError('invalid-argument', 'Email is required.');
    }

    try {
      const auth = getAuth();

      // Generate Firebase password reset link
      const resetLink = await auth.generatePasswordResetLink(email);

      // Configure transporter
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: GMAIL_USER.value(),
          pass: GMAIL_PASS.value(),
        },
      });

      await transporter.sendMail({
        from: `"TaskOrbit" <${GMAIL_USER.value()}>`,
        to: email,
        subject: '🔑 [TaskOrbit] Yêu cầu đặt lại mật khẩu',
        html: buildPasswordResetEmailHtml(resetLink),
      });

      console.log(`Password reset email sent to ${email}`);
      return { success: true, message: 'Password reset email sent.' };
    } catch (error) {
      // Do NOT reveal if email exists for security reasons
      console.error('Error sending password reset email:', error);
      // Still return success to prevent email enumeration
      return { success: true, message: 'If this email exists, a reset link has been sent.' };
    }
  }
);

// ─── Scheduled Function: Delete Unverified Users ──────────────────────────────

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

