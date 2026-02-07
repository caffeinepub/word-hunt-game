# Android APK Build Guide for Word Hunt Game

This guide explains how to build an installable Android APK for the Word Hunt Game using the one-command build script.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Build Types](#build-types)
- [Signing Configuration](#signing-configuration)
- [Output Locations](#output-locations)
- [Web Download](#web-download)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **Java Development Kit (JDK) 17 or later**
   - Download: [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)
   - Set `JAVA_HOME` environment variable

2. **Android SDK**
   - Install via [Android Studio](https://developer.android.com/studio) or standalone SDK tools
   - Set `ANDROID_HOME` environment variable

3. **Node.js and npm**
   - Already required for the web app build

### Environment Variables

Set these environment variables before building:

**Linux/macOS:**
