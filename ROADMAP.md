# Roadmap: Modernize iOSMessup (Liquid Glass, local dev DB, adaptive layouts)

Goals, in the order the user gave them:
1. A **local, persistent, no-login app** on SwiftData – no backend, no auth (done in milestone 1).
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
| (historical, before milestone 1) `dev` = in-memory mocks with a login that accepted any credentials; data lost on relaunch. Now: `local` (SwiftData, default) and `mock` | `MUEnvironmentConfigurator.swift` |
| `SocialGroupsView` is a stub (`Text("These are my groups")`); Profile sub-screens are `Text(...)` placeholders | views |
| Legacy API in use: `NavigationView` (4 modals), `NavigationLink(destination:)`, `.foregroundColor`, `.cornerRadius`, `.tabItem`, `UIScreen.main` (`MUCustomVerticalForEach`), `.thinMaterial` field backgrounds | grep over `Presentation/` |
| Installed simulators: iPhone 17e/Air/17, iPad Pro/Air/mini/A16, **iPhone Duo**; runtimes iOS 18.4, 18.6, 27.0, 27.1 (no iOS 26.x runtime) | `simctl` |
| Verified present in SDK 27.1 swiftinterface: `glassEffect(_:in:)`, `GlassEffectContainer`, `glassEffectID`, `glassEffectUnion`, `glassEffectTransition`, `.glass` / `.glassProminent` button styles, `tabBarMinimizeBehavior`, `tabViewBottomAccessory`, `searchToolbarBehavior`, `scrollEdgeEffectStyle`, `backgroundExtensionEffect`, `ToolbarSpacer` | grep on `SwiftUI`/`SwiftUICore` interfaces |
| No public SwiftUI hinge/fold/"duo" API found in the SDK interfaces | grep on `SwiftUI.swiftinterface` |

## Decisions (change them here before starting if you disagree)
1. **Minimum iOS 26.0.** Liquid Glass APIs are iOS 26+; a lower floor means `#available` forks in every view. Test on the 27.x runtimes (no 26.x runtime installed; install one from Xcode ▸ Settings ▸ Components if 26.0-specific behavior matters).
2. **"iPhone Duo" = the `iPhone Duo` simulator device type** in Xcode 27.1. Because there is no hinge API, support it through size-class/width-adaptive layout, not device checks. Phase 5 measures its real geometry first.
3. **Local DB = SwiftData in all builds** (Debug and Release), no backend and no login. Domain stays plain `struct`s (project rule); `@Model` records map to/from them. Sample data is Debug-only.
4. **Adopt `MUDesignSystem` as a real dependency** of the app and delete the app's duplicate components (today the app does not import it). Alternative: delete the package. Recommended: adopt, because glass tokens/components then live in one place.
5. **Clean cutover, no shims**: each phase migrates every caller and deletes the old path.

---

