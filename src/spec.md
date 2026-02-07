# Specification

## Summary
**Goal:** Ensure Android APK packaging publishes the latest APK as a static web asset that is verifiably available at `/downloads/word-hunt-latest.apk`, and that the Word Hunt UI shows the download control when it’s available.

**Planned changes:**
- Update `frontend/scripts/build-android-apk.sh` to copy/publish the newly built APK into the web build output as `frontend/dist/downloads/word-hunt-latest.apk`.
- Keep `frontend/public/downloads/word-hunt-latest.apk` in sync as part of the build script when the deployment pipeline uses `frontend/public/` for static assets.
- Add a fail-fast verification step to `frontend/scripts/build-android-apk.sh` that checks the published APK exists and is non-empty, printing clear English success/error messages and exiting non-zero on failure.
- Ensure the in-app APK availability check drives the Word Hunt header to show the download button only when `/downloads/word-hunt-latest.apk` is present (English labels: “Download APK” on larger screens, “APK” on small screens).

**User-visible outcome:** When the APK is successfully packaged and published, the deployed site serves `/downloads/word-hunt-latest.apk`, and the Word Hunt screen automatically shows a “Download APK”/“APK” button only when that file is available.
