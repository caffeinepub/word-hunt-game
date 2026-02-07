# Specification

## Summary
**Goal:** Package the current deployed draft into a fresh Android APK and publish it so it’s downloadable from the deployed web app at `/downloads/word-hunt-latest.apk`.

**Planned changes:**
- Run and rely on the existing one-command build script (`frontend/scripts/build-android-apk.sh`) to produce a new APK artifact under `frontend/android-apk-output/`.
- Copy/publish the latest built APK to `frontend/dist/downloads/word-hunt-latest.apk` for deployment output.
- Also copy/publish the latest built APK to `frontend/public/downloads/word-hunt-latest.apk` so future web builds include it.
- Ensure the app’s existing header download control (“Download APK” / “APK”) becomes visible by making the runtime APK availability check succeed via the published file at the required path.

**User-visible outcome:** Users can download the latest Android APK from the site at `/downloads/word-hunt-latest.apk`, and the in-app header shows an English-labeled download control.
