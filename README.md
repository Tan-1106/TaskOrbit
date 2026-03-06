<p align="center">
  <img src="assets/icons/app_icon.png" width="120" alt="Task Orbit Logo" />
</p>

<h1 align="center">Task Orbit</h1>

<p align="center">
  <strong>A productivity app built with Flutter — combining task management and the Pomodoro technique in one place.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet" alt="Architecture" />
  <img src="https://img.shields.io/badge/State-BLoC-orange" alt="State Management" />
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [System Architecture](#-system-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Database Design](#-database-design)
- [Getting Started](#-getting-started)
- [Firebase Setup](#-firebase-setup)
- [Build & Release](#-build--release)
- [Testing](#-testing)
- [Localization](#-localization)
- [License](#-license)

---

## 🌐 Overview

**Task Orbit** is a full-featured, cross-platform productivity application that helps users organize daily tasks and boost focus with a built-in Pomodoro timer. The app follows **Clean Architecture** principles with a clear separation between data, domain, and presentation layers, and uses the **BLoC pattern** for predictable, testable state management.

The app works seamlessly in both **online and offline** modes thanks to its local-first sync strategy — all data is stored locally in SQLite (via Drift) and automatically synchronized to Cloud Firestore when connectivity is restored.

### Why Task Orbit?

| Problem | Solution |
|---|---|
| Most task apps lack focus tools | Integrated Pomodoro timer with customizable presets |
| Data loss when offline | Offline-first architecture with automatic cloud sync |
| English-only interfaces | Full i18n support (English & Vietnamese) with auto device locale detection |
| Timer stops when phone screen is off | Background-resilient timer using DateTime-anchor strategy |
| Unverified accounts clutter the database | Automated Cloud Function cleanup of unverified users every 15 minutes |

---

## ✨ Key Features

### 🔐 Authentication
- Email/password sign-up & sign-in via **Firebase Auth**
- **Email verification** flow with auto-redirect on verification
- Forgot password / password reset via email
- **"Remember Me"** — persists session across cold starts
- Change password from profile settings
- Account deletion with full data cleanup
- Guest mode — browse the app without signing in
- **Automated cleanup**: Cloud Function deletes unverified accounts after 15 minutes

### 📅 Task Management (Agenda)
- Create, edit, and delete tasks with rich metadata:
  - Title, description, date, start/end time, all-day toggle
  - Custom **categories** with color coding
  - Configurable **notification reminders** (e.g. 5 min, 15 min, 1 hour before)
- **Horizontal date picker** for quick date navigation
- Filter tasks by category, completion status
- Search tasks by title/description
- Mark tasks as complete/incomplete with confirmation
- **Local notifications** scheduled at reminder time

### 🍅 Pomodoro Timer
- Classic 25/5/15 preset built-in
- **Custom presets**: configure focus duration, short break, long break, and cycle count
- Preset CRUD — create, edit, delete, sync to cloud
- Visual **ring progress indicator** with phase-colored animation
- **Cycle dots** showing completed focus rounds
- Repeat mode — auto-restart after long break
- **Background-resilient timer**:
  - Uses `DateTime` anchor instead of `Timer.periodic` decrement
  - `WidgetsBindingObserver` detects app lifecycle (pause/resume)
  - Fast-forwards through elapsed phases when resuming from background
  - Persists timer state to `SharedPreferences` — survives app kill & force stop
  - Shows **ongoing notification** with end time while backgrounded
  - Schedules **phase-end notification** for background alerts

### 👤 Profile & Settings
- User info display (name, email, verified status)
- **Task statistics dashboard**:
  - Completed / pending / missed task counts
  - Expandable lists of pending and missed tasks with quick navigation
- Change password
- **Language switcher** (English / Vietnamese)
- Sign out with confirmation
- Delete account with data purge

### 🔄 Offline-First Sync
- All data is stored locally in **SQLite** (Drift ORM) first
- On connectivity change, unsynced records are pushed to **Cloud Firestore**
- On app launch, remote data is pulled and merged with local state
- Each entity tracks `isSynced` and `isDeleted` flags for conflict resolution
- Works flawlessly in airplane mode — syncs automatically when back online

### 🌍 Internationalization (i18n)
- Full support for **English** and **Vietnamese**
- **Auto-detects** device system locale on first launch via `PlatformDispatcher`
- Manual language switch in profile settings
- All notification strings (task reminders, Pomodoro alerts) are localized
- Context-free localization in domain/bloc layers using `lookupAppLocalizations`

---

## 🏗 System Architecture

The project strictly follows **Clean Architecture** with 3 distinct layers per feature:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│         (Pages, Widgets, BLoC / Events / States)     │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│        (Entities, Use Cases, Repository Interfaces)  │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│    (Repository Implementations, Data Sources,        │
│     Local: Drift/SQLite, Remote: Cloud Firestore)    │
└─────────────────────────────────────────────────────┘
```

### Data Flow

```
UI (Widget)
  │  dispatches Event
  ▼
BLoC
  │  calls UseCase
  ▼
UseCase (Domain)
  │  calls Repository interface
  ▼
Repository Implementation (Data)
  │  delegates to DataSources
  ├──► LocalDataSource (Drift / SQLite)
  └──► RemoteDataSource (Cloud Firestore)
```

### Dependency Injection

All dependencies are registered and resolved through **GetIt** (service locator pattern), configured in `init_dependencies.dart`. This ensures:
- Loose coupling between layers
- Easy testing with mock injection
- Single source of truth for object lifetimes (`factory` vs `lazySingleton`)

### Error Handling

Functional error handling using **fpdart** (`Either<Failure, T>`):
- No exceptions leak across layer boundaries
- Use cases always return `Either<Failure, SuccessType>`
- BLoC maps `Left` (failure) and `Right` (success) to appropriate UI states

---

## 🛠 Tech Stack

### Frontend (Flutter / Dart)

| Category | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter 3.11 | Cross-platform UI |
| **Language** | Dart 3.11 | Application logic |
| **State Management** | flutter_bloc | BLoC pattern for predictable state |
| **Routing** | go_router | Declarative navigation with auth guards |
| **DI** | get_it | Service locator for dependency injection |
| **Local Database** | Drift (SQLite) | Type-safe, reactive local persistence |
| **Functional** | fpdart | `Either`, `Option` for error handling |
| **Notifications** | flutter_local_notifications | Scheduled & ongoing local notifications |
| **Connectivity** | connectivity_plus | Network state monitoring |
| **Preferences** | shared_preferences | Key-value storage for settings & timer state |
| **Fonts** | google_fonts | Material Design typography |
| **i18n** | flutter_localizations + intl | Multi-language support |
| **UUID** | uuid | Unique ID generation for entities |
| **Timezone** | timezone | Timezone-aware notification scheduling |

### Backend (Firebase)

| Service | Purpose |
|---|---|
| **Firebase Auth** | Email/password authentication with email verification |
| **Cloud Firestore** | Real-time cloud database for data sync |
| **Firebase Cloud Functions** | Scheduled cleanup of unverified user accounts |
| **Firebase Messaging** | Push notification infrastructure |
| **Firestore Security Rules** | Per-user data isolation and access control |

### Dev Tools

| Tool | Purpose |
|---|---|
| mockito | Mock generation for unit tests |
| bloc_test | BLoC-specific testing utilities |
| drift_dev + build_runner | Drift code generation |
| flutter_launcher_icons | App icon generation for all platforms |
| flutter_lints | Dart/Flutter lint rules |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, WidgetsBindingObserver
├── init_dependencies.dart             # DI registration (GetIt)
├── init_dependencies.main.dart        # DI implementation (part file)
├── firebase_options.dart              # Firebase config (auto-generated)
│
├── core/                              # Shared infrastructure
│   ├── auth/
│   │   └── app_auth_notifier.dart     # Auth state → GoRouter refresh bridge
│   ├── common/
│   │   ├── enums/
│   │   │   └── child_routes.dart      # Route enum definitions
│   │   ├── layout/
│   │   │   ├── app_shell_layout.dart  # Bottom nav + app bar shell
│   │   │   └── shell_actions_notifier.dart
│   │   ├── locale/
│   │   │   └── locale_notifier.dart   # Locale persistence + device detection
│   │   └── widgets/
│   │       └── custom_app_bar.dart    # Reusable app bar
│   ├── config/
│   │   ├── routes/
│   │   │   └── app_router.dart        # GoRouter config with auth guards
│   │   └── theme/
│   │       └── theme.dart             # Material 3 theme (light/dark)
│   ├── database/
│   │   ├── app_database.dart          # Drift database schema
│   │   └── app_database.g.dart        # Generated Drift code
│   ├── error/
│   │   ├── exceptions.dart            # Custom exception types
│   │   └── failure.dart               # Failure class for Either<Failure, T>
│   ├── network/
│   │   └── connectivity_service.dart  # Reactive connectivity monitoring
│   ├── services/
│   │   └── notification_service.dart  # Local notification scheduling
│   ├── usecases/
│   │   └── usecase.dart               # Abstract UseCase interface
│   └── utils/
│       └── create_theme.dart          # Theme factory utility
│
├── features/                          # Feature modules (Clean Architecture)
│   │
│   ├── authentication/                # 🔐 Auth feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repository/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── user_sign_up.dart
│   │   │       ├── user_login.dart
│   │   │       ├── forgot_password.dart
│   │   │       ├── change_password.dart
│   │   │       ├── get_current_user.dart
│   │   │       ├── send_email_verification.dart
│   │   │       ├── check_email_verified.dart
│   │   │       └── delete_current_user.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── sign_in_page.dart
│   │       │   ├── sign_up_page.dart
│   │       │   ├── forgot_password_page.dart
│   │       │   └── email_verification_page.dart
│   │       └── widgets/
│   │           └── sign_in_background.dart
│   │
│   ├── agenda/                        # 📅 Task management feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── task_local_data_source.dart
│   │   │   │   ├── task_remote_data_source.dart
│   │   │   │   ├── category_local_data_source.dart
│   │   │   │   └── category_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       ├── task_repository_impl.dart
│   │   │       └── category_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── task.dart
│   │   │   │   └── category.dart
│   │   │   ├── repository/
│   │   │   │   ├── task_repository.dart
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_task.dart
│   │   │       ├── update_task.dart
│   │   │       ├── delete_task.dart
│   │   │       ├── get_tasks_by_date.dart
│   │   │       ├── get_tasks_for_period.dart
│   │   │       ├── toggle_task_complete.dart
│   │   │       ├── search_tasks.dart
│   │   │       ├── sync_tasks.dart
│   │   │       ├── get_categories.dart
│   │   │       ├── create_category.dart
│   │   │       └── delete_category.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── agenda_bloc.dart
│   │       │   ├── agenda_event.dart
│   │       │   └── agenda_state.dart
│   │       ├── pages/
│   │       │   ├── agenda_page.dart
│   │       │   └── task_detail_page.dart
│   │       └── widgets/
│   │           ├── add_edit_task_sheet.dart
│   │           ├── category_management_sheet.dart
│   │           ├── filter_dialog.dart
│   │           ├── horizontal_date_picker.dart
│   │           └── task_card.dart
│   │
│   ├── pomodoro/                      # 🍅 Pomodoro timer feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── pomodoro_preset_local_data_source.dart
│   │   │   │   └── pomodoro_preset_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── pomodoro_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── pomodoro_preset.dart
│   │   │   │   └── pomodoro_phase.dart
│   │   │   ├── repository/
│   │   │   │   └── i_pomodoro_preset_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_presets.dart
│   │   │       ├── save_preset.dart
│   │   │       ├── delete_preset.dart
│   │   │       └── sync_presets.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── pomodoro_bloc.dart
│   │       │   ├── pomodoro_event.dart
│   │       │   └── pomodoro_state.dart
│   │       ├── pages/
│   │       │   └── pomodoro_page.dart
│   │       └── widgets/
│   │           ├── pomodoro_timer_widget.dart
│   │           ├── pomodoro_preset_dropdown.dart
│   │           └── preset_form_sheet.dart
│   │
│   └── profile/                       # 👤 Profile & settings feature
│       └── presentation/
│           ├── bloc/
│           │   └── profile_bloc.dart
│           ├── pages/
│           │   └── profile_page.dart
│           └── widgets/
│               ├── user_info_card.dart
│               ├── stats_card.dart
│               ├── settings_card.dart
│               ├── language_switcher_card.dart
│               └── sign_out_button.dart
│
├── l10n/                              # 🌍 Localization
│   ├── app_en.arb                     # English strings
│   ├── app_vi.arb                     # Vietnamese strings
│   ├── app_localizations.dart         # Generated base class
│   ├── app_localizations_en.dart      # Generated EN
│   └── app_localizations_vi.dart      # Generated VI
│
functions/                             # ☁️ Firebase Cloud Functions
│   ├── index.js                       # Scheduled cleanup of unverified users
│   └── package.json
│
firestore.rules                        # 🔒 Firestore security rules
```

---

## 🗄 Database Design

### Local Database (SQLite via Drift)

#### Tasks Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT (PK) | UUID |
| `userId` | TEXT | Owner's Firebase UID |
| `title` | TEXT | Task title (1–200 chars) |
| `description` | TEXT? | Optional description |
| `date` | DATETIME | Task date |
| `startTime` | DATETIME? | Optional start time |
| `endTime` | DATETIME? | Optional end time |
| `isAllDay` | BOOLEAN | All-day flag |
| `categoryId` | TEXT? | FK to categories |
| `isCompleted` | BOOLEAN | Completion status |
| `createdAt` | DATETIME | Creation timestamp |
| `updatedAt` | DATETIME | Last update timestamp |
| `isSynced` | BOOLEAN | Cloud sync status |
| `isDeleted` | BOOLEAN | Soft delete flag |
| `notificationMinutesBefore` | INTEGER? | Reminder offset in minutes |

#### Categories Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT (PK) | UUID |
| `userId` | TEXT | Owner's Firebase UID |
| `name` | TEXT | Category name (1–100 chars) |
| `colorValue` | INTEGER | Color as int value |
| `isSynced` | BOOLEAN | Cloud sync status |
| `isDeleted` | BOOLEAN | Soft delete flag |

#### Pomodoro Presets Table
| Column | Type | Description |
|---|---|---|
| `id` | TEXT (PK) | UUID |
| `userId` | TEXT | Owner's Firebase UID |
| `name` | TEXT | Preset name |
| `description` | TEXT? | Optional description |
| `focusMinutes` | INTEGER | Focus duration |
| `shortBreakMinutes` | INTEGER | Short break duration |
| `longBreakMinutes` | INTEGER | Long break duration |
| `cyclesBeforeLongBreak` | INTEGER | Cycles before long break |
| `isSynced` | BOOLEAN | Cloud sync status |
| `isDeleted` | BOOLEAN | Soft delete flag |

### Cloud Database (Firestore)

```
users/{userId}/
├── tasks/{taskId}               # Mirror of local tasks
├── categories/{categoryId}      # Mirror of local categories
└── pomodoro_presets/{presetId}   # Mirror of local presets

pending_verifications/{userId}   # Temporary doc for email verification tracking
```

### Firestore Security Rules

All data is **per-user isolated** — users can only read/write their own subcollections:

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  match /tasks/{taskId} { /* same rule */ }
  match /categories/{categoryId} { /* same rule */ }
  match /pomodoro_presets/{presetId} { /* same rule */ }
}
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.11.0`
- Dart `>=3.11.0`
- Android Studio / VS Code with Flutter extensions
- Firebase CLI (`firebase-tools`)
- Node.js 20+ (for Cloud Functions)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/TaskOrbit.git
cd TaskOrbit

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# 4. Generate localization files
flutter gen-l10n

# 5. Run the app
flutter run
```

---

## 🔥 Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Enable **Authentication** → Email/Password provider

3. Enable **Cloud Firestore** database

4. Configure Firebase for Flutter:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Deploy Firestore Security Rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

6. Deploy Cloud Functions:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

---

## 📦 Build & Release

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs per ABI (smaller file size)
flutter build apk --split-per-abi --release
```

### App Icon

```bash
dart run flutter_launcher_icons
```

---

## 🧪 Testing

The project includes test infrastructure with **mockito** for mocking and **bloc_test** for BLoC testing.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 🌍 Localization

| Language | Code | Status |
|---|---|---|
| English | `en` | ✅ Complete |
| Vietnamese | `vi` | ✅ Complete |

### How it works

1. **First launch**: App auto-detects device locale via `PlatformDispatcher.instance.locale`
2. **Manual switch**: User can change language in Profile → Settings
3. **Persistence**: Selected language is saved to `SharedPreferences`
4. **Notifications**: All notification strings (task reminders, Pomodoro alerts) are localized using context-free `lookupAppLocalizations()` — no `BuildContext` required

### Adding a new language

1. Create `lib/l10n/app_<code>.arb` (copy from `app_en.arb`)
2. Translate all string values
3. Add `Locale('<code>')` to `supportedLocales` in `main.dart`
4. Add the code to `_supportedCodes` in `locale_notifier.dart`
5. Run `flutter gen-l10n`

---

## 📄 License

This project is for educational and portfolio purposes.

---

<p align="center">
  Built with ❤️ using Flutter
</p>
