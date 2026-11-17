<p align="center"><img src="docs/messup-git-header.jpeg" alt="Messup" width="100%"></p>

# Messup

Local-only iOS expense and income tracker built with SwiftUI and Liquid Glass. iOS 26+, no backend, no login, no third-party dependencies.

## Features

- Track expenses, income and savings-goal contributions.
- Week / month / year period picker with change vs the previous period **at the same day**, daily average, projection and category totals.
- Balance = income − expenses − contributions.
- Monthly and per-category budgets (warning from 80 %, flagged when over the limit).
- Up to 3 spending insights per period.
- User-selectable currency.
- CSV export.
- Data persisted on device with SwiftData.

## Requirements

- Xcode 16+ (Swift 6.2 toolchain)
- iOS 26.0 minimum
- Swift 6 language mode

## Getting started

```bash
git clone https://github.com/RafaSG13/ios-messup.git
cd ios-messup
open iOSMessup.xcodeproj
```

Run the `iOSMessup` scheme, or build from the CLI:

```bash
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup build
```

Debug builds auto-seed sample data when the store is empty. Launch arguments:

| Argument | Effect |
|---|---|
| `-messup_autoseed NO` | Disable auto-seeding (see the real empty state) |
| `-messup_environment mock` | Run on in-memory sample data; nothing is persisted |

## Tests

Swift Testing. Use the `iOSMessupTests` scheme (the `iOSMessup` scheme has no testables):

```bash
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessupTests test
```

## Architecture

Model-View, no ViewModels. Layers: Domain → Data → Presentation, plus Core infrastructure. Views read `@Observable`, protocol-based services injected through `@Entry` environment values; services persist through a SwiftData `LocalStore`.

| Path | Purpose |
|---|---|
| `iOSMessup/` | The app (Domain, Data, Presentation, Core) |
| `MUDesignSystem/` | Local SPM package with shared components and design tokens |
| `iOSMessupTests/` | Unit tests |

See [AGENTS.md](AGENTS.md) for architecture details and conventions, and [ROADMAP.md](ROADMAP.md) for open product items.
