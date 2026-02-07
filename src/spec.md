# Specification

## Summary
**Goal:** Make it easy to generate a production-ready Android release APK artifact from a single script command with deterministic output naming.

**Planned changes:**
- Update `frontend/scripts/build-android-apk.sh` to support an explicit release build option (in addition to debug), invoking the appropriate Gradle release task.
- Copy the produced debug and/or release APK into `frontend/android-apk-output/` with deterministic, clearly named filenames.
- Add clear failure handling when the expected release APK is not produced, including printing the expected path(s).
- Ensure the script prints the final deterministic output path(s) at the end of the run for both debug and release builds.
- Update `frontend/ANDROID_APK.md` with copy/paste-ready instructions for building the release APK via the one-command script, including the deterministic output path(s), while retaining debug instructions and Gradle output locations for reference.

**User-visible outcome:** A developer can run one command to build either a debug or release Android APK and find the resulting artifact(s) in `frontend/android-apk-output/` under stable, predictable filenames, with documented commands and output paths.
