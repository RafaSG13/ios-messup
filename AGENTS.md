# Repository Guidelines

## Project Overview
iOS expense/income tracker (SwiftUI, iOS 17.5 target, Swift 5 language mode). Two independent code bases in one repo:
- `iOSMessup/` – the app (hand-managed `iOSMessup.xcodeproj`, Xcode 16+ synchronized folders; **no XcodeGen, no `project.yml`**).
- `MUDesignSystem/` – standalone SPM package (swift-tools 6.2, iOS 16). **The app does NOT import it**; the app keeps its own copies of `MUSpacer`, `MUTextField`, `MUPasswordField`, `ProgressBar`, `CircularSavingProgressView`, `MUCustomVerticalForEach`, `SelectableCell`, `MULoadingHudModifier` under `iOSMessup/Presentation/`. Changing one copy does not change the other.

Backend: REST API, base URL hard-coded `http://localhost:3000` in `MUClient`. Only third-party dependency: `keychain-swift` 24.0.0 (used in `Core/Keychain/KeychainManager.swift`).

## Architecture & Data Flow
Model-View, no ViewModels. Layers: Domain → Data → Presentation, plus Core infrastructure.

```
iOSMessupApp (@main)  --@State services built by-->  MUEnvironmentConfigurator (dev→Mock*, pro→live)
  .environment(\.expenseService / \.incomeService / \.authService)
    → MainTabBarView → Expenses / IncomeObjective / SocialGroups / Profile views
      → @Environment(\.xService) (protocol-typed) → service methods
        → live service (@Observable) → MUClientProtocol.send(MURequest, as:) → MUClient (URLSession)
```
- Read: views read `@Observable` service properties directly (`expenseService.expenses`); derived values (`filteredExpenses(on:)`, `getActualWeekExpenses()`, `lastExpenses(limit:)`) live on the service.
- Write: views pass `onSubmit` closures through sheet modifiers (`Presentation/ViewModifiers/ExpenseSheetViewModifier.swift`: `addExpenseSheet`, `editExpenseSheet`; same for deposits) to `async throws` service methods; service mutates its array after API success.
- Auth: `AuthService.isAuthenticated` drives `.fullScreenCover(LandingView)` in `iOSMessupApp`; on change `resetAppServices()` rebuilds all services.
- Environment switch: `UserDefaults "messup_environment"` = `"dev"` (default, mocks) or `"pro"` (live). Set it before launch to hit the backend.
- DI: each service protocol file ends with
  ```swift
  extension EnvironmentValues { @Entry var authService: AuthServiceProtocol = MockAuthService() }
  ```
  Defaults are mocks so previews work with no injection. Exception: `ExpensesServiceProtocol` + its `@Entry` live in `ExpensesService.swift`, not a separate file.

## Key Directories
| Path | Purpose |
|---|---|
| `iOSMessup/Core/Network` | `MUClient`, `MUClientProtocol`, `Shared/` (`MURequest`, `HTTPMethod`, `TaskStore`), `Tokens/` |
| `iOSMessup/Core/Tokens`, `Core/Keychain` | `TokenStorageProtocol`, `KeyChainTokenStorage`, JWT decoding, KeychainSwift wrapper |
| `iOSMessup/Core/Environment` | `MUEnvironmentConfigurator` (dev/pro wiring) |
| `iOSMessup/Domain/Model`, `Domain/Error`, `Domain/Status.swift` | Structs (`Expense`, `Deposit`, `SavingGoal`, `User`), `AuthError`, view-state enum |
| `iOSMessup/Data/Requests`, `Data/Responses` | `MURequest` conformers (`<Verb><Noun>Request`), response DTOs |
| `iOSMessup/Data/Services/<Feature>/` | Protocol, live service, `Mock/Mock<X>Service.swift` |
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
- Types PascalCase, members camelCase. Protocols suffixed `Protocol`; mocks prefixed `Mock` in a `Mock/` subfolder next to the live service; `MU` prefix for infrastructure/components (`MUClient`, `MUTextField`).
- Domain: structs, `Comparable`, `static var mock` / `mockArray` in an `extension` under `// MARK: - Mocks`. `PaymentMethod` and `Category` are top-level enums (with `icon`/`color`) in `Domain/Model/Expense.swift`.
- Services: `@Observable final class`; live ones take `client: MUClientProtocol`; mocks take `initialX`, `delay` (default 0.1s), `shouldFail`. Protocol methods that mutate auth state are `@MainActor`.
- Network: add a `MURequest` struct in `Data/Requests/` (`path`, `method`, `body`, `headers`) and call `client.send(request, as: Response.self)`. `MUClient` retries once after refreshing on 401; errors surface as `NSError` with HTTP status as `code`.
- Async in views: `TaskStore` (`Core/Network/Shared/Task+Utils.swift`) with a private `enum TaskId` key – dedupes running work, `cancelAll()` in `.onDisappear`. It swallows errors (`try?`); surface errors inside the closure (see `LoginView`).
- Errors/state: `Domain/Status.swift` (`idle|loading|error(Error)`, equality ignores the wrapped error) is only written in `iOSMessupApp`, never read by views.
- Navigation: `Route` (`Presentation/Navigation/Route.swift`) exposes `destination` and is used by `ListSectionHeaderView` through `NavigationLink(destination:)`, not `navigationDestination(for:)`.
- Every SwiftUI view gets a `#Preview` using mocks. Use `// MARK: -` headers. Default access `private`.
- Gotchas: `filteredExpenses(on:)` returns everything for terms ≤3 chars (intentional); `delete(at:)` fires N requests (backend lacks bulk delete); `ExpensesView.lastExpenses` is a snapshot taken `.onAppear`.

