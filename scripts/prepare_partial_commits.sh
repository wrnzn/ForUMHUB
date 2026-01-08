#!/usr/bin/env bash
set -e

# Usage: ./scripts/prepare_partial_commits.sh
# This will create three commits on a new branch `chore/docs-ci`.
# REVIEW the script before running; it will run `git add` and `git commit`.

BRANCH="chore/docs-ci"

git checkout -b "$BRANCH"

# Commit 1: docs + changelog + contributing
git add README.md docs/Project_Documentation.md docs/Commit_Plan.md docs/Release_and_Collaborators.md CONTRIBUTING.md CHANGELOG.md
git commit -m "chore(docs): add README, docs, commit plan, release guide"

# Commit 2: CI and gitignore
git add .github/workflows/ci.yml .gitignore
git commit -m "chore(ci): add GH Actions workflow and update .gitignore"

# Commit 3: security & scripts
git add lib/main.dart scripts/export_docs_to_pdf.ps1
git commit -m "chore(security): remove hard-coded Firebase options and add export script"

echo "Created branch $BRANCH with 3 commits. Review them before pushing to origin. To push: git push -u origin $BRANCH"