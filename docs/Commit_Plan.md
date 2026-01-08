# Partial Commit Plan (Professor Timeline)

This file describes an ordered sequence of small commits and branch flows you can make to demonstrate iterative progress.

Guidelines:
- Use small commits with clear messages (conventional commits: `feat:`, `fix:`, `chore:`)
- Create feature branches off `develop`, open PRs to `develop`, then merge

Example sequence (files listed are suggestions — adapt to your current working files):

1) init: project scaffold + theme
   - Files: `lib/main.dart`, `pubspec.yaml`, `lib/widgets/*` (skeleton), `lib/pages/*` (skeleton)
   - Commit message: `init: scaffold app, main theme, base routes`
   - Commands:
     - git checkout -b feat/init
     - git add lib/main.dart pubspec.yaml lib/widgets lib/pages
     - git commit -m "init: scaffold app, main theme, base routes"
     - git push -u origin feat/init

2) feat: auth + user model
   - Files: `lib/services/auth_service.dart`, `lib/pages/login_page.dart`, `lib/pages/create_account_page.dart`, `lib/models/user_model.dart`
   - Commit message: `feat(auth): add email/password auth and user model`

3) feat: posts + post_service
   - Files: `lib/services/post_service.dart`, `lib/models/post_model.dart`, `lib/pages/home_page.dart`, `lib/widgets/post_card.dart`
   - Commit message: `feat(posts): add PostService and feed UI`

4) feat: comments & interactions
   - Files: `lib/services/post_service.dart` (edited), `lib/widgets/post_detail/*`, `lib/widgets/post_detail/comment_input_box.dart`
   - Commit message: `feat(comments): add comments, upvotes, bookmarking`

5) feat: marketplace
   - Files: `lib/services/market_service.dart`, `lib/pages/market_page.dart`, `lib/models/product_model.dart` and product widgets
   - Commit message: `feat(market): add marketplace pages and models`

6) feat: chat + messaging
   - Files: `lib/services/chat_service.dart`, `lib/services/message_service.dart`, `lib/pages/chat_page.dart`, `lib/pages/conversation_page.dart`
   - Commit message: `feat(chat): add messaging services and UI`

7) feat: notifications & presence
   - Files: `lib/services/notification_service.dart`, `lib/widgets/notification/*`
   - Commit message: `feat(notifications): add notification model and flows`

8) chore: docs + security + ci
   - Files: `README.md`, `docs/*`, `.github/workflows/ci.yml`, `.gitignore`
   - Commit message: `chore(docs/ci/security): add docs, CI workflow, hide secrets`

9) release: v0.1.0
   - Tag the release: `git tag -a v0.1.0 -m "Release v0.1.0"` and `git push origin v0.1.0`

Notes:
- Keep each commit self-contained so you can demonstrate incremental progress.
- For each feature branch, include at least one test or simple manual test steps in the PR description.
- If you want, I can prepare the commits locally and show you the exact `git` commands to run (I will not push to GitHub unless you allow me to).