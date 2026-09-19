---
name: release
description: Bump the app version (SemVer x.y.z+N) and add its CHANGELOG.md entry on the current feature branch, so merging the PR releases a new APK. Use when finalizing a PR.
argument-hint: "[major|minor|patch] [--build]"
---

Version bump for this branch: $ARGUMENTS (default: choose from the changes).

A release is routine work: in the main session, don't run these steps yourself. Hand them to a Sonnet subagent (`Agent` with `model: sonnet`) with the bump level, the branch, the exact changelog entry you want, and whether `--build` was asked for; then relay its result (see the token rules in `CLAUDE.md`).

**Keep it to a handful of tool calls.** Every call re-sends the whole conversation, so the cost is the number of steps, not the size of the work: read `pubspec.yaml` and the top of `CHANGELOG.md` in one command, write both files, commit, write the notes file in one go. A release without `--build` should take under ten calls and about a minute.

Every PR merged to `main` is a release: `release-android.yml` tags `vX.Y.Z`, builds the APK and the App Bundle itself, attaches the APK to a draft GitHub Release, and keeps both in the run's artifacts. CI fails a PR whose version isn't above the latest tag or has no changelog entry (see `docs/RELEASING.md`).

1. Stop if on `main`. Run `git fetch --tags --quiet`; the latest release is the first line of `git tag --list "v*" --sort=-v:refname`. Read `version:` in `pubspec.yaml` (`x.y.z+N`). With no tag yet, keep the version and only write its changelog entry. If the branch is already above the tag, adjust the bump level if needed and update its entry.
2. Bump the tag's version per [SemVer](https://semver.org) and reset the lower parts (`1.4.2` → `1.5.0`):
   - `major`: breaks existing users, e.g. data or backups that older versions can't read, or a removed feature.
   - `minor`: new user-facing features or behavior.
   - `patch`: fixes, and changes users don't notice (dependencies, docs, CI, refactors).
   Set `N` to the tag's build number + 1.
3. In `CHANGELOG.md`, add `## [x.y.z] - YYYY-MM-DD` right below `## [Unreleased]`, and move anything listed under Unreleased into it. Write it from `git log --oneline origin/main..HEAD`: Added / Changed / Fixed, short, in user-facing words.
4. Commit `chore(release): vX.Y.Z` on the branch, and put the version in the PR title or description.
5. Write Play's release notes to `store/play/release-notes/X.Y.Z.txt` (the `store/` folder is gitignored; create it if missing), in **one** write. Say what changed for the user, from this version's `CHANGELOG.md` entry alone, in two to four short `•` lines, one block per store listing language as `<code>`…`</code>` tags, with the same 23 codes in the same order as the previous file in that folder: en-US, ar, bn-BD, zh-CN, nl-NL, fr-FR, de-DE, el-GR, hi-IN, id, it-IT, ja-JP, ko-KR, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-419, th, tr-TR, ur, vi. Each block is at most 500 characters, Play's limit. Don't open the ARB files for this: they are 25–40 KB each and cost more than everything else here put together. Give the user the path: they paste the whole file into the release's notes box, on each track it goes to.
6. **Only with `--build`:** build the local artifacts, because CI builds the same ones on merge. Ask for it when the user is about to hand-test a release build or upload to Play before the merge; otherwise the APK is on the draft release and the App Bundle is in the merge run's artifacts. Two `--release` builds take about twelve minutes, so build only what was asked for: `flutter build apk --release` for testing on a phone, `build appbundle --release` for Play, both only if both are wanted. Run them in the background with `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter.bat`, then copy `build/app/outputs/flutter-apk/app-release.apk` to `dist/monthly-expenses-X.Y.Z.apk`, `build/app/outputs/bundle/release/app-release.aab` to `dist/monthly-expenses-X.Y.Z.aab`, and `build/app/outputs/mapping/release/mapping.txt` to `dist/monthly-expenses-X.Y.Z-mapping.txt`, with PowerShell `Copy-Item` and absolute paths (Bash `cp` under `build/` is blocked). Check `versionName` and `versionCode` with `aapt2 dump badging` from the Android SDK `build-tools`, and give the user the path. Rebuild after any later app change on the branch.