## Phase 0 – Baseline and safety net
- [x] Build and run tests with Xcode 27.1 (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`). Results in "Baseline results" at the end of this file.
- [x] Run `iOSMessupTests` scheme; `ExpensesServiceTests` pass. `MUClientTests.swift` deleted together with the backend code.
- [x] Build `MUDesignSystem` (`swift build`): fails on the macOS host (`UITextContentType`); recorded, not fixed.
- [x] "Before" screenshots dropped (Landing view deleted; `simctl` cannot drive taps). Post-change screenshots are taken in later phases.

**Accept:** a recorded green/red baseline for app, tests and package. Met.

## Phase 1 – Local SwiftData store, no login (done)
Backend, auth, Keychain and the `keychain-swift` dependency were deleted; the app launches straight into the tab bar with a single implicit user.
- Environments: `local` (SwiftData in Application Support, default) and `mock` (in-memory mocks, `-messup_environment mock`).
- `Data/Local/`: `@Model` records `ExpenseRecord`, `DepositRecord`, `SavingGoalRecord`; `LocalStore` (file or in-memory).
- `ExpensesService` / `IncomeService` are SwiftData-backed (same protocols as the mocks).
- Debug only: `DebugSeeder`, Profile ▸ Debug section, launch arg `-messup_seed_sample_data YES`. First launch is empty.
- Tests: `iOSMessupTests/Local/` (in-memory stores, one on-disk relaunch test).

## Phase 2 – Refactor foundation (done)
- [x] Deployment target 26.0 at project level (iOS and macOS; per-target overrides removed); `MUDesignSystem/Package.swift` is `.iOS(.v26)`. The pbxproj was hand-edited (no Xcode GUI available in the CLI session); `xcodebuild -list` and all builds resolve it.
- [x] Concurrency: `SWIFT_APPROACHABLE_CONCURRENCY = YES` + `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` first (clean under Swift 5), then app/test/UI-test targets on Swift 6. Per-method `@MainActor` removed from services, `DebugSeeder`, `LocalStore` and tests; `async let` in `loadInitialData` replaced by sequential awaits (services are not `Sendable`).
- [x] Modern API sweep: `NavigationView`→`NavigationStack`, `foregroundColor`→`foregroundStyle`, `cornerRadius`→`clipShape(.rect(cornerRadius:))`, `NavigationLink(destination:)`→`NavigationLink(value:)` + `navigationDestination(for:)` (`Route`, private `ProfileRoute`), `.tabItem`→`Tab` (old `Tab` enum renamed `AppTab`), `UIScreen.main` gone (`onGeometryChange`), `autocapitalization` gone with the deleted `MUTextField`. The only `.cornerRadius(` left is `ChartContent.cornerRadius` on a `BarMark` (Charts API, no replacement). `MUCustomVerticalForEach` was kept (not replaced by `List`).
- [x] `MUDesignSystem` adopted as a local package dependency; app copies deleted. The package was trimmed to what the app uses: removed `MUTextField`, `MUPasswordField`, `MULoadingHudModifier` (no users after the login removal) and the broken showcase executable and placeholder test target. Package components are public and iOS-only (`xcodebuild -scheme MUDesignSystem`; `swift build` on macOS still fails by design). Fixes while moving: `CircularSavingProgressView` no longer freezes `progress` in `@State`; `MUCustomVerticalForEach` measures width with `onGeometryChange` instead of `UIScreen`/`GeometryReader`; `ListSectionHeaderView` takes a `Hashable` value instead of `AnyView`.
- [x] Errors visible: `ErrorAlertModifier` (`.errorAlert($error)`) on all add/edit/delete paths and on the initial load; modals dismiss only after a successful save. `TaskStore` (swallowed errors, unused after this) deleted.
- [x] Localization: `Localizable.xcstrings`, English base (no Spanish strings remained after the login removal). Other languages are not added yet (open question 2 below).
- [x] File headers fixed; `SavingsObjectiveView.swift` renamed to `IncomeObjectiveView.swift` to match its type; dead `HideTabBarAfterScrollingThreshold` deleted (Phase 3 still adds `.tabBarMinimizeBehavior`).
- Bugs found by reading and fixed on the way (not reproduced in the UI, since `simctl` cannot tap): the edit-expense modal built a new `Expense` with a fresh `id`, which `updateExpense` ignores as unknown; the "All" lists deleted by offsets into the unfiltered array while a search was active; toolbar "+" buttons had no accessibility label.

**Accept (met):** app + tests build with zero warnings at Swift 6 (clean build); legacy-symbol grep is empty apart from the Charts `cornerRadius` above; the app compiles with the package as the only source of the shared components.

## Phase 3 – Liquid Glass shell (done except the app icon)
Rebuilding with the new SDK already gives glass bars/sheets; the work was removing things that fight it and adding glass only on the controls layer.
- [x] Tab bar: `.tabBarMinimizeBehavior(.onScrollDown)` and `.tabViewStyle(.sidebarAdaptable)` (`Tab` API was already in place). `sidebarAdaptable` is only exercised on iPhone so far; iPad is Phase 5.
- [x] Chrome that fought glass removed: `.buttonStyle(.plain)` on toolbars (all screens), the `.ultraThinMaterial` label fill in `IncomeObjectiveView` (now `.quaternary`), and the hard-coded `.white` stop in the goal-summary gradient (it rendered a white band in dark mode; now `systemBackground`). There were no custom bar/sheet backgrounds.
- [x] Primary action: toolbar "+" is `.buttonStyle(.glassProminent)` on all four screens that have it. Modals use `.cancellationAction` / `.confirmationAction` with `Button(role: .cancel)` / `Button(role: .confirm)`, and the padding/`fixedSize` hacks are gone. No floating button / `tabViewBottomAccessory`: the toolbar action is enough until Phase 4 designs the dashboard.
- [x] Search: `.searchToolbarBehavior(.minimize)` on the All lists (expense search only exists there; the >3-character rule is unchanged).
- [x] Scroll edges: the default soft scroll-edge effect was checked in screenshots; `backgroundExtensionEffect` is not applied because no hero content sits at a scroll edge yet (revisit with the Phase 4 dashboard).
- [x] Rules written down in `AGENTS.md` (glass only on controls, never on cells; one `GlassEffectContainer` for neighbouring glass).
- [x] Accessibility, verified on iPhone 17 (iOS 27.0 simulator) in light and dark with Increase Contrast, Reduce Transparency (bars and the minimized tab bar become opaque) and `accessibility-extra-extra-large` type. Found and fixed: cells had a fixed 70 pt height (text clipped) → `minHeight` + vertical layout at accessibility sizes; chart annotations overlapped the bars → chart capped at `.xxxLarge`.
- [ ] **Not done:** new app icon via Icon Composer. It needs artwork and the Icon Composer GUI; `AppIcon.appiconset` is unchanged.

**Accept (met, except the icon):** screenshots in light/dark and Reduce Transparency on/off show no custom bar backgrounds; no `NavigationView`/`.thinMaterial` left. Screenshots were produced by a throwaway XCUITest (not committed, recipe in `AGENTS.md`). The same run exercised add → edit → delete of an expense through the UI (including swipe-to-delete in `MUCustomVerticalForEach`), which confirms the Phase 2 edit-modal fix.

**Carried to Phase 4:** the Income dashboard hero / circular progress and the section headers still do not reflow at accessibility sizes.

## Phase 4 – Screen redesign
Design tokens (spacing, radii, semantic colors, glass usage) are defined once in `MUDesignSystem`; screens consume them.

| Screen | Work |
|---|---|
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

## Phase 6 – Tests, QA, release
- [ ] Unit tests: domain sorting/filtering (service tests exist in `iOSMessupTests/Local/`). Follow existing Swift Testing style; `delay: 0` on mocks.
- [ ] UI smoke tests (target exists with no sources): launch with `-messup_environment local -messup_seed_sample_data YES`, add expense, verify list; run on iPhone and iPad.
- [ ] `performAccessibilityAudit()` in UI tests for main screens.
- [ ] CI: GitHub Actions running build + unit tests on a 27.x simulator (none exists today).
- [ ] Release checklist: privacy manifest, Release build has no debug code, icon, localization review, TestFlight.

## Risks
| Risk | Mitigation |
|---|---|
| Raising to iOS 26 drops older devices | Explicit decision #1; revisit only if distribution needs them |
| Glass over charts hurts legibility | Glass only on controls; test Reduce Transparency / Increase Contrast each phase |
| SwiftData store diverges from mock semantics | Mock and SwiftData services implement the same protocols; extend the shared contract tests to run against both |
| Swift 6 migration noise | Staged: Approachable Concurrency under Swift 5 first |
| No iOS 26.x simulator runtime | Test on 27.x; install a 26.x runtime if a 26-specific bug is suspected |

## Open questions
1. Build the Social groups feature, or hide the tab?
2. Keep Spanish, English, or both (String Catalog) as launch languages?
3. Confirm "iPhone Duo" means the simulator device above (and not another device/feature).

## Baseline results
Recorded before the local-only/SwiftData milestone (Xcode 27 toolchain, iPhone 17 simulator).

- `xcodebuild -scheme iOSMessup build`: **succeeded**, 14 distinct warnings (unstructured throwing `Task`s in `ExpensesView`/`AllDepositsView`/`SavingsObjectiveView`/`RegistrationView`, unused `refreshToken` in `AuthService`, `Combine` not imported in `LoadingScreen`).
- `xcodebuild -scheme iOSMessupTests test`: **succeeded**; all 9 `ExpensesServiceTests` pass.
- `cd MUDesignSystem && swift build` (macOS host): **fails** (`cannot find type 'UITextContentType' in scope` in `MUTextField`; the package is iOS-only and `swift build` targets macOS). `MUDesignSystemShowcase` not investigated. Not fixed.
- Landing-screen "before" screenshots not taken: the Landing view is deleted by this milestone and `simctl` cannot drive taps to reach tab screens.
