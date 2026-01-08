# Contributing to ForUMhub

Thanks for collaborating! This file explains how we want to manage partial commits and PRs for the professor timeline.

## Branching strategy
- `develop` is where features are integrated incrementally.
- `main` is the protected stable branch used for releases.

## Partial commit / timeline strategy
- Make small, focused commits with clear messages (use `feat:`, `fix:`, `chore:` prefixes)
- Group commits by feature and push each completed feature to a short-lived branch: `feat/posts-v1`, `feat/chat-v1`, etc.
- Open a PR to `develop` for review and merge when ready

## PR guidelines
- Include a short description of what changed and which rubric items the change addresses
- Add screenshots for UI changes
- Run `flutter analyze` and `flutter test` locally

## Reviewer checklist
- UI is responsive and matches the app theme
- Core functionality works for the feature (CRUD operations, navigation)
- No secrets committed
- Basic tests added for new widgets or services

## Adding collaborator notes
- Admins can add a collaborator under repository Settings → Collaborators
- After adding, assign tasks via Issues and PRs
