# Repository Guidelines

## Project Overview
iOS expense/income tracker (SwiftUI, iOS 27 minimum, Swift 6 language mode with default MainActor isolation + Approachable Concurrency). Two code bases in one repo:
- `iOSMessup/` – the app (hand-managed `iOSMessup.xcodeproj`, Xcode 16+ synchronized folders; **no XcodeGen, no `project.yml`**).
- `MUDesignSystem/` – local SPM package (swift-tools 6.2, iOS 27) that the app imports (`import MUDesignSystem`, local package reference in the pbxproj). It holds the shared components (`MUCard`, `MUIconTile`, `ListSectionHeaderView`, `ProgressBar`, `SelectableCell` + `selectableCell(_:)`) and tokens (`MUSpacer`, `MURadius`, `MUTypography`, `Color.designSystem`). The app has no copies of them. Package strings are passed in by the caller (`LocalizedStringKey` parameters) so they are extracted into the app's catalog.

No backend, no login, no third-party dependencies. The app is local-only: one implicit user, data persisted on device with SwiftData (`Data/Local/`) in every build.

## Architecture & Data Flow
Model-View, no ViewModels. Layers: Domain → Data → Presentation, plus Core infrastructure.

```
iOSMessupApp (@main)  --@State services built by-->  MUEnvironmentConfigurator (local→SwiftData services, mock→Mock*)
  .environment(\.expenseService / \.incomeService / \.savingsService / \.currencyCode)
    → MainTabBarView (Expenses / Income / Savings / Settings) → ExpensesView, IncomeView, SavingsView, SettingsView (+ All* lists, form sheets)
      → @Environment(\.xService) (protocol-typed) → service methods
        → ExpensesService / IncomeService / SavingsService (@Observable) → LocalStore (SwiftData ModelContainer) → ExpenseRecord / IncomeRecord / ContributionRecord / SavingGoalRecord
```
- Read: views read `@Observable` service properties directly (`expenseService.expenses`); derived values (`filteredExpenses(on:)`, `lastExpenses(limit:)`) live on the service.
- Write: views pass `onSubmit` closures through sheet modifiers (`Presentation/ViewModifiers/ExpenseSheetViewModifier.swift`: `addExpenseSheet`, `editExpenseSheet`; same for income, contributions and the goal) to `async throws` service methods; the service writes records through `LocalStore.context`, saves, then reloads its observable array (sorted by `date` ascending). Everything is main-actor isolated by default (no per-method `@MainActor`).
- Money model: `Income` is money in; the saving goal is funded only by explicit `Contribution`s (goal progress = sum of contributions, `SavingsService.progress()`); **balance = income − expenses − contributions**. `Domain/Period.swift` (week/month/year, previous/next) and `Domain/PeriodSummary.swift` (totals, change vs the previous period **at the same day** (`previousSpentToDate`, so a partial month is not compared with a full one), daily average, projection, category totals, cumulative series, balance) are pure and unit-tested; screens consume `PeriodSummary` instead of re-deriving numbers. The Expenses and Income screens share `Presentation/Components/PeriodPicker.swift` (state: `kind` + `anchor` date; next is disabled on the current period). `Domain/ExpenseInsights.swift` turns a summary into at most 3 `Insight`s. `Budget` (one monthly limit + optional per-category limits, `BudgetService`, `BudgetFormView` sheet from the Expenses summary card and Settings) yields `BudgetProgress` (ok / warning from 80 % / over); the budget row only applies to the month period.
- Persistence: `@Model` records (`Data/Local/LocalRecords.swift`) map to/from the domain structs (`init(_:)`, `domain`, `apply(_:)`; enums stored as raw strings). `LocalStore.shared` is the on-disk store (`Application Support/Messup.store`); `LocalStore(storage: .inMemory)` is for tests. There is only ever one saving goal.
- Environment switch: `UserDefaults "messup_environment"` = `"local"` (default, SwiftData) or `"mock"` (in-memory sample data, nothing persisted). Launch arg: `-messup_environment mock`.
- Debug only (`#if DEBUG`): sample data comes from `SampleDataGenerator` (~4 months, deterministic seed, relative to today; not the `mockArray`s, which are for previews/mock services). `DebugSeeder.seedOnLaunch` runs from `iOSMessupApp.init` for the `local` environment: an **empty store is auto-seeded** (toggle Settings ▸ Debug "Auto-seed when empty", or launch arg `-messup_autoseed NO` to see the real empty state); launch arg `-messup_seed_sample_data YES` forces a replace at every launch. Settings ▸ Debug also has "Replace with sample data" / "Delete all data" (after a delete, the next launch auto-seeds again unless the toggle is off). A Release build contains none of this. Extend the generator whenever a new model is added.
- Currency: the user picks it in Settings (`@AppStorage(AppCurrency.storageKey)`); `iOSMessupApp` injects it as `\.currencyCode`. Format amounts with `Double.formattedMoney(code:)` / `formattedCompactMoney(code:)` and type them with `.currency(code: currencyCode)`; never hard-code `$`/`USD`.
- Services container and App Intents: `Core/Environment/AppServices.swift` (`AppServices.shared`) holds the one set of services of the process; `iOSMessupApp` injects them and `AddExpenseIntent` (`Core/Intents/AddExpenseIntent.swift`, plus `MessupShortcuts` and the `AppEnum` conformances of `Category`/`PaymentMethod`) uses the same instances, so an expense added from Siri/Shortcuts appears in an open app. Intent `perform()`/helpers are `@MainActor` (the protocol requirements are nonisolated). New intents must go through `AppServices.shared`, not build their own services.
- Notifications: opt-in switches in Settings (`NotificationPreferences` keys, off by default; permission is requested when a switch is turned on). `NotificationServiceProtocol` (`Data/Services/Notifications/`, real `NotificationService`, `MockNotificationService` records calls). Budget alerts: pure `Domain/BudgetAlert.swift` (warning from 80 %, over above the limit, each level once per month) + `BudgetAlertChecker` (persists the delivered mark in `UserDefaults`); it runs from the `.budgetAlerts()` modifier on the tab root (expenses/budget changes) and from `AddExpenseIntent` (can run with no UI). `NotificationPresenter` (delegate set in `iOSMessupApp.init`) shows banners while the app is open. The weekly summary is a repeating Sunday 18:00 reminder with generic text (local notifications cannot compute numbers at delivery time).
- Apple Intelligence (on-device Foundation Models, nothing leaves the device): `IntelligenceServiceProtocol` (`Data/Services/Intelligence/`, real `IntelligenceService` on `SystemLanguageModel.default`, `MockIntelligenceService`), built by `MUEnvironmentConfigurator` and held by `AppServices`. Views show every AI control only when `intelligenceService.availability == .available`. Features: quick add from text / photo / scanned receipt and category suggestion in `ExpenseFormView` (add mode only; `categorySource` keeps a saved or user-picked category from being overwritten), "Summarize" in `ExpenseInsightsCard`, the "Ask Messup" chat (`Presentation/Views/Assistant/AssistantView.swift`, sheet from the Expenses toolbar) and the status row in Settings. `@Generable` types and `Tool`s (`GeneratedTypes.swift`, `Tools.swift`) are `nonisolated`; tools hold no data and read the services inside a `@MainActor` closure. `IntelligencePrompts` is pure (unit-tested): the model is given computed figures, never asked to calculate. Streams yield cumulative text. Errors go through `IntelligenceError.wrap` (`LanguageModelError`; `GenerationError` is deprecated). The simulator can report the model as available without being able to generate, so the live test (`LiveIntelligenceTests`) only runs on a device.
- DI: each service protocol file ends with
  ```swift
  extension EnvironmentValues { @Entry var incomeService: IncomeServiceProtocol = MockIncomeService() }
  ```
  Defaults are mocks so previews work with no injection. Exception: `ExpensesServiceProtocol` + its `@Entry` live in `ExpensesService.swift`, not a separate file.

