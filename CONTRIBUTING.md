# Contributing to Messup

## Setup
- Xcode 27 or later (iOS 27 SDK) and an iOS 27.0+ simulator.
- `git clone https://github.com/RafaSG13/ios-messup.git`, then `open iOSMessup.xcodeproj`.
- No third-party dependencies to install.

## Workflow
1. Branch from `main` (`feature/<topic>`, `fix/<topic>`, `docs/<topic>`).
2. One topic per pull request.
3. Open the PR and fill in the template (summary, changes, screenshots for UI changes in light and dark, checklist).

## Build & test
Get simulator ids with `xcrun simctl list devices available` and use `id=` destinations.

```bash
# App
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup -destination 'id=<simulator-id>' build

# Tests (the iOSMessup scheme has no testables)
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessupTests -destination 'id=<simulator-id>' test

# Design system package
cd MUDesignSystem && xcodebuild -scheme MUDesignSystem -destination 'generic/platform=iOS Simulator' build
```

`swift build` does not work for `MUDesignSystem`: the package is iOS-only.

## CI
`.github/workflows/ci.yml` runs on every pull request and on `main`: SwiftLint (`swiftlint lint --strict`, config in `.swiftlint.yml`; `brew install swiftlint` to run it locally), the design-system package build, the `iOSMessupTests` suite with code coverage (report in the job summary, `.xcresult` attached as an artifact). There is no coverage threshold yet.

## Conventions
[`AGENTS.md`](AGENTS.md) is the single source for architecture and conventions. The hard rules:

- No third-party dependencies.
- No ViewModels: views read `@Observable` services from the environment.
- Every view has a `#Preview` that uses mocks.
- New logic gets Swift Testing tests.
- Never hard-code a currency; format with `formattedMoney(code:)` and use the `\.currencyCode` environment value.
- User-facing strings live in `Localizable.xcstrings`.
- Edit `project.pbxproj` only through Xcode. Files added under `iOSMessup/` or `iOSMessupTests/` need no project edit.
