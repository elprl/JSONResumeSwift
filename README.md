# JSON Resume — Swift iOS / iPadOS App

An app for viewing and sharing a standardised CV based on the open-source [JSON Resume](https://jsonresume.org) schema.

It started as a test harness for **Swift 6**, **SwiftData**, and **App Clips**, and grew into a small resume viewer with built-in AI chat for CV feedback.

## Features

- Load and display JSON Resume data (basics, work, education, skills, and more)
- Per-resume notes and AI chat scoped to CV content
- AI providers: **ChatGPT**, **Claude**, and **Gemini**
- QR code generation for sharing a resume URL
- **App Clip** target for lightweight resume sharing without a full App Store install

## Requirements

- **Xcode 16** or later
- **Swift 6**
- **iOS 17.0+** (main app target)
- Apple Silicon or Intel Mac for the simulator

## Getting started

1. Clone the repo and open `OpenCV.xcodeproj` in Xcode.
2. **Add `GoogleService-Info.plist`** — required for Gemini (see below). This file is **not** committed to the repo.
3. Create `OpenCV/Env/DebugConfig.xcconfig` if you want mock API keys for Debug builds (see below).
4. Select the **OpenCV** scheme and run on an iOS Simulator or device.

### GoogleService-Info.plist (required for Gemini)

Gemini integration uses [Firebase AI Logic](https://firebase.google.com/docs/ai-logic) from the [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk). The deprecated [Google Generative AI Swift SDK](https://github.com/google-gemini/deprecated-generative-ai-swift) is no longer used.

**You must add your own `GoogleService-Info.plist` before Gemini will work.** The app calls `FirebaseApp.configure()` at launch (`OpenCVApp.swift`), which expects this file to be present in the **OpenCV** target. Without it, the app may fail to start or Gemini requests will not authenticate.

1. Create a [Firebase project](https://console.firebase.google.com) and add an iOS app with bundle ID `com.tapdigital.OpenCV`.
2. Download `GoogleService-Info.plist` from the Firebase console.
3. Place it at `OpenCV/GoogleService-Info.plist` and ensure it is included in the **OpenCV** target (Copy Bundle Resources).
4. Enable the Gemini API for your Firebase / Google Cloud project.

`GoogleService-Info*.plist` is listed in `.gitignore` — do not commit it.

### API keys

API keys are stored in the iOS Keychain via **Settings** in the app. For local Debug builds, you can supply mock keys without committing secrets.

Create `OpenCV/Env/DebugConfig.xcconfig` (this file is gitignored via `*.xcconfig`):

```
MOCK_OPENAI_TOKEN[config=Debug]=your-openai-key
MOCK_CLAUDE_TOKEN[config=Debug]=your-claude-key
MOCK_GEMINI_TOKEN[config=Debug]=your-gemini-key
```

The Debug configuration reads these values into `Info.plist` at build time.

> **Note:** Gemini’s free tier is unavailable in some regions (e.g. the UK). Enable billing in [Google AI Studio](https://aistudio.google.com) if requests fail with location or quota errors.

## Schemes

| Scheme | Description |
|--------|-------------|
| `OpenCV` | Main app (**JSON CV**) |
| `OpenCVAppClip` | App Clip target (iOS 17.0+, shares AI service code with the main app) |

## Architecture

- **SwiftUI** views with `@Observable` view models
- **SwiftData** for `Person` and `ChatMessage` persistence
- **MVVM**-style modules under `OpenCV/Modules/`
- AI services behind `AGIServiceProtocol` in `OpenCV/Services/AIService/`

## Key dependencies

| Package | Purpose |
|---------|---------|
| [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk) | Firebase Core + AI Logic (Gemini) |
| [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) | Claude API |
| [GPT3-Tokenizer](https://github.com/aespinilla/GPT3-Tokenizer) | Token counting |
| [CodeScanner](https://github.com/twostraws/CodeScanner) | QR scanning |
| [swift-markdown](https://github.com/apple/swift-markdown) | Markdown rendering |
| [Nuke](https://github.com/kean/Nuke) | Image loading |

## How it started

This app began as a test harness for Swift 6 and SwiftData. App Clips were added as a way to share a CV with iPhone users without requiring a full App Store download — though App Clips are difficult to exercise end-to-end until the main app is on the App Store.