## Key Directories
| Path | Purpose |
|---|---|
| `iOSMessup/Localizable.xcstrings` | String Catalog, base language English (no other languages yet) |
| `iOSMessup/Core/Environment` | `MUEnvironmentConfigurator` (local/mock wiring) |
| `iOSMessup/Domain/Model`, `Domain/Status.swift` | Structs (`Expense`, `Income`, `Contribution`, `SavingGoal`), view-state enum |
| `iOSMessup/Data/Local` | SwiftData: `LocalRecords` (`@Model`), `LocalStore`, `DebugSeeder` (Debug only) |
| `iOSMessup/Data/Services/<Feature>/` | Protocol, SwiftData-backed service, `Mock/Mock<X>Service.swift` |
| `iOSMessup/Presentation/{Views,Components,ViewModifiers,Navigation}` | UI by feature; reusable pieces |
| `iOSMessupTests/` | Unit tests (synchronized folder: new files are auto-included) |
| `MUDesignSystem/Sources/MUDesignSystem` | Design-system package (tokens, components, modifiers) |

## Development Commands
```bash
# App
open iOSMessup.xcodeproj
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup build
# Tests: use the iOSMessupTests scheme (the iOSMessup scheme has no Testables)
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessupTests test
xcodebuild test -project iOSMessup.xcodeproj -scheme iOSMessupTests -only-testing:iOSMessupTests/ExpensesServiceTests/loadExpenses
# Design system
xcodebuild -scheme MUDesignSystem -destination 'generic/platform=iOS Simulator' build   # run inside MUDesignSystem/; plain `swift build` targets macOS and fails (iOS-only package)
```
No linter/formatter, Makefile, CI, or code generation exists. Edit the pbxproj only through Xcode; adding files under `iOSMessup/` or `iOSMessupTests/` needs no project edit.

