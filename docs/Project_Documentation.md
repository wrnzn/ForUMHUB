# ForUMhub — Project Documentation

## 1. App Title
ForUMhub — Forum + Marketplace for UM students (Tagum campus)

## 2. Team Members
- Member 1 — Role (e.g., Frontend / Flutter)
- Member 2 — Role (e.g., Backend / Firebase)

## 3. Project Overview
ForUMhub is a mobile-first application where UM students can:
- Post academic/general discussion threads
- Post marketplace listings (items/services)
- Comment, upvote, bookmark posts
- Chat privately with other users
- Receive notifications for replies, upvotes, bookmarks, messages

The app is implemented in Flutter with Firebase as the backend (Auth, Firestore, Storage).

## 4. Feature List (Functional)
- User authentication (email/password)
- Create / Read / Update / Delete posts
- Comment threads with nested replies
- Upvote posts and comments
- Bookmark posts (saved list)
- Marketplace: create/edit/delete product listings
- Chat & messaging (one-to-one)
- Notifications stored in Firestore and displayed in-app
- Profile editing, password reset

## 5. Non-functional / Quality
- Responsive UI using Material 3
- Basic error handling and user feedback (snackbars, loading states)
- Realtime updates using Firestore snapshots

## 6. Database structure (Firestore collections)
- users: { name, email, course, photoUrl, bookmarked_posts: [] }
- posts: { title, description, authorId, upvotes, upvotedBy: [], bookmarkedBy: [], commentCount, timestamp }
- comments: { postId, parentId, text, authorId, upvotes, upvotedBy: [], timestamp }
- products: { title, description, price, sellerId, images, timestamp }
- chats: { participants: [], lastMessage, time, unreadCount }
- chats/{chatId}/messages: { senderId, text, imageUrl, timestamp }
- notifications: { targetUserId, title, subtitle, isNew, senderId, postId, timeAgo }

## 7. Screen Map / Routes
- Login / Create Account / Forgot Password
- Home feed / main feed page (posts & categories)
- Post detail screen + comments
- Create / Edit Post (modal or page)
- Market page / Product detail / Create Product
- Profile / Edit Profile
- Chat list / Chat conversation
- Notifications page

## 8. Security & Secrets
- **Do not** commit API keys or service account files.
- Use platform config files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) or use `firebase_options.dart` generated locally (add to `.gitignore` if it contains secrets).
- Android `google-services.json` is present for local debug; ensure it is not shared publicly if you do not want the project-wide keys exposed.
### Recommended actions if secrets are already committed
1. Remove the files from the index so future commits don't include them (example):

   ```bash
   git rm --cached android/app/google-services.json
   git rm --cached ios/Runner/GoogleService-Info.plist # if present
   git commit -m "chore: remove firebase platform config files from repo"
   git push
   ```

2. To fully purge secrets from history, use a history-rewriting tool like `git filter-repo` or the `BFG Repo-Cleaner` (note: rewriting history will require collaborators to re-clone or rebase). Example with BFG:

   - Install BFG, then run:
     ```bash
     bfg --delete-files google-services.json
     git reflog expire --expire=now --all && git gc --prune=now --aggressive
     git push --force
     ```

3. **Rotate the API keys** in the Firebase Console after removal and set new ones if you suspect exposure.

If you'd like, I can prepare the exact commands and steps for your repo and show how to perform the clean-up safely (I will not `push --force` without your explicit permission).## 9. Testing
- Add widget tests for critical UI components (login flow, create post dialog, post card)
- Add integration tests for messaging + post creation flows (optional but recommended)

## 10. CI / Build
- Add a GitHub Actions workflow that runs `flutter analyze` and `flutter test`; optionally run `flutter build apk` on release tags.

## 11. Partial Commit Plan (detailed)
- Commit 1 (init): project scaffold, theme, basic routes, skeleton pages
- Commit 2 (auth): `AuthService`, login/create account pages, password reset
- Commit 3 (posts): `PostService`, post model, home feed, create post dialog
- Commit 4 (comments & interactions): comments collection, toggles for upvote/bookmark, notifications triggers
- Commit 5 (marketplace): product models/services, product pages
- Commit 6 (chat): chat & message services, chat UI
- Commit 7 (notifications & presence): notification service, presence service
- Commit 8 (polish): UX improvements, accessibility, icons/logo, images
- Commit 9 (docs & release): `README`, `docs/Project_Documentation.md`, CI workflow, release prep

Each commit should contain a short, focused set of files and a clear message (use the examples above). Push each commit to `develop` branch and make a PR to `main` when ready to release.

## 12. How to add a GitHub collaborator & protect branches
1. Create a new repository on GitHub and push local repo as remote (`git remote add origin ...` and `git push -u origin develop`)
2. On GitHub: Settings → Collaborators → Add collaborator by username/email
3. Settings → Branches → Add branch protection for `main`: require PR reviews, require CI to pass, prevent force pushes

## 13. Release steps for APK submission
1. Update version in `pubspec.yaml` (e.g., `version: 0.1.0+1`)
2. Build APK: `flutter build apk --release`
3. Upload APK to GitHub Release as asset and attach the required PDF documentation
4. Submit APK + repo link + PDF to course submission

## 14. Rubric mapping
- App Design (UI/UX): Modern Material 3 theme, responsive layouts — file `lib/main.dart`, custom widgets in `lib/widgets` ✅
- Functionality & Features: Posts, Comments, Market, Chat — services in `lib/services` (post_service, market_service, message_service) ✅
- Database Integration: Firestore used for all core features — `lib/services/*` ✅
- Code Quality: Folder structure exists under `lib/models`, `lib/pages`, `lib/services`, `lib/widgets` (add comments and more tests to improve) ⚠️ suggest adding tests
- Presentation & Docs: Create this `docs/Project_Documentation.md` and a PDF export for submission ✅

## 15. Next steps (recommended immediate actions)
- Remove any remaining hard-coded secrets and add `.env` guidance
- Add `CONTRIBUTING.md`, `CHANGELOG.md`, and basic GitHub Actions CI
- Create the partial commit plan and make the small staged commits
- Prepare screenshots and export `docs/Project_Documentation.md` to PDF for submission

---

If you want, I can create the `docs` file as a PDF, add CI workflow files, and implement the first partial commit series locally (creating branches and commits). I will not push to GitHub or add collaborators without your authorization (I can provide step-by-step commands or push if you provide a token/permission).