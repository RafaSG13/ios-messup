# Roadmap: Modernize iOSMessup (Liquid Glass, local dev DB, adaptive layouts)

Goals, in the order the user gave them:
1. A **local, persistent debug database with login in dev mode** – no backend required.
2. **Refactor** the old codebase onto current SwiftUI/Swift APIs.
3. **Redesign** with Liquid Glass.
4. **Support every form factor**: iPhone (incl. Air), iPad, and the **iPhone Duo** simulator device.

Phases are ordered by dependency. Each ends with acceptance checks that must pass before the next starts. Update `AGENTS.md` at the end of every phase (several of its statements become false as work lands).

## Baseline (verified in this repo, Xcode 27.1 / iOS SDK 27.1)

| Fact | Source |
|---|---|
| 79 Swift files in app; ~1.2k lines in `Presentation/Views` | `find` / `wc` |
| Deployment target: project 17.0, targets 17.5; Swift 5 mode; device family iPhone+iPad | `project.pbxproj` |
| iPhone is **portrait only**; iPad all orientations | `INFOPLIST_KEY_UISupportedInterfaceOrientations*` |
| `dev` = in-memory mocks: `MockAuthService.login` accepts any credentials, data is lost on relaunch | `MockAuthenticationService.swift`, `MUEnvironmentConfigurator.swift` |
| `SocialGroupsView` is a stub (`Text("These are my groups")`); Profile sub-screens are `Text(...)` placeholders | views |
| Legacy API in use: `NavigationView` (4 modals), `NavigationLink(destination:)`, `.foregroundColor`, `.cornerRadius`, `.tabItem`, `UIScreen.main` (`MUCustomVerticalForEach`), `.thinMaterial` field backgrounds | grep over `Presentation/` |
| Installed simulators: iPhone 17e/Air/17, iPad Pro/Air/mini/A16, **iPhone Duo**; runtimes iOS 18.4, 18.6, 27.0, 27.1 (no iOS 26.x runtime) | `simctl` |
| Verified present in SDK 27.1 swiftinterface: `glassEffect(_:in:)`, `GlassEffectContainer`, `glassEffectID`, `glassEffectUnion`, `glassEffectTransition`, `.glass` / `.glassProminent` button styles, `tabBarMinimizeBehavior`, `tabViewBottomAccessory`, `searchToolbarBehavior`, `scrollEdgeEffectStyle`, `backgroundExtensionEffect`, `ToolbarSpacer` | grep on `SwiftUI`/`SwiftUICore` interfaces |
| No public SwiftUI hinge/fold/"duo" API found in the SDK interfaces | grep on `SwiftUI.swiftinterface` |

## Decisions (change them here before starting if you disagree)
1. **Minimum iOS 26.0.** Liquid Glass APIs are iOS 26+; a lower floor means `#available` forks in every view. Test on the 27.x runtimes (no 26.x runtime installed; install one from Xcode ▸ Settings ▸ Components if 26.0-specific behavior matters).
2. **"iPhone Duo" = the `iPhone Duo` simulator device type** in Xcode 27.1. Because there is no hinge API, support it through size-class/width-adaptive layout, not device checks. Phase 5 measures its real geometry first.
3. **Local DB = SwiftData**, `DEBUG` builds only. Domain stays plain `struct`s (project rule); `@Model` records map to/from them.
4. **Adopt `MUDesignSystem` as a real dependency** of the app and delete the app's duplicate components (today the app does not import it). Alternative: delete the package. Recommended: adopt, because glass tokens/components then live in one place.
5. **Clean cutover, no shims**: each phase migrates every caller and deletes the old path.

---