### Known defects (do not copy; fix only when asked)
- Token split: `AuthService` saves tokens to Keychain (`KeyChainTokenStorage`), but `MUClient` reads/refreshes tokens from `UserDefaults` (`TokenKeys`), and sends `Authorization: "Bearer:<token>"` (colon) and `print`s it.
- Unused: `AppEnvironment`, `MUResponse`, `MUAPIError`, `TokenRefreshRequest`, `UserDataStore`, `KeychainStorage`, `ExpenseResponse`. `IncomeService` and `AuthService.refreshSession/resetPassword` are `Task.sleep` stubs with TODOs.
- `LoginView`/`RegistrationView` ship hard-coded default credentials; several write paths drop errors (`AddExpenseViewModal`, `RegistrationView`, `ExpensesView` onDelete).
- Many file header comments name the wrong file (template leftovers).

## Important Files
- `iOSMessup/iOSMessupApp.swift` – entry, DI root, `resetAppServices()`
- `iOSMessup/Core/Environment/MUEnvironmentConfigurator.swift` – dev/pro factories
- `iOSMessup/Core/Network/MUClient.swift` – HTTP, refresh logic
- `iOSMessup/Data/Services/Expenses/ExpensesService.swift` – canonical live service + `@Entry`
- `iOSMessup/Data/Services/Expenses/Mock/MockExpensesService.swift` – canonical mock
- `iOSMessup/Presentation/Views/MainTabBarView.swift` – tab root
- `iOSMessup/Info.plist` (only calendar usage key), `iOSMessup/iOSMessup.entitlements` (empty dict), `MUDesignSystem/Package.swift`

## Runtime/Tooling Preferences
- Xcode 16+ (project `objectVersion 70`), Swift 6.2 toolchain for the package. App target: Swift 5 mode, iOS 17.5, team `FMHB2W3446`, bundle id `rafael.serrano.iOSMessup`. Package: Swift 6 language mode, iOS 16.
- Dependencies via SPM only (no CocoaPods); networking is native `URLSession`.
- Debug conditions: `DEVELOPMENT DEBUG`; Release: `PRODUCTION`.
- `MUDesignSystemShowcase` likely does not compile (references nonexistent `MUDesignSystemSpacing`, uses internal types); verify with `swift build` before relying on it.

## Testing & QA
- Swift Testing (`import Testing`, `@Test`, `#expect`, `await #expect(throws:)`), `struct` suites, behavior-named tests, `@testable import iOSMessup`.
- Real coverage: only `iOSMessupTests/Expense/ExpensesServiceTests.swift` (against `MockExpensesService`). `iOSMessupTests/Network/MUClientTests.swift` is fully commented out; `iOSMessupTests/Income/` is empty; `MUDesignSystemTests` is a placeholder; `iOSMessupUITests` target has no sources.
- Pattern:
  ```swift
  @Test func addExpenseFailure() async throws {
      let service = MockExpensesService(initialExpenses: [], shouldFail: true)
      await #expect(throws: Error.self) { try await service.addExpense(Expense.mock) }
  }
  ```
- Pass `delay: 0` to keep tests fast. `MUClient` uses `URLSession.shared` (not injectable), so live-service tests need a `MUClientProtocol` fake. No coverage threshold configured.
