---
name: release
description: Bump the app version, update CHANGELOG.md, and tag a release that triggers the store workflows.
disable-model-invocation: true
argument-hint: "[patch|minor|major]"
---

Release bump: $ARGUMENTS (default `patch`).

1. Check the tree is clean and on `main` (`git status --short`, `git branch --show-current`). If not, stop and say why.
2. Read the `version:` line in `pubspec.yaml` (`x.y.z+N`). Bump `x.y.z` per the argument and always increment `N` — store build numbers must grow with every upload.
3. Draft a new `CHANGELOG.md` entry under `## [Unreleased]` → `## [x.y.z] - YYYY-MM-DD`, from `git log --oneline <last tag>..HEAD` (all commits if there's no tag). Group as Added / Changed / Fixed; keep it short.
4. Show the new version and the changelog entry, and ask the user to confirm.
5. On confirmation: commit `chore(release): vX.Y.Z` and create the annotated tag `vX.Y.Z`.
6. Ask before pushing. Pushing the tag runs `release-android.yml` and `release-ios.yml` (see `docs/RELEASING.md`).
