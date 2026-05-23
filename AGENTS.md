# Repository Guidelines

## Quick Reference

- See @README.md for project overview.
- -scheme "OpenCV" is release version pointing to live firebase  
- -scheme "OpenCV(Staging)" is pointing to firebase staging version
- -scheme "OpenCV(Develop)" points to localhost firebase version.

## For Daily Development

### Release Workflow

- Use `bundle exec fastlane ios public_beta` as the canonical TestFlight release lane.
- The `bump` lane resolves the next build number as `max(version-scoped TestFlight build, committed xcodeproj build) + 1`, then commits the `OpenCV.xcodeproj` build-number change before the archive is built.
- Keep the release working tree clean before running `public_beta`; the lane then badges icons, builds, uploads to TestFlight, creates the git tag/GitHub release, and sends Slack.
- If App Store Connect rejects an upload because a bundle version already exists, rerun the lane after the previous upload appears in TestFlight so `bump` can read the newer build number.

### Overview

- iOS 26 SwiftUI app targeting iPhone, iPad, macOS (Designed for iPad)
- Minimum deployment: iOS 26
- Swift 6.3 with strict concurrency
- Use SwiftUI throughout - no UIKit unless absolutely necessary
- Use Apple's newest Swift Testing framework
- Strict MVVM architecture
- Use xcrun mcpbridge `BuildProject` for compilation, not shell commands, or
- `xcodebuildmcp simulator build --scheme "OpenCV(Develop)" --project-path OpenCV.xcodeproj --simulator-name "iPhone 17" --derived-data-path "build/"`
- If above fails, use: `xcodebuild -project OpenCV.xcodeproj -scheme "OpenCV(Develop)" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath "build/" build 2>&1 | grep -E 'error:|BUILD (SUCCEEDED|FAILED)|\*\* BUILD' | head -20`
- Do NOT use `-destination 'generic/platform=iOS Simulator` with xcodebuild, always use `-destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath "build/"`
- Previews available via `RenderPreview`
- For unit tests, use `RunAllTests` or `RunSomeTests`


### Project Structure & Module Organization

- The SwiftUI MVVM app source lives in `OpenCV/`, organised by feature under `Modules/` (for example `Dashboard`, `Circle`, `Journal`).
- Shared services and utilities are in `Services/` and `Utils/`; keep reusable UI in `Modules/SharedViews`.
- Assets are managed via `Assets.xcassets`, while configuration files such as API endpoints belong in `Config/`.
- Unit and integration tests sit in `OpenCVTests/`, with UI flows in `OpenCVUITests/`.

### Coding Style & Naming Conventions

- Follow Swift 6.3 style with four-space indentation and descriptive `CamelCase` types.
- Think hard about preventing concurrency issues such as objects crossing actor boundaries and sendability issues.
- Group related views and models by feature inside the matching `Modules/Module` folder.
- Name SwiftUI views with the `*View` suffix, models with `*Model`, viewModels with `*ViewModel`, services with `*ServiceImpl` where the protocol is named `*Service`.
- Keep service protocols in `Services/` and concrete implementations in subfolders named for the dependency.
- Prefer `@MainActor` annotations for UI entry points. If SwiftLint is enabled, run `bundle exec fastlane lint` before pushing and address reported issues.
- Prefer using `FactoryKit` for dependency injection to simplify testing and improve modularity - it allows easy swapping of implementations and clean test setup.


### Anti-Patterns to Avoid

- Avoid passing `@State` or `@ObservedObject` across actor boundaries - causes Sendable warnings.
- Don't hardcode environment-specific values - use `BuildConfig.swift` and `.xcconfig` files.
- Never commit secrets, .env files, API keys, or certificates - use fastlane match and Keychain.
- Avoid massive ViewModels - split into smaller, focused components or extract business logic to services.
- Don't use force unwrapping (`!`) without clear justification - prefer optional chaining or guard statements.


### Testing Guidelines

- Verify code with unit tests for each module.
- Add feature tests under matching folders in `OpenCVTests/` using Apple's Swift Testing framework.
- Use `@Test` and `@Suite` macros from Swift Testing framework instead of XCTest where possible.
- Mirror file names with a `Tests` suffix (e.g., `LoginViewModel.swift` → `LoginViewModelTests.swift`).
- UI regressions should be covered in `OpenCVUITests/` with XCTest and `XCUIApplication`.
- Ensure fastlane test runs remain green and retain generated coverage reports in `fastlane/test_output/report.html` for review.
- When introducing async code, include expectation-based tests to avoid flaky behaviour.
- Run unit tests before pushing to verify no regressions.

### Debugging & Troubleshooting

- Use OSLog categories defined in `Utils/OSLog+Utils.swift` for structured logging.

## For Reviewing

### Pull Request Review Checklist

- Verify commit subjects follow present tense (e.g., `ADDS: inverter live chart data`) and stay under ~60 characters.
- Config updates in `Config/` need validation - ensure no secrets are committed and environment variables are correctly scoped.
- Check for proper error handling, especially around async/await and database operations.
- Verify new dependencies are necessary and approved - check `Package.resolved` changes.
- Ensure `@MainActor` annotations are present on UI entry points to prevent concurrency issues.

### What to Look For

- **Concurrency safety**: No data races, proper actor isolation, Sendable conformance where needed.
- **Test coverage**: New features have corresponding tests, edge cases covered.
- **Performance**: No obvious performance issues (N+1 queries, unnecessary re-renders).
- **Security**: No hardcoded secrets, proper Keychain usage, secure network calls.
- **Accessibility**: VoiceOver labels, Dynamic Type support, sufficient contrast ratios.