## Phase 0 – Baseline and safety net
- [ ] Build and run tests with Xcode 27.1 (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`; `xcode-select` currently points to the Xcode app, but the CLT SDK path error seen with bare `xcodebuild -version` means CI/scripts should set it explicitly). Record warnings.
- [ ] Run `iOSMessupTests` scheme; confirm `ExpensesServiceTests` pass. Delete the fully commented-out `MUClientTests.swift` (re-created in Phase 6).
- [ ] Build `MUDesignSystem` (`swift build`); record whether `MUDesignSystemShowcase` compiles (earlier static read says it does not).
- [ ] Capture "before" screenshots of every screen on iPhone 17 and iPad Pro 11 for later comparison.

**Accept:** a recorded green/red baseline for app, tests and package.

## Phase 1 – Local debug database + login (no backend)
Today `dev` is not a database: any credentials log in and nothing persists.

**Design**
- Environments become `mock` (previews/tests, in-memory, deterministic), `local` (SwiftData, default in Debug), `pro` (backend). `MUEnvironmentConfigurator` gains `local`; rename the old `dev`. Select via the `messup_environment` default or the launch argument `-messup_environment local|pro|mock` (launch arguments populate `UserDefaults`).
- `Data/Local/`: `@Model` records `UserRecord`, `ExpenseRecord`, `DepositRecord`, `SavingGoalRecord`; one `ModelContainer` in Application Support (in-memory variant for tests).
- `LocalAuthService: AuthServiceProtocol` – validates email/password against `UserRecord` (salted hash via CryptoKit), persists the active user id so relaunch stays logged in, `logout()` clears it, `register` inserts a user. Wrong password throws `AuthError`.
- `LocalExpensesService`, `LocalIncomeService` conform to the existing protocols; mutate the store, then refresh the observable array (same contract as live services).
- `DebugSeeder`: if the store is empty, seed a debug user (e.g. `debug@messup.dev` / `debug1234`) plus data from `Expense.mockArray`, `Deposit.mockArray`, `SavingGoal.mock`.
- UI (all under `#if DEBUG`): "Continue as debug user" on `LandingView`/`LoginView`; Profile ▸ Debug section with *Reset database*, *Reseed*, *Active environment*. **Remove the hard-coded default credentials** currently baked into `LoginView`/`RegistrationView`.
- Everything under `Data/Local/` and the debug UI is compiled out of Release.

**Accept**
- Backend off, airplane mode: launch → "Continue as debug user" → add an expense → kill app → relaunch: still logged in, expense present.
- Logout → login with debug credentials works; wrong password shows an error.
- In-memory `ModelContainer` tests cover: login ok/fail, register duplicate email, CRUD persistence, seed-once.
- Release build contains no debug credential string (`strings` on the Release binary).

## Phase 2 – Refactor foundation
Order matters: do toolchain/dead code first so later phases touch less.
- [ ] Raise deployment target to 26.0 (project level 17.0 and targets 17.5 → one value; **change in Xcode, not by hand-editing the pbxproj**). Same for `MUDesignSystem/Package.swift` (`.iOS(.v26)`).
- [ ] Concurrency: enable Approachable Concurrency / default MainActor isolation under Swift 5 first, fix diagnostics, then move the app target to Swift 6 language mode. Services are `@Observable` UI-state holders → `@MainActor`; drop per-method `@MainActor` on protocols.
- [ ] Delete dead code after confirming zero references with `xd://lsp`: `AppEnvironment`, `MUResponse`, `MUAPIError`, `TokenRefreshRequest`, `UserDataStore`, `KeychainStorage`, `ExpenseResponse`.
- [ ] Modern API sweep (mechanical, grep-driven): `NavigationView`→`NavigationStack`; `foregroundColor`→`foregroundStyle`; `cornerRadius`→`clipShape(.rect(cornerRadius:))`; `NavigationLink(destination:)`→`NavigationLink(value:)` + `navigationDestination(for: Route.self)`, one `NavigationStack` with a path per tab; `.tabItem`→`Tab`; `UIScreen.main` removed (replace `MUCustomVerticalForEach` with `List` + `.swipeActions`, or `onGeometryChange` if the custom gesture is kept); `autocapitalization`→`textInputAutocapitalization`.
- [ ] Adopt `MUDesignSystem`: add as local package dependency, delete the app's copies (`MUSpacer`, `MUTextField`, `MUPasswordField`, `ProgressBar`, `CircularSavingProgressView`, `MUCustomVerticalForEach`, `SelectableCell`, `MULoadingHudModifier`), fix/remove the broken showcase.
- [ ] Make errors visible: views currently never read `Status`; several write paths swallow errors (`AddExpenseViewModal`, `RegistrationView`, `ExpensesView` onDelete). Surface via alert/inline state.
- [ ] Localization: UI mixes English and Spanish ("Iniciar Sesión" vs "Login"). Move strings to a String Catalog; pick base language.
- [ ] Fix stale file headers.

**Accept:** app + tests build with zero warnings at Swift 6; `grep` for the legacy symbols above returns nothing in `iOSMessup/`; the app compiles with the design-system package as the only source of the shared components.

## Phase 3 – Liquid Glass shell
Rebuilding with the new SDK already gives glass bars/sheets; the work is removing things that fight it and adding glass only on the controls layer.
- [ ] Delete custom chrome: `HideTabBarAfterScrollingThreshold` → `.tabBarMinimizeBehavior(.onScrollDown)`; remove custom sheet/toolbar backgrounds and `.thinMaterial` field fills.
- [ ] `TabView` with `Tab` API; on iPad/wide windows `.tabViewStyle(.sidebarAdaptable)`. Drop the `resettable` helper if `Tab` selection handling covers re-tap-to-root; otherwise keep it, ported.
- [ ] Primary action ("add expense/deposit") as a glass control: `.buttonStyle(.glassProminent)` in the toolbar, or a floating button inside a `GlassEffectContainer`; consider `tabViewBottomAccessory` for the quick-add.
- [ ] Search: `.searchable` + `searchToolbarBehavior` for expenses (keep the >3-character filter rule documented in `AGENTS.md`).
- [ ] Scroll edges: `scrollEdgeEffectStyle` / `backgroundExtensionEffect` on hero content (dashboard header).
- [ ] Rules enforced in review: glass only on navigation/controls, **never on content cells** (cells use plain surfaces); glass elements near each other go in one `GlassEffectContainer`; use `glassEffectID` + namespace for morphs.
- [ ] Accessibility: verify with *Reduce Transparency*, *Increase Contrast*, Dynamic Type XXL; glass over colorful charts must stay legible.
- [ ] New app icon via Icon Composer (layered glass icon) replacing `AppIcon.appiconset`.

**Accept:** screenshots on iPhone 17 (light/dark, Reduce Transparency on/off) show no custom bar backgrounds; no `NavigationView`/`.thinMaterial` left.

## Phase 4 – Screen redesign
Design tokens (spacing, radii, semantic colors, glass usage) are defined once in `MUDesignSystem`; screens consume them.

| Screen | Work |
|---|---|
| Landing / Login / Registration | Glass primary button, system `TextField` styling, autofill content types, inline validation, debug entry (Phase 1) |
| Expenses | Dashboard: weekly chart + category chart (Swift Charts) in cards, recent list, search, add/edit sheets as `NavigationStack` forms with glass toolbar buttons |
| All expenses / All deposits | Sections by day, swipe actions, empty states (`ContentUnavailableView`) |
| Income / Savings objective | Redesign progress (ring + bar) with tokens; goal editing |
| Social groups | Currently a stub. **Decision needed:** build it (requires backend/data model) or hide the tab until built |
| Profile | Replace `Text(...)` placeholder destinations (Export, Categories, Currency, Password, Subscriptions) with real screens or remove the rows |
| Add/Edit modals | Unify Expense/Deposit add+edit into shared form components (4 near-duplicate modals today) |

**Accept:** every screen has `#Preview`s for mock data, empty state and error state; no placeholder `Text` destinations remain.

## Phase 5 – Adaptive layouts: iPhone, iPad, iPhone Duo
- [ ] **Measure first**: boot `iPhone Duo`, record window size, size classes, safe areas and orientations the sim offers; write results here. Do not assume a fold/hinge API (none found in SDK 27.1).
- [ ] Lift iPhone portrait-only restriction (`INFOPLIST_KEY_UISupportedInterfaceOrientations`) → allow landscape.
- [ ] Width-driven layout, never device checks: `NavigationSplitView` (sidebar/list/detail) in regular width, `NavigationStack` in compact; `ViewThatFits`, `containerRelativeFrame`, `onGeometryChange` for charts/grids (adaptive `LazyVGrid` columns).
- [ ] Dashboard: single column compact → two-column (chart | list) wide. Forms: sheet compact, popover/centered regular.
- [ ] Multitasking: resize window in Split View / Stage Manager on iPad; no layout jumps, no `UIScreen` use (removed in Phase 2).
- [ ] Keyboard/pointer: hardware keyboard shortcuts for add (⌘N), search (⌘F), hover effects on rows.

**Test matrix (screenshot each, both orientations, light/dark):**

| Device | Purpose |
|---|---|
| iPhone 17e | smallest current iPhone |
| iPhone Air | thin form factor, large screen |
| iPhone Duo | wide/dual-pane layout |
| iPad mini (A17 Pro), iPad Pro 13 | compact→regular transitions, split view |

**Accept:** no clipped/overlapping content on any matrix device; resizing an iPad window through compact↔regular preserves state.

## Phase 6 – Live backend hardening (`pro` environment)
Needs the backend API contract, which is **not in this repo**. Do not change wire formats without it.
- [ ] Resolve the **token split**: `AuthService` writes tokens to Keychain, `MUClient` reads/refreshes from `UserDefaults` (`TokenKeys`). Make Keychain the single store, `MUClient` takes `TokenStorageProtocol`.
- [ ] `Authorization: "Bearer:<token>"` (colon) looks wrong; confirm against the backend before changing. Remove the `print` of the token.
- [ ] `MUClient`: injectable `URLSession` and base URL (per-environment xcconfig, not hard-coded `localhost:3000`); typed errors instead of `NSError`.
- [ ] Implement real `IncomeService` and `AuthService.refreshSession/resetPassword` (currently `Task.sleep` stubs).
- [ ] Batch delete: use bulk endpoint if/when backend adds one.
- [ ] Re-create `MUClientTests` with a `URLProtocol` stub (401→refresh→retry, refresh failure → logout).

**Accept:** login, CRUD and refresh flow pass against a running backend and against the `URLProtocol` stub.

## Phase 7 – Tests, QA, release
- [ ] Unit tests: Local services (Phase 1), `MUClient` (Phase 6), domain sorting/filtering. Follow existing Swift Testing style; `delay: 0` on mocks.
- [ ] UI smoke tests (target exists with no sources): launch with `-messup_environment local`, debug login, add expense, verify list; run on iPhone and iPad.
- [ ] `performAccessibilityAudit()` in UI tests for main screens.
- [ ] CI: GitHub Actions running build + unit tests on a 27.x simulator (none exists today).
- [ ] Release checklist: privacy manifest, Release build has no debug code, icon, localization review, TestFlight.

## Risks
| Risk | Mitigation |
|---|---|
| Raising to iOS 26 drops older devices | Explicit decision #1; revisit only if distribution needs them |
| Glass over charts hurts legibility | Glass only on controls; test Reduce Transparency / Increase Contrast each phase |
| SwiftData in Debug diverges from live API semantics | Local services implement the same protocols; shared contract tests run against Mock, Local, and (later) live |
| Swift 6 migration noise | Staged: Approachable Concurrency under Swift 5 first |
| No iOS 26.x simulator runtime | Test on 27.x; install a 26.x runtime if a 26-specific bug is suspected |
| Backend contract unknown | Phase 6 is blocked on the API spec; Phases 1–5 do not depend on it |

## Open questions
1. Build the Social groups feature, or hide the tab?
2. Keep Spanish, English, or both (String Catalog) as launch languages?
3. Confirm "iPhone Duo" means the simulator device above (and not another device/feature).
