# Building an Android APK for Word Hunt Game

This guide explains how to package the Word Hunt Game as an installable Android APK using two different approaches: **Trusted Web Activity (TWA)** via Bubblewrap, or **Capacitor** for a WebView-based wrapper.

**Important:** No backend changes are required for Android packaging. The Word Hunt Game runs entirely client-side and uses the existing PWA build output.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Build APK (One Command)](#build-apk-one-command)
3. [Release APK](#release-apk)
4. [PWA Assets Reference](#pwa-assets-reference)
5. [Approach 1: Bubblewrap TWA](#approach-1-bubblewrap-twa)
6. [Approach 2: Capacitor WebView](#approach-2-capacitor-webview)
7. [Troubleshooting](#troubleshooting)
8. [Production Release](#production-release)

---

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Node.js** (v16 or later) and npm/pnpm
- **Java Development Kit (JDK)** 17 or later
  - Download from [Oracle](https://www.oracle.com/java/technologies/downloads/) or use [OpenJDK](https://adoptium.net/)
  - Set `JAVA_HOME` environment variable
  - **Note:** Java 17 is the minimum required version for this project (Gradle 8.4 + Android Gradle Plugin 8.2.1)
- **Android Studio** or **Android SDK Command-line Tools**
  - Download from [developer.android.com](https://developer.android.com/studio)
  - Install Android SDK Platform 33 (or latest)
  - Install Android SDK Build-Tools (version 33.0.0 or later)
  - Set `ANDROID_HOME` environment variable

### Environment Variables Setup

**Linux/macOS:**

