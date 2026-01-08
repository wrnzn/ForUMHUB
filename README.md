# ForUMhub (UM Forum & Marketplace) ✅

ForUMhub is a mobile forum and marketplace built with Flutter for University of Mindanao students. The app allows students to post announcements/questions, sell and buy items, chat with one another, and receive notifications. It focuses on a simple, responsive Android experience.

## Team
- Joseph Alejo — Developer
- Christopher Insik — Developer

## What the app does 🔎
- Post creation, edit, and deletion (text + images)
- Commenting, upvoting, and bookmarking posts
- Marketplace: list products, view details, and contact sellers
- Real-time chat between users (one-to-one conversations)
- User authentication (Firebase Auth)
- Notifications for messages, replies, and interactions
- Profile management and basic search

## Tech stack & architecture 🔧
- Flutter (Dart) — UI and mobile logic
- Firebase — Authentication, Cloud Firestore (data), Firebase Storage (media)
- Clean-ish services layer: `AuthService`, `PostService`, `ChatService`, `MessageService`, `NotificationService`, `UserService`
- Platform focus: **Android** (project contains other platform folders but Android is primary target)

## Android-focused setup (how to build and run) 📱
1. Ensure Flutter SDK is installed (stable channel) and Android toolchain is configured.
2. Clone the repository:
   ```bash
   git clone https://github.com/wrnzn/ForUMHUB.git
   cd ForUMHUB
   ```
3. Add Android Firebase config (if using Firebase features locally):
   - Place `google-services.json` in `android/app/` or configure `flutterfire` CLI to generate `firebase_options.dart`.
4. Get dependencies and build a release APK:
   ```bash
   flutter pub get
   flutter build apk --release
   ```
5. Install the APK onto a device or emulator:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

Notes:
- The repository currently contains a release `v0.1.0` with a prebuilt APK attached.
- Do not commit `google-services.json`, `firebase_options.dart`, keystore files, or any secrets. They are ignored in `.gitignore`.

## Usage & testing 🧪
- Run `flutter run` for development.
- Run `flutter test` to run unit/widget tests.
- The app was tested on Android (API level 30+) and supports release builds.

## Files & important paths 📁
- `lib/` — Flutter source code
- `lib/pages/` — Screens (home, chat, market, profile, etc.)
- `lib/services/` — Firebase service layer
- `android/` — Android project and Gradle config
- `build/app/outputs/flutter-apk/` — generated APK path after `flutter build apk`

## Contribution & branching model 🌱
- Use `develop` for active work and open PRs against it. Protect `main` for releases.
- Commit messages follow the `chore/feat/fix/release` style used in this repo.

## Release & APK
- Release `v0.1.0` contains an attached release APK (uploaded). For future releases, tag with semantic versioning and attach produced artifacts.

## Contact
- Joseph Alejo
- Christopher Insik

---

For full docs, architecture details, and the rubric mapping see `docs/Project_Documentation.md` and `docs/Commit_Plan.md`.