# Release & Collaborator Setup

This document lists step-by-step commands and GUI steps to create a GitHub repository, add collaborators, set branch protection, and create a release with APK.

## Create a GitHub repository and push local repo
1. Create a new repo on GitHub (via web UI) named e.g. `ForUMhub`.
2. From your local project root:

```bash
git remote add origin git@github.com:<your-org-or-user>/ForUMhub.git
git push -u origin develop
git push -u origin main
```

If you haven't committed yet, stage the planned partial commits and push them in sequence (see `docs/Commit_Plan.md`).

## Add a collaborator
1. On GitHub, open the repo → Settings → Collaborators and teams
2. Click "Add people" and enter their GitHub username/email
3. The collaborator will receive an invite they must accept

## Branch protection (recommended for `main`)
- Settings → Branches → Add rule for `main`:
  - Require pull request reviews before merging
  - Require status checks to pass (enable `analyze_and_test` from Actions)
  - Include administrators (optional)

## Create a release with APK
1. Tag the release locally:
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0"
   git push origin v0.1.0
   ```
2. Create a GitHub Release (Web UI) and upload the built APK (`build/app/outputs/flutter-apk/app-release.apk`) as an asset.

## Add collaborators automatically (optional)
If you want to automate adding collaborators, you can use the GitHub CLI (gh):

```bash
# invite a user as a collaborator
gh repo add-collaborator <owner>/<repo> --user <username> --permission write
```

## Notes
- Do not add service account keys or secrets to the repo
- Configure branch protection after initial pushes to ensure CI checks are enforced
- If you want, I can prepare the release draft and the APK artifact locally, and optionally push and create the GitHub release if you provide push access or a token (I will not push without your approval).