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
# Usage:
#   ./build-android-apk.sh           # Build debug APK (default)
#   ./build-android-apk.sh --release # Build unsigned release APK
#   ./build-android-apk.sh --release --signed # Build signed release APK
#   BUILD_TYPE=release ./build-android-apk.sh  # Build release APK (env var)
#
# Output:
# - Debug APK: frontend/android-apk-output/word-hunt-debug.apk
# - Unsigned Release APK: frontend/android-apk-output/word-hunt-release-unsigned.apk
# - Signed Release APK: frontend/android-apk-output/word-hunt-release.apk
# - Published Web Copy (immediate): frontend/dist/downloads/word-hunt-latest.apk
# - Published Web Copy (future builds): frontend/public/downloads/word-hunt-latest.apk
# ============================================================================

# ============================================================================
# Parse Arguments and Determine Build Type
# ============================================================================
BUILD_TYPE="debug"
ENABLE_SIGNING=false

# Check for flags
for arg in "$@"; do
  if [ "$arg" = "--release" ]; then
    BUILD_TYPE="release"
  elif [ "$arg" = "--signed" ]; then
    ENABLE_SIGNING=true
  fi
done

# Check for BUILD_TYPE environment variable (allow override)
if [ -n "${BUILD_TYPE:-}" ] && [ "$BUILD_TYPE" != "debug" ]; then
  # BUILD_TYPE was set via environment, keep it
  :
fi

# Normalize build type to lowercase
BUILD_TYPE=$(echo "$BUILD_TYPE" | tr '[:upper:]' '[:lower:]')

# Validate build type
if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
  echo "❌ ERROR: Invalid build type '$BUILD_TYPE'"
  echo ""
  echo "Valid options: debug, release"
  echo ""
  echo "Usage:"
  echo "  ./build-android-apk.sh           # Build debug APK (default)"
  echo "  ./build-android-apk.sh --release # Build unsigned release APK"
  echo "  ./build-android-apk.sh --release --signed # Build signed release APK"
  echo "  BUILD_TYPE=release ./build-android-apk.sh  # Build release APK (env var)"
  echo ""
  exit 1
fi

# Signing is only applicable to release builds
if [ "$ENABLE_SIGNING" = true ] && [ "$BUILD_TYPE" != "release" ]; then
  echo "❌ ERROR: --signed flag can only be used with release builds"
  echo ""
  echo "Usage:"
  echo "  ./build-android-apk.sh --release --signed"
  echo ""
  exit 1
fi

echo "🚀 Starting Android APK build for Word Hunt Game..."
echo "📦 Build type: $BUILD_TYPE"
if [ "$ENABLE_SIGNING" = true ]; then
  echo "🔐 Signing: enabled"
