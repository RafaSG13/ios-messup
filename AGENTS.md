# Repository Guidelines

## Project Overview
iOS expense/income tracker (SwiftUI, iOS 17.5 target, Swift 5 language mode). Two independent code bases in one repo:
- `iOSMessup/` – the app (hand-managed `iOSMessup.xcodeproj`, Xcode 16+ synchronized folders; **no XcodeGen, no `project.yml`**).
- `MUDesignSystem/` – standalone SPM package (swift-tools 6.2, iOS 16). **The app does NOT import it**; the app keeps its own copies of `MUSpacer`, `MUTextField`, `ProgressBar`, `CircularSavingProgressView`, `MUCustomVerticalForEach`, `SelectableCell`, `MULoadingHudModifier` under `iOSMessup/Presentation/`. Changing one copy does not change the other.

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
- Write: views pass `onSubmit` closures through sheet modifiers (`Presentation/ViewModifiers/ExpenseSheetViewModifier.swift`: `addExpenseSheet`, `editExpenseSheet`; same for deposits) to `async throws` service methods; the service writes records through `LocalStore.context`, saves, then reloads its observable array (sorted by `date` ascending). Service methods that touch the store are `@MainActor`.
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
| `iOSMessup/Core/Utils` | `TaskStore` (`Task+Utils.swift`) |
| `iOSMessup/Core/Environment` | `MUEnvironmentConfigurator` (local/mock wiring) |
| `iOSMessup/Domain/Model`, `Domain/Status.swift` | Structs (`Expense`, `Deposit`, `SavingGoal`), view-state enum |
| `iOSMessup/Data/Local` | SwiftData: `LocalRecords` (`@Model`), `LocalStore`, `DebugSeeder` (Debug only) |
| `iOSMessup/Data/Services/<Feature>/` | Protocol, SwiftData-backed service, `Mock/Mock<X>Service.swift` |
| `iOSMessup/Presentation/{Views,Components,ViewModifiers,Navigation}` | UI by feature; reusable pieces |
| `iOSMessupTests/` | Unit tests (synchronized folder: new files are auto-included) |
| `MUDesignSystem/Sources/{MUDesignSystem,MUDesignSystemShowcase}` | Package + showcase executable |

## Development Commands
```bash
# App
open iOSMessup.xcodeproj
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup build
# Tests: use the iOSMessupTests scheme (the iOSMessup scheme has no Testables)
xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessupTests test
xcodebuild test -project iOSMessup.xcodeproj -scheme iOSMessupTests -only-testing:iOSMessupTests/ExpensesServiceTests/loadExpenses
# Design system
cd MUDesignSystem && swift build && swift test
```
No linter/formatter, Makefile, CI, or code generation exists. Edit the pbxproj only through Xcode; adding files under `iOSMessup/` or `iOSMessupTests/` needs no project edit.

## Code Conventions & Common Patterns
- 4-space indent, braces on same line, trailing closures, imports grouped (SwiftUI/Foundation first) and alphabetized.
- Types PascalCase, members camelCase. Protocols suffixed `Protocol`; mocks prefixed `Mock` in a `Mock/` subfolder next to the real service; `MU` prefix for infrastructure/components (`MUEnvironmentConfigurator`, `MUTextField`).
- Domain: structs, `Comparable`, `static var mock` / `mockArray` in an `extension` under `// MARK: - Mocks`. `PaymentMethod` and `Category` are top-level enums (with `icon`/`color`) in `Domain/Model/Expense.swift`.
- Services: `@Observable final class`; the real ones take `store: LocalStore`; mocks take `initialX`, `delay` (default 0.1s), `shouldFail`.
- Persistence changes: add/modify the `@Model` record and its mapping together with the domain struct; keep derived (sync) methods on the service reading only the observable arrays.
- Async in views: `TaskStore` (`Core/Utils/Task+Utils.swift`) with a private `enum TaskId` key – dedupes running work, `cancelAll()` in `.onDisappear`. It swallows errors (`try?`); surface errors inside the closure.
- Errors/state: `Domain/Status.swift` (`idle|loading|error(Error)`, equality ignores the wrapped error) is only written in `iOSMessupApp`, never read by views.
- Navigation: `Route` (`Presentation/Navigation/Route.swift`) exposes `destination` and is used by `ListSectionHeaderView` through `NavigationLink(destination:)`, not `navigationDestination(for:)`.
- Every SwiftUI view gets a `#Preview` using mocks. Use `// MARK: -` headers. Default access `private`.
- Gotchas: `filteredExpenses(on:)` returns everything for terms ≤3 chars (intentional); the "recent" lists in `ExpensesView`/`IncomeObjectiveView` are `@State` snapshots refreshed by `.onChange(of: service.expenses/deposits, initial: true)` because the store loads after the first appearance.

### Known defects (do not copy; fix only when asked)
- Several write paths drop errors (`AddExpenseViewModal`, `ExpensesView` onDelete).
- Many file header comments name the wrong file (template leftovers).

## Important Files
- `iOSMessup/iOSMessupApp.swift` – entry, DI root, Debug seeding hook
- `iOSMessup/Core/Environment/MUEnvironmentConfigurator.swift` – local/mock factories
- `iOSMessup/Data/Local/LocalStore.swift` – SwiftData container
- `iOSMessup/Data/Services/Expenses/ExpensesService.swift` – canonical real service + `@Entry`
- `iOSMessup/Data/Services/Expenses/Mock/MockExpensesService.swift` – canonical mock
- `iOSMessup/Presentation/Views/MainTabBarView.swift` – tab root
- `iOSMessup/Info.plist` (only calendar usage key), `iOSMessup/iOSMessup.entitlements` (empty dict), `MUDesignSystem/Package.swift`

## Runtime/Tooling Preferences
- Xcode 16+ (project `objectVersion 70`), Swift 6.2 toolchain for the package. App target: Swift 5 mode, iOS 17.5, team `FMHB2W3446`, bundle id `rafael.serrano.iOSMessup`. Package: Swift 6 language mode, iOS 16.
- Dependencies: none (Apple frameworks only; SwiftData for persistence).
- Debug conditions: `DEVELOPMENT DEBUG`; Release: `PRODUCTION`.
- `MUDesignSystemShowcase` likely does not compile (references nonexistent `MUDesignSystemSpacing`, uses internal types); verify with `swift build` before relying on it.

## Testing & QA
- Swift Testing (`import Testing`, `@Test`, `#expect`, `await #expect(throws:)`), `struct` suites, behavior-named tests, `@testable import iOSMessup`.
- Real coverage: `iOSMessupTests/Expense/ExpensesServiceTests.swift` (against `MockExpensesService`) and `iOSMessupTests/Local/` (SwiftData services on in-memory stores, one on-disk relaunch test, `DebugSeeder`). `MUDesignSystemTests` is a placeholder; `iOSMessupUITests` target has no sources.
- Pattern:
  ```swift
  @Test func addExpenseFailure() async throws {
      let service = MockExpensesService(initialExpenses: [], shouldFail: true)
      await #expect(throws: Error.self) { try await service.addExpense(Expense.mock) }
  }
  ```
- Pass `delay: 0` to keep tests fast. SwiftData service tests use a fresh `LocalStore(storage: .inMemory)` per test and are `@MainActor`. No coverage threshold configured.