## Code Conventions & Common Patterns
- 4-space indent, braces on same line, trailing closures, imports grouped (SwiftUI/Foundation first) and alphabetized.
- Types PascalCase, members camelCase. Protocols suffixed `Protocol`; mocks prefixed `Mock` in a `Mock/` subfolder next to the real service; `MU` prefix for infrastructure/components (`MUEnvironmentConfigurator`, `MUSpacer`). File header names the file it is in.
- Domain: structs, `Comparable`, `static var mock` / `mockArray` in an `extension` under `// MARK: - Mocks`. `PaymentMethod` and `Category` are top-level enums (with `icon`/`color`) in `Domain/Model/Expense.swift`.
- Services: `@Observable final class`; the real ones take `store: LocalStore`; mocks take `initialX`, `delay` (default 0.1s), `shouldFail`.
- Persistence changes: add/modify the `@Model` record and its mapping together with the domain struct; keep derived (sync) methods on the service reading only the observable arrays.
- Async in views: plain `Task { do { try await service.x() } catch { self.error = error } }` with `@State private var error: (any Error)?` and `.errorAlert($error)` (`Presentation/ViewModifiers/ErrorAlertModifier.swift`). Add/edit modals `await` the submit, dismiss only on success and show the error otherwise.
- Load errors: `Status` (`Domain/Status.swift`) is set in `iOSMessupApp.loadInitialData()` and shown through `errorAlert`.
- Navigation: `NavigationStack` per tab; value links `NavigationLink(value:)` + `.navigationDestination(for: Route.self)` (`Presentation/Navigation/Route.swift`; Settings has a private `SettingsRoute`). Tabs use `Tab(_:systemImage:value:)` with the `AppTab` enum. There is no Social groups tab (decision: hidden until it has a data model) and no profile/user.
- Screens: dashboards (Expenses, Savings), the Income list and the All lists are `List(.insetGrouped)`: rows are plain content (`ExpenseCellView`/`IncomeCellView`/`ContributionCellView` have no own background), delete is `.swipeActions` on the resolved row, row tap opens the edit sheet, empty/no-results states are `ContentUnavailableView`. Charts/summaries live in `MUCard`s as full-width list rows. Buttons placed inside a list row (e.g. `PeriodPicker`'s chevrons) need `.buttonStyle(.borderless)` or the whole row acts as one button. Add/edit share one form per entity (`ExpenseFormView`, `IncomeFormView`, `ContributionFormView`, `SavingGoalFormView`, each with a `Mode`); edit presents via `.sheet(item:)`. Lists grouped by day use `groupedByDay(date:)` (`Domain/DaySection.swift`).
- Liquid Glass: bars, sheets and the tab bar get glass from the system, so do not add bar/sheet backgrounds, `.buttonStyle(.plain)` on toolbar items, or `.thinMaterial`-style fills. Glass only on navigation/controls (toolbar primary action uses `.buttonStyle(.glassProminent)`; modals use `Button(role: .cancel)` in `.cancellationAction` and `Button(role: .confirm)` in `.confirmationAction`), never on content cells. Glass elements near each other go in one `GlassEffectContainer`. The tab bar minimizes on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`), lists use `.searchToolbarBehavior(.minimize)`. Never hard-code `.white`/`.black` in surfaces (use `Color(.systemBackground)` / semantic styles); cells must not use fixed heights (`minHeight`) and restack vertically at accessibility type sizes.
- Brand: `AccentColor` is the mint of the app icon (teal 0/0.553/0.522 in light for contrast, mint 0.376/0.839/0.784 in dark), so tinted controls, `.glassProminent`, tab selection and `ProgressBar`'s default tint follow it; do not override with fixed colors. The icon palette is in `Color.designSystem` (`tangerine`, `sunYellow`, `bubblegum`, `deepBlue`, used by `Category.color`). The mascot (`logoPNG`) is deliberately rare: only the launch screen (`UILaunchScreen` in `Info.plist`, `mintAccent` background) and the Settings header (default profile image). Empty states keep SF Symbols.
- Color semantics: the mint accent is the only brand color and nothing in the UI is green. "Positive" gets no color (primary text plus a sign or arrow, e.g. `formattedSignedMoney`); progress and "ok" use the accent; `Color.designSystem.warning` (orange: budget from 80 %, spending above the previous period) and `.critical` (red: over a limit, negative balance) are only for states. Category/payment/income/goal palettes avoid green, mint, teal and cyan (some tones are shared on purpose). Amounts use `MUTypography` (SF Rounded, monospaced digits); icons in rows and cards are always `MUIconTile`.
- Every SwiftUI view gets a `#Preview` using mocks. Use `// MARK: -` headers. Default access `private`.
- Gotchas: `filteredExpenses(on:)`/`filteredIncomes(on:)` return everything for terms ≤3 chars (intentional); `lastExpenses(limit:)`/`lastIncomes(limit:)`/`lastContributions(limit:)` return the last N oldest-first, so screens reverse them to show newest first; the "All" lists delete by resolving the displayed (filtered) rows, not by offsets into the full array; edit forms must keep the original `id` (`update…` ignores unknown ids); deleting the saving goal keeps its contributions; `Settings.bundle` no longer exists (the environment is only selected by launch argument/UserDefaults); the SwiftData store opens older schemas with automatic lightweight migration (removed entities lose their data).

### Known defects (do not copy; fix only when asked)
- None recorded. Open product items live in `ROADMAP.md`.

## Important Files
- `iOSMessup/iOSMessupApp.swift` – entry, DI root, Debug seeding hook
- `iOSMessup/Core/Environment/MUEnvironmentConfigurator.swift` – local/mock factories
- `iOSMessup/Data/Local/LocalStore.swift` – SwiftData container
- `iOSMessup/Data/Services/Expenses/ExpensesService.swift` – canonical real service + `@Entry`
- `iOSMessup/Data/Services/Expenses/Mock/MockExpensesService.swift` – canonical mock
- `iOSMessup/Presentation/Views/MainTabBarView.swift` – tab root
- `iOSMessup/Info.plist` (calendar usage key + `UILaunchScreen`), `iOSMessup/iOSMessup.entitlements` (empty dict), `MUDesignSystem/Package.swift`

## Runtime/Tooling Preferences
- Xcode 16+ (project `objectVersion 70`; the Foundation Models work needs the Xcode 27 SDK), Swift 6.2 toolchain. App and test targets: Swift 6 mode, iOS/macOS 27.0 (set once at project level), `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`; team `FMHB2W3446`, bundle id `rafael.serrano.iOSMessup`. Package: Swift 6, iOS 27. `xcodebuild` destinations must use the simulator `id=` (a `name=…` specifier can match a paired physical device).
- Dependencies: none (Apple frameworks only; SwiftData for persistence).
- Debug conditions: `DEVELOPMENT DEBUG`; Release: `PRODUCTION`.
- Strings: build with `xcodebuild` does not update `Localizable.xcstrings`; Xcode's IDE build does. To refresh from the CLI, build Release and run `xcrun xcstringstool sync iOSMessup/Localizable.xcstrings --stringsdata <Release *.stringsdata>` (Release so Debug-only strings stay out).

## Testing & QA
- Swift Testing (`import Testing`, `@Test`, `#expect`, `await #expect(throws:)`), `struct` suites, behavior-named tests, `@testable import iOSMessup`.
- Real coverage: `iOSMessupTests/Expense/` (`ExpensesServiceTests` against `MockExpensesService`, `ExpenseAnalyticsTests`), `iOSMessupTests/Local/` (SwiftData services on in-memory stores, one on-disk relaunch test, `DebugSeeder`, `SampleDataGenerator`, `BudgetServiceLocalTests`), `iOSMessupTests/Income/` (`SavingGoalProgressTests`), `iOSMessupTests/Domain/` (`DaySectionTests`, `PeriodTests`, `PeriodSummaryTests`, `BudgetProgressTests`, `ExpenseInsightsTests`), `iOSMessupTests/Export/` (`CSVExporterTests`). The package has no tests; `iOSMessupUITests` target has no sources.
- Intelligence tests: `iOSMessupTests/Intelligence/` (`ExpenseDraftMappingTests`, `IntelligencePromptsTests`, `LiveIntelligenceTests` skipped on the simulator).
- UI taps: `simctl` cannot tap. To drive the app, temporarily add a `iOSMessupUITests` synchronized folder to the pbxproj (the target exists but has no folder) and a scheme with that testable, launch with `-messup_environment local -messup_seed_sample_data YES`, and write `app.screenshot().pngRepresentation` to `/tmp` from the test (simulator processes share the host filesystem). `xcodebuild` stalls ~10 min after the tests finish; kill it once `Test Suite … passed` appears. Accessibility settings: `xcrun simctl ui booted appearance|content_size|increase_contrast`; Reduce Transparency via `xcrun simctl spawn booted defaults write com.apple.Accessibility EnhancedBackgroundContrastEnabled -bool true` (relaunch the app). No UI test is committed.
- Pattern:
  ```swift
  @Test func addExpenseFailure() async throws {
      let service = MockExpensesService(initialExpenses: [], shouldFail: true)
      await #expect(throws: Error.self) { try await service.addExpense(Expense.mock) }
  }
  ```
- Pass `delay: 0` to keep tests fast. SwiftData service tests use a fresh `LocalStore(storage: .inMemory)` per test; the test target also defaults to MainActor isolation. No coverage threshold configured.
