# JSON Resume Swift iOS / iPadOS App

An app to show a standardised CV from the open-source JSON Resume project - https://github.com/jsonresume.

## Install
- Build using Xcode 16 and run. Uses Swift 6.
- Put your mock api keys `DebugConfig.xcconfig` (don't add to git):
```
MOCK_OPENAI_TOKEN[config=Debug]=apikey1
MOCK_CLAUDE_TOKEN[config=Debug]=apikey2
MOCK_GEMINI_TOKEN[config=Debug]=apikey3
```

### How it started
This app started life as a test harness for Swift 6 and SwiftData explorations. 
Later the project explored App Clips as a way to share your CV / Resume to iPhone uses with them needing to download the app from the app store. Hard to test without being on the app store first.
