#!/usr/bin/env bash
set -e

# ============================================================================
# One-Command Android APK Build Script for Word Hunt Game
# ============================================================================
# This script builds the web app and generates an installable Android APK
# using the existing Capacitor + Gradle setup.
#
# Prerequisites:
# - JAVA_HOME must be set and point to JDK 17+
# - ANDROID_HOME must be set and point to Android SDK
# - Gradle wrapper must exist at frontend/android/gradlew
#
# Output:
# - Debug APK: frontend/android/app/build/outputs/apk/debug/app-debug.apk
# - Deterministic copy: frontend/android-apk-output/word-hunt-debug.apk
# ============================================================================

echo "🚀 Starting Android APK build for Word Hunt Game..."
echo ""

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$FRONTEND_DIR/.." && pwd)"

# ============================================================================
# Step 1: Validate Prerequisites
# ============================================================================
echo "📋 Validating prerequisites..."

# Check JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
  echo "❌ ERROR: JAVA_HOME is not set."
  echo ""
  echo "Please set JAVA_HOME to your JDK 17 (or later) installation directory."
  echo "Example (Linux/macOS):"
  echo "  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
  echo ""
  echo "Example (Windows):"
  echo "  set JAVA_HOME=C:\\Program Files\\Java\\jdk-17"
  echo ""
  echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
  exit 1
fi

if [ ! -d "$JAVA_HOME" ]; then
  echo "❌ ERROR: JAVA_HOME is set but directory does not exist: $JAVA_HOME"
  echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
  exit 1
fi

echo "✅ JAVA_HOME: $JAVA_HOME"

# Check Java version (must be 17 or later)
JAVA_CMD="$JAVA_HOME/bin/java"
if [ ! -f "$JAVA_CMD" ]; then
  # Fallback to java on PATH
  JAVA_CMD="java"
  if ! command -v "$JAVA_CMD" &> /dev/null; then
    echo "❌ ERROR: Java executable not found."
    echo ""
    echo "Please ensure Java 17 or later is installed and JAVA_HOME is set correctly."
    echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
    exit 1
  fi
fi

# Extract Java version
JAVA_VERSION_OUTPUT=$("$JAVA_CMD" -version 2>&1)
JAVA_VERSION=$(echo "$JAVA_VERSION_OUTPUT" | grep -oP 'version "?\K[0-9]+' | head -1)

if [ -z "$JAVA_VERSION" ]; then
  echo "⚠️  WARNING: Could not determine Java version from: $JAVA_CMD"
  echo "Output: $JAVA_VERSION_OUTPUT"
  echo ""
  echo "This project requires Java 17 or later."
  echo "If the build fails, please verify your Java installation."
  echo ""
else
  echo "✅ Java version: $JAVA_VERSION"
  
  if [ "$JAVA_VERSION" -lt 17 ]; then
    echo ""
    echo "❌ ERROR: Java 17 or later is required, but found Java $JAVA_VERSION"
    echo ""
    echo "This Android project uses Gradle 8.4 and Android Gradle Plugin 8.2.1,"
    echo "which require Java 17 as the minimum version."
    echo ""
    echo "Please install Java 17 or later and set JAVA_HOME accordingly."
    echo ""
    echo "Download options:"
    echo "  - Oracle JDK: https://www.oracle.com/java/technologies/downloads/"
    echo "  - OpenJDK: https://adoptium.net/"
    echo ""
    echo "Example setup (Linux/macOS):"
    echo "  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
    echo ""
    echo "Example setup (Windows):"
    echo "  set JAVA_HOME=C:\\Program Files\\Java\\jdk-17"
    echo ""
    echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
    exit 1
  fi
fi

echo ""

# Check ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
  echo "❌ ERROR: ANDROID_HOME is not set."
  echo ""
  echo "Please set ANDROID_HOME to your Android SDK installation directory."
  echo "Example (Linux/macOS):"
  echo "  export ANDROID_HOME=\$HOME/Android/Sdk"
  echo ""
  echo "Example (Windows):"
  echo "  set ANDROID_HOME=%LOCALAPPDATA%\\Android\\Sdk"
  echo ""
  echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
  exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
  echo "❌ ERROR: ANDROID_HOME is set but directory does not exist: $ANDROID_HOME"
  echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
  exit 1
fi

echo "✅ ANDROID_HOME: $ANDROID_HOME"

# Check Gradle wrapper
GRADLEW="$FRONTEND_DIR/android/gradlew"
if [ ! -f "$GRADLEW" ]; then
  echo "❌ ERROR: Gradle wrapper not found at: $GRADLEW"
  echo "Please ensure the Capacitor Android project is properly initialized."
  echo "For detailed setup instructions, see: frontend/ANDROID_APK.md"
  exit 1
fi

# Make gradlew executable
chmod +x "$GRADLEW"
echo "✅ Gradle wrapper: $GRADLEW"

echo ""

# ============================================================================
# Step 2: Build Web App
# ============================================================================
echo "🔨 Building web app..."
cd "$FRONTEND_DIR"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Build the web app
npm run build:skip-bindings

if [ ! -d "dist" ]; then
  echo "❌ ERROR: Web build failed - dist directory not found."
  exit 1
fi

echo "✅ Web app built successfully"
echo ""

# ============================================================================
# Step 3: Sync Capacitor
# ============================================================================
echo "🔄 Syncing Capacitor Android project..."

# Run Capacitor sync to copy web assets to Android project
npx cap sync android

echo "✅ Capacitor sync completed"
echo ""

# ============================================================================
# Step 4: Build Android APK
# ============================================================================
echo "📱 Building Android APK with Gradle..."
cd "$FRONTEND_DIR/android"

# Build debug APK by default
"$GRADLEW" assembleDebug

echo ""
echo "✅ Android APK build completed!"
echo ""

# ============================================================================
# Step 5: Copy APK to Deterministic Output Directory
# ============================================================================
echo "📦 Copying APK to deterministic output directory..."

# Define paths
DEBUG_APK="$FRONTEND_DIR/android/app/build/outputs/apk/debug/app-debug.apk"
OUTPUT_DIR="$FRONTEND_DIR/android-apk-output"
OUTPUT_APK="$OUTPUT_DIR/word-hunt-debug.apk"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Verify the debug APK exists
if [ ! -f "$DEBUG_APK" ]; then
  echo ""
  echo "❌ ERROR: Debug APK not found after Gradle build."
  echo ""
  echo "Expected location: $DEBUG_APK"
  echo ""
  echo "The Gradle build completed but did not produce the expected APK file."
  echo "This may indicate a build configuration issue or Gradle task failure."
  echo ""
  echo "Please check the Gradle output above for errors and ensure:"
  echo "  - The assembleDebug task completed successfully"
  echo "  - No build errors occurred during compilation"
  echo "  - The Android project configuration is correct"
  echo ""
  exit 1
fi

# Copy the APK to the deterministic output directory
cp "$DEBUG_APK" "$OUTPUT_APK"

if [ ! -f "$OUTPUT_APK" ]; then
  echo ""
  echo "❌ ERROR: Failed to copy APK to output directory."
  echo ""
  echo "Source: $DEBUG_APK"
  echo "Target: $OUTPUT_APK"
  echo ""
  exit 1
fi

echo "✅ APK copied to deterministic output directory"
echo ""

# ============================================================================
# Step 6: Display Output Paths
# ============================================================================
echo "📦 APK Output Locations:"
echo ""

# Show Gradle output location
if [ -f "$DEBUG_APK" ]; then
  APK_SIZE=$(du -h "$DEBUG_APK" | cut -f1)
  echo "  ✅ Gradle Debug APK ($APK_SIZE):"
  echo "     $DEBUG_APK"
  echo ""
fi

# Show deterministic output location
if [ -f "$OUTPUT_APK" ]; then
  APK_SIZE=$(du -h "$OUTPUT_APK" | cut -f1)
  echo "  ✅ Deterministic Output APK ($APK_SIZE):"
  echo "     $OUTPUT_APK"
  echo ""
fi

# Check for release APK (optional)
RELEASE_APK="$FRONTEND_DIR/android/app/build/outputs/apk/release/app-release-unsigned.apk"
if [ -f "$RELEASE_APK" ]; then
  APK_SIZE=$(du -h "$RELEASE_APK" | cut -f1)
  echo "  ✅ Release APK ($APK_SIZE):"
  echo "     $RELEASE_APK"
  echo ""
fi

echo "🎉 Build complete! You can now install the APK on your Android device."
echo ""
echo "📍 Deterministic APK path:"
echo "   $OUTPUT_APK"
echo ""
echo "To install:"
echo "  1. Transfer the APK to your Android device"
echo "  2. Enable 'Install from Unknown Sources' in device settings"
echo "  3. Open the APK file to install"
echo ""
echo "Or use ADB:"
echo "  adb install \"$OUTPUT_APK\""
echo ""
