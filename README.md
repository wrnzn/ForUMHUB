# ForUMhub

**Short description:** ForUMhub is a forum + marketplace mobile app for UM students in Tagum — users can post questions, announcements, sell/buy items or services, comment, upvote, bookmark, chat, and receive notifications.

## Team
- Team name: (replace)
- Members: (replace with names and roles)

## Key features
- Multi-screen Flutter app (Home feed, Post detail, Create/Edit post, Market pages, Chat, Notifications, Profile)
- Firebase backend: Authentication, Firestore for posts/chat/notifications, Storage for uploaded images
- Transactional functions: create/edit/delete posts & comments, upvote, bookmark, messaging
- Offline-friendly UI and responsive design using Material 3 and custom theme

## Tech stack
- Flutter (Dart)
- Firebase: Authentication, Cloud Firestore, Cloud Storage, (optionally FCM)
- State management: (project-specific - e.g., setState/Provider)

## Local setup
1. Clone repository
2. Install Flutter SDK and set up environment (Windows instructions)
3. Add platform Firebase config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
   - Or use `flutterfire` CLI to generate `firebase_options.dart` per platform
4. Run `flutter pub get`, then `flutter run`

> Security note: **Do not** commit API keys or secrets to the repository. `lib/main.dart` was updated to avoid hard-coded `FirebaseOptions`.

## APK / Release
- Use `flutter build apk --release` to build a release APK
- Prepare release notes and tag using semantic versioning (e.g., `v0.1.0`)

## Partial commit plan (example sequence for professor timeline)
1. `init: project scaffold + basic routes` — commit initial screens and theme
2. `feat: auth + user model` — add registration/login flows and `AuthService`
3. `feat: posts + post_service` — implement post CRUD and feed
4. `feat: comments + upvotes + bookmarks` — comment system and interactions
5. `feat: marketplace` — product models and market pages
6. `feat: chat + messaging` — chat pages and message service
7. `feat: notifications + presence` — notification system
8. `chore: docs + ci + security` — add docs, CI, remove secrets
9. `release: v0.1.0` — publish APK and PDF doc

## Contribution
- Please open issues and PRs; use the `develop` branch for active work and `main` for releases.

## Professor submission checklist
- APK file (debug or release)
- GitHub repo link with commit history demonstrating progress
- Short Documentation PDF (title, team, description, screenshots, db structure, tech stack)
- App logo (custom branding)

---

For detailed documentation and the rubric mapping, see `docs/Project_Documentation.md`.
