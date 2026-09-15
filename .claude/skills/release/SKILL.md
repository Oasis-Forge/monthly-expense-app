---
name: release
description: Bump the app version (SemVer x.y.z+N) and add its CHANGELOG.md entry on the current feature branch, so merging the PR releases a new APK. Use when finalizing a PR.
argument-hint: "[major|minor|patch]"
---

Version bump for this branch: $ARGUMENTS (default: choose from the changes).

A release is routine work: in the main session, don't run these steps yourself. Hand them to a Sonnet subagent (`Agent` with `model: sonnet`) with the bump level, the branch, and a one-line summary of each commit for the changelog, and relay its result (see the token rules in `CLAUDE.md`).

Every PR merged to `main` is a release: `release-android.yml` tags `vX.Y.Z` and attaches `monthly-expenses-X.Y.Z.apk` to a draft GitHub Release. CI fails a PR whose version isn't above the latest tag or has no changelog entry (see `docs/RELEASING.md`).

1. Stop if on `main`. Run `git fetch --tags --quiet`; the latest release is the first line of `git tag --list "v*" --sort=-v:refname`. Read `version:` in `pubspec.yaml` (`x.y.z+N`). With no tag yet, keep the version and only write its changelog entry. If the branch is already above the tag, adjust the bump level if needed and update its entry.
2. Bump the tag's version per [SemVer](https://semver.org) and reset the lower parts (`1.4.2` → `1.5.0`):
   - `major`: breaks existing users, e.g. data or backups that older versions can't read, or a removed feature.
   - `minor`: new user-facing features or behavior.
   - `patch`: fixes, and changes users don't notice (dependencies, docs, CI, refactors).
   Set `N` to the tag's build number + 1.
3. In `CHANGELOG.md`, add `## [x.y.z] - YYYY-MM-DD` right below `## [Unreleased]`, and move anything listed under Unreleased into it. Write it from `git log --oneline origin/main..HEAD`: Added / Changed / Fixed, short, in user-facing words.
4. Commit `chore(release): vX.Y.Z` on the branch, and put the version in the PR title or description.
5. Build the local APK so `dist/` always matches the branch: run `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter.bat build apk --release` in the background, then copy `build/app/outputs/flutter-apk/app-release.apk` to `dist/monthly-expenses-X.Y.Z.apk` with Bash `cp` (settings block PowerShell reads under `build/`). Check `versionName` and `versionCode` with `aapt2 dump badging` from the Android SDK `build-tools`, and give the user the path. Rebuild it after any later app change on the branch.