fi
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
# Step 1.5: Validate Signing Configuration (if enabled)
# ============================================================================
if [ "$ENABLE_SIGNING" = true ]; then
  echo "🔐 Validating signing configuration..."
  
  SIGNING_PROPS_FILE="$FRONTEND_DIR/android/signing.properties"
  MISSING_INPUTS=()
  
  # Check for signing.properties file
  if [ -f "$SIGNING_PROPS_FILE" ]; then
    echo "✅ Found signing.properties file"
    
    # Source the properties file to check for required keys
    # Note: We're just checking existence, not validating values
    if ! grep -q "RELEASE_STORE_FILE" "$SIGNING_PROPS_FILE"; then
      MISSING_INPUTS+=("RELEASE_STORE_FILE in signing.properties")
    fi
    if ! grep -q "RELEASE_STORE_PASSWORD" "$SIGNING_PROPS_FILE"; then
      MISSING_INPUTS+=("RELEASE_STORE_PASSWORD in signing.properties")
    fi
    if ! grep -q "RELEASE_KEY_ALIAS" "$SIGNING_PROPS_FILE"; then
      MISSING_INPUTS+=("RELEASE_KEY_ALIAS in signing.properties")
    fi
    if ! grep -q "RELEASE_KEY_PASSWORD" "$SIGNING_PROPS_FILE"; then
      MISSING_INPUTS+=("RELEASE_KEY_PASSWORD in signing.properties")
    fi
  else
    # Check for environment variables as fallback
    if [ -z "$RELEASE_STORE_FILE" ]; then
      MISSING_INPUTS+=("RELEASE_STORE_FILE environment variable or signing.properties file")
    fi
    if [ -z "$RELEASE_STORE_PASSWORD" ]; then
      MISSING_INPUTS+=("RELEASE_STORE_PASSWORD environment variable")
    fi
    if [ -z "$RELEASE_KEY_ALIAS" ]; then
      MISSING_INPUTS+=("RELEASE_KEY_ALIAS environment variable")
    fi
    if [ -z "$RELEASE_KEY_PASSWORD" ]; then
      MISSING_INPUTS+=("RELEASE_KEY_PASSWORD environment variable")
    fi
  fi
  
  # If any required inputs are missing, fail with clear instructions
  if [ ${#MISSING_INPUTS[@]} -gt 0 ]; then
    echo ""
    echo "❌ ERROR: Signing is enabled but required signing configuration is missing."
    echo ""
    echo "Missing inputs:"
    for input in "${MISSING_INPUTS[@]}"; do
      echo "  - $input"
    done
    echo ""
    echo "To sign your release APK, you must provide:"
    echo "  1. RELEASE_STORE_FILE - Path to your keystore file (.jks or .keystore)"
    echo "  2. RELEASE_STORE_PASSWORD - Password for the keystore"
    echo "  3. RELEASE_KEY_ALIAS - Alias of the key in the keystore"
    echo "  4. RELEASE_KEY_PASSWORD - Password for the key"
    echo ""
    echo "You can provide these in two ways:"
    echo ""
    echo "Option 1: Create a signing.properties file (recommended)"
    echo "  1. Copy the example file:"
    echo "     cp frontend/android/signing.properties.example frontend/android/signing.properties"
    echo "  2. Edit frontend/android/signing.properties with your actual values"
    echo "  3. This file is git-ignored and will not be committed"
    echo ""
    echo "Option 2: Set environment variables"
    echo "  export RELEASE_STORE_FILE=/path/to/your/keystore.jks"
    echo "  export RELEASE_STORE_PASSWORD=your_keystore_password"
    echo "  export RELEASE_KEY_ALIAS=your_key_alias"
    echo "  export RELEASE_KEY_PASSWORD=your_key_password"
    echo ""
    echo "If you don't have a keystore yet, generate one with:"
    echo "  keytool -genkey -v -keystore my-release-key.jks -keyalg RSA \\"
    echo "    -keysize 2048 -validity 10000 -alias my-key-alias"
    echo ""
    echo "For detailed instructions, see: frontend/ANDROID_APK.md"
    echo ""
    exit 1
  fi
  
  # Validate keystore file exists (if using signing.properties)
  if [ -f "$SIGNING_PROPS_FILE" ]; then
    KEYSTORE_PATH=$(grep "RELEASE_STORE_FILE" "$SIGNING_PROPS_FILE" | cut -d'=' -f2)
    # Remove any surrounding quotes and whitespace
    KEYSTORE_PATH=$(echo "$KEYSTORE_PATH" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')
    
    # Handle relative paths (relative to android directory)
    if [[ ! "$KEYSTORE_PATH" = /* ]]; then
      KEYSTORE_PATH="$FRONTEND_DIR/android/$KEYSTORE_PATH"
    fi
    
    if [ ! -f "$KEYSTORE_PATH" ]; then
      echo ""
      echo "❌ ERROR: Keystore file not found at: $KEYSTORE_PATH"
      echo ""
      echo "The signing.properties file specifies a keystore path, but the file does not exist."
      echo "Please ensure:"
      echo "  1. The RELEASE_STORE_FILE path in signing.properties is correct"
      echo "  2. The keystore file exists at the specified location"
      echo "  3. You have read permissions for the keystore file"
      echo ""
      echo "If you need to generate a new keystore, run:"
      echo "  keytool -genkey -v -keystore my-release-key.jks -keyalg RSA \\"
      echo "    -keysize 2048 -validity 10000 -alias my-key-alias"
      echo ""
      exit 1
    fi
    
    echo "✅ Keystore file found: $KEYSTORE_PATH"
  elif [ -n "$RELEASE_STORE_FILE" ]; then
    # Validate keystore from environment variable
    if [ ! -f "$RELEASE_STORE_FILE" ]; then
      echo ""
      echo "❌ ERROR: Keystore file not found at: $RELEASE_STORE_FILE"
      echo ""
      echo "The RELEASE_STORE_FILE environment variable points to a file that does not exist."
      echo "Please ensure the path is correct and the file exists."
      echo ""
      exit 1
    fi
    echo "✅ Keystore file found: $RELEASE_STORE_FILE"
  fi
  
  echo "✅ Signing configuration validated"
  echo ""
fi

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

# Determine Gradle task based on build type
if [ "$BUILD_TYPE" = "release" ]; then
  GRADLE_TASK="assembleRelease"
  if [ "$ENABLE_SIGNING" = true ]; then
    echo "Building signed release APK..."
    # Set environment variable to enable signing in Gradle
    export ENABLE_RELEASE_SIGNING=true
  else
    echo "Building unsigned release APK..."
  fi
else
  GRADLE_TASK="assembleDebug"
  echo "Building debug APK..."
fi

# Build APK
"$GRADLEW" "$GRADLE_TASK"

echo ""
echo "✅ Android APK build completed!"
echo ""

# ============================================================================
# Step 5: Copy APK to Deterministic Output Directory
# ============================================================================
echo "📦 Copying APK to deterministic output directory..."

# Define paths based on build type
OUTPUT_DIR="$FRONTEND_DIR/android-apk-output"
mkdir -p "$OUTPUT_DIR"

if [ "$BUILD_TYPE" = "release" ]; then
  if [ "$ENABLE_SIGNING" = true ]; then
    # Signed release APK paths
    GRADLE_APK="$FRONTEND_DIR/android/app/build/outputs/apk/release/app-release.apk"
    OUTPUT_APK="$OUTPUT_DIR/word-hunt-release.apk"
    
    # Verify the signed release APK exists
    if [ ! -f "$GRADLE_APK" ]; then
      echo ""
      echo "❌ ERROR: Signed release APK not found after Gradle build."
      echo ""
      echo "Expected location: $GRADLE_APK"
      echo ""
      echo "The Gradle build completed but did not produce a signed APK."
      echo "This may indicate:"
      echo "  1. Signing configuration was not properly applied"
      echo "  2. Keystore credentials are incorrect"
      echo "  3. Build errors occurred during signing"
      echo ""
      echo "Please check the Gradle output above for signing errors."
      echo "Verify your signing configuration in:"
      echo "  - frontend/android/signing.properties (if using properties file)"
      echo "  - Environment variables (if using env vars)"
      echo ""
      exit 1
    fi
  else
    # Unsigned release APK paths
    GRADLE_APK="$FRONTEND_DIR/android/app/build/outputs/apk/release/app-release-unsigned.apk"
    OUTPUT_APK="$OUTPUT_DIR/word-hunt-release-unsigned.apk"
    
    # Verify the unsigned release APK exists
    if [ ! -f "$GRADLE_APK" ]; then
      echo ""
      echo "❌ ERROR: Unsigned release APK not found after Gradle build."
      echo ""
      echo "Expected location: $GRADLE_APK"
      echo ""
      echo "The Gradle build completed but did not produce the expected APK file."
      echo "This may indicate a build configuration issue or Gradle task failure."
      echo ""
      echo "Please check the Gradle output above for errors and ensure:"
      echo "  - The assembleRelease task completed successfully"
      echo "  - No build errors occurred during compilation"
      echo "  - The Android project configuration is correct"
      echo ""
      echo "Note: To build a signed release APK, use: ./build-android-apk.sh --release --signed"
      echo ""
      exit 1
    fi
  fi
else
  # Debug APK paths
  GRADLE_APK="$FRONTEND_DIR/android/app/build/outputs/apk/debug/app-debug.apk"
  OUTPUT_APK="$OUTPUT_DIR/word-hunt-debug.apk"
  
  # Verify the debug APK exists
  if [ ! -f "$GRADLE_APK" ]; then
    echo ""
    echo "❌ ERROR: Debug APK not found after Gradle build."
    echo ""
    echo "Expected location: $GRADLE_APK"
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
fi

# Copy the APK to the deterministic output directory
cp "$GRADLE_APK" "$OUTPUT_APK"

if [ ! -f "$OUTPUT_APK" ]; then
  echo ""
  echo "❌ ERROR: Failed to copy APK to output directory."
  echo ""
  echo "Source: $GRADLE_APK"
  echo "Target: $OUTPUT_APK"
  echo ""
  exit 1
fi

echo "✅ APK copied to deterministic output directory"
echo ""

# ============================================================================
# Step 6: Publish APK to Web Download Directories
# ============================================================================
echo "🌐 Publishing APK to web download directories..."

# Ensure the dist downloads directory exists
DIST_DOWNLOADS_DIR="$FRONTEND_DIR/dist/downloads"
mkdir -p "$DIST_DOWNLOADS_DIR"

if [ ! -d "$DIST_DOWNLOADS_DIR" ]; then
  echo ""
  echo "❌ ERROR: Failed to create dist downloads directory."
  echo ""
  echo "Target: $DIST_DOWNLOADS_DIR"
  echo ""
  exit 1
fi

# Ensure the public downloads directory exists
PUBLIC_DOWNLOADS_DIR="$FRONTEND_DIR/public/downloads"
mkdir -p "$PUBLIC_DOWNLOADS_DIR"

if [ ! -d "$PUBLIC_DOWNLOADS_DIR" ]; then
  echo ""
  echo "❌ ERROR: Failed to create public downloads directory."
  echo ""
  echo "Target: $PUBLIC_DOWNLOADS_DIR"
  echo ""
  exit 1
fi

# Define the published APK name
PUBLISHED_APK_NAME="word-hunt-latest.apk"
DIST_PUBLISHED_APK="$DIST_DOWNLOADS_DIR/$PUBLISHED_APK_NAME"
PUBLIC_PUBLISHED_APK="$PUBLIC_DOWNLOADS_DIR/$PUBLISHED_APK_NAME"

# Copy to dist/downloads (for immediate deployment)
echo "📋 Publishing to dist/downloads (immediate deployment)..."
cp "$OUTPUT_APK" "$DIST_PUBLISHED_APK"

if [ ! -f "$DIST_PUBLISHED_APK" ]; then
  echo ""
  echo "❌ ERROR: Failed to publish APK to dist downloads directory."
  echo ""
  echo "Source: $OUTPUT_APK"
  echo "Target: $DIST_PUBLISHED_APK"
  echo ""
  echo "This APK is required for the deployed web app to serve at /downloads/word-hunt-latest.apk"
  echo ""
  exit 1
fi

echo "✅ Published to: $DIST_PUBLISHED_APK"

# Copy to public/downloads (for future web builds)
echo "📋 Publishing to public/downloads (future web builds)..."
cp "$OUTPUT_APK" "$PUBLIC_PUBLISHED_APK"

if [ ! -f "$PUBLIC_PUBLISHED_APK" ]; then
  echo ""
  echo "❌ ERROR: Failed to publish APK to public downloads directory."
  echo ""
  echo "Source: $OUTPUT_APK"
  echo "Target: $PUBLIC_PUBLISHED_APK"
  echo ""
  echo "This APK is required for future web builds to include the latest APK."
  echo ""
  exit 1
fi

echo "✅ Published to: $PUBLIC_PUBLISHED_APK"
echo ""

# ============================================================================
# Success Summary
# ============================================================================
echo "🎉 Build and publish completed successfully!"
echo ""
echo "📍 Deterministic APK output:"
echo "   $OUTPUT_APK"
echo ""
echo "🌐 Published web downloads:"
echo "   Immediate deployment: $DIST_PUBLISHED_APK"
echo "   Future web builds:    $PUBLIC_PUBLISHED_APK"
echo ""
echo "📱 Runtime download URL: /downloads/word-hunt-latest.apk"
echo ""
echo "Next steps:"
echo "  1. Deploy the updated frontend/dist directory to your web host"
echo "  2. The APK will be available at: https://your-domain.com/downloads/word-hunt-latest.apk"
echo "  3. The in-app Download APK button will automatically appear when the APK is detected"
echo ""
echo "To install the APK on an Android device:"
echo "  1. Enable 'Install from Unknown Sources' in Android settings"
echo "  2. Download the APK from the web app or transfer it directly"
echo "  3. Open the APK file to install"
echo ""
