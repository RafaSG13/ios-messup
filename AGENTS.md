# Repository Guidelines

## Project Overview
iOS expense/income tracker (SwiftUI, iOS 26 minimum, Swift 6 language mode with default MainActor isolation + Approachable Concurrency). Two code bases in one repo:
- `iOSMessup/` – the app (hand-managed `iOSMessup.xcodeproj`, Xcode 16+ synchronized folders; **no XcodeGen, no `project.yml`**).
- `MUDesignSystem/` – local SPM package (swift-tools 6.2, iOS 26) that the app imports (`import MUDesignSystem`, local package reference in the pbxproj). It holds the shared components (`ListSectionHeaderView`, `MUCustomVerticalForEach`, `ProgressBar`, `CircularSavingProgressView`, `SelectableCell` + `selectableCell(_:)`) and tokens (`MUSpacer`, `Color.designSystem`). The app has no copies of them. Package strings are passed in by the caller (`LocalizedStringKey` parameters) so they are extracted into the app's catalog.

No backend, no login, no third-party dependencies. The app is local-only: one implicit user, data persisted on device with SwiftData (`Data/Local/`) in every build.

## Architecture & Data Flow
Model-View, no ViewModels. Layers: Domain → Data → Presentation, plus Core infrastructure.

```
iOSMessupApp (@main)  --@State services built by-->  MUEnvironmentConfigurator (local→SwiftData services, mock→Mock*)
  .environment(\.expenseService / \.incomeService)
    → MainTabBarView → Expenses / IncomeObjective / SocialGroups / Profile views
      → @Environment(\.xService) (protocol-typed) → service methods
        → ExpensesService / IncomeService (@Observable) → LocalStore (SwiftData ModelContainer) → ExpenseRecord / DepositRecord / SavingGoalRecord
```
- Read: views read `@Observable` service properties directly (`expenseService.expenses`); derived values (`filteredExpenses(on:)`, `getActualWeekExpenses()`, `lastExpenses(limit:)`) live on the service.
- Write: views pass `onSubmit` closures through sheet modifiers (`Presentation/ViewModifiers/ExpenseSheetViewModifier.swift`: `addExpenseSheet`, `editExpenseSheet`; same for deposits) to `async throws` service methods; the service writes records through `LocalStore.context`, saves, then reloads its observable array (sorted by `date` ascending). Everything is main-actor isolated by default (no per-method `@MainActor`).
- Persistence: `@Model` records (`Data/Local/LocalRecords.swift`) map to/from the domain structs (`init(_:)`, `domain`, `apply(_:)`; enums stored as raw strings). `LocalStore.shared` is the on-disk store (`Application Support/Messup.store`); `LocalStore(storage: .inMemory)` is for tests. There is only ever one saving goal.
- Environment switch: `UserDefaults "messup_environment"` = `"local"` (default, SwiftData) or `"mock"` (in-memory sample data, nothing persisted). Launch arg: `-messup_environment mock`.
- Debug only (`#if DEBUG`): `DebugSeeder` + Profile ▸ Debug section (replace with sample data / delete all data); launch arg `-messup_seed_sample_data YES` replaces the store content with the mock data at launch. First launch is otherwise empty.
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
| `iOSMessup/Domain/Model`, `Domain/Status.swift` | Structs (`Expense`, `Deposit`, `SavingGoal`), view-state enum |
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
- Navigation: `NavigationStack` per tab; value links `NavigationLink(value:)` + `.navigationDestination(for: Route.self)` (`Presentation/Navigation/Route.swift`; Profile has a private `ProfileRoute`). Tabs use `Tab(_:systemImage:value:)` with the `AppTab` enum. Placeholder Profile destinations are still `Text` (ROADMAP Phase 4).
- Liquid Glass: bars, sheets and the tab bar get glass from the system, so do not add bar/sheet backgrounds, `.buttonStyle(.plain)` on toolbar items, or `.thinMaterial`-style fills. Glass only on navigation/controls (toolbar primary action uses `.buttonStyle(.glassProminent)`; modals use `Button(role: .cancel)` in `.cancellationAction` and `Button(role: .confirm)` in `.confirmationAction`), never on content cells. Glass elements near each other go in one `GlassEffectContainer`. The tab bar minimizes on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`), lists use `.searchToolbarBehavior(.minimize)`. Never hard-code `.white`/`.black` in surfaces (use `Color(.systemBackground)` / semantic styles); cells must not use fixed heights (`minHeight`) and restack vertically at accessibility type sizes.
- Every SwiftUI view gets a `#Preview` using mocks. Use `// MARK: -` headers. Default access `private`.
- Gotchas: `filteredExpenses(on:)` returns everything for terms ≤3 chars (intentional); the "recent" lists in `ExpensesView`/`IncomeObjectiveView` are `@State` snapshots refreshed by `.onChange(of: service.expenses/deposits, initial: true)` because the store loads after the first appearance; the "All" lists delete by resolving the displayed (filtered) rows, not by offsets into the full array; edit modals must keep the original `id` (`updateExpense`/`updateDeposit` ignore unknown ids).

### Known defects (do not copy; fix only when asked)
- Hard-coded content: "In 122 days" in `IncomeObjectiveView`, a literal `$` in the `WeeklyExpensesView` annotations, Profile `Link`s pointing at `apple.com`.
- Accessibility sizes: the Income dashboard (hero, circular progress labels) and section header titles ("Transactions" hyphenates) are not reflowed for accessibility Dynamic Type; the weekly chart is capped at `.xxxLarge`. ROADMAP Phase 4.

## Important Files
- `iOSMessup/iOSMessupApp.swift` – entry, DI root, Debug seeding hook
- `iOSMessup/Core/Environment/MUEnvironmentConfigurator.swift` – local/mock factories
- `iOSMessup/Data/Local/LocalStore.swift` – SwiftData container
- `iOSMessup/Data/Services/Expenses/ExpensesService.swift` – canonical real service + `@Entry`
- `iOSMessup/Data/Services/Expenses/Mock/MockExpensesService.swift` – canonical mock
- `iOSMessup/Presentation/Views/MainTabBarView.swift` – tab root
- `iOSMessup/Info.plist` (only calendar usage key), `iOSMessup/iOSMessup.entitlements` (empty dict), `MUDesignSystem/Package.swift`

## Runtime/Tooling Preferences
- Xcode 16+ (project `objectVersion 70`), Swift 6.2 toolchain. App and test targets: Swift 6 mode, iOS/macOS 26.0 (set once at project level), `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`; team `FMHB2W3446`, bundle id `rafael.serrano.iOSMessup`. Package: Swift 6, iOS 26.
- Dependencies: none (Apple frameworks only; SwiftData for persistence).
- Debug conditions: `DEVELOPMENT DEBUG`; Release: `PRODUCTION`.
- Strings: build with `xcodebuild` does not update `Localizable.xcstrings`; Xcode's IDE build does. To refresh from the CLI, build Release and run `xcrun xcstringstool sync iOSMessup/Localizable.xcstrings --stringsdata <Release *.stringsdata>` (Release so Debug-only strings stay out).

## Testing & QA
- Swift Testing (`import Testing`, `@Test`, `#expect`, `await #expect(throws:)`), `struct` suites, behavior-named tests, `@testable import iOSMessup`.
- Real coverage: `iOSMessupTests/Expense/ExpensesServiceTests.swift` (against `MockExpensesService`) and `iOSMessupTests/Local/` (SwiftData services on in-memory stores, one on-disk relaunch test, `DebugSeeder`). The package has no tests; `iOSMessupUITests` target has no sources.
- UI taps: `simctl` cannot tap. To drive the app, temporarily add a `iOSMessupUITests` synchronized folder to the pbxproj (the target exists but has no folder) and a scheme with that testable, launch with `-messup_environment local -messup_seed_sample_data YES`, and write `app.screenshot().pngRepresentation` to `/tmp` from the test (simulator processes share the host filesystem). `xcodebuild` stalls ~10 min after the tests finish; kill it once `Test Suite … passed` appears. Accessibility settings: `xcrun simctl ui booted appearance|content_size|increase_contrast`; Reduce Transparency via `xcrun simctl spawn booted defaults write com.apple.Accessibility EnhancedBackgroundContrastEnabled -bool true` (relaunch the app). No UI test is committed.
- Pattern:
  ```swift
  @Test func addExpenseFailure() async throws {
      let service = MockExpensesService(initialExpenses: [], shouldFail: true)
      await #expect(throws: Error.self) { try await service.addExpense(Expense.mock) }
  }
  ```
- Pass `delay: 0` to keep tests fast. SwiftData service tests use a fresh `LocalStore(storage: .inMemory)` per test; the test target also defaults to MainActor isolation. No coverage threshold configured.
