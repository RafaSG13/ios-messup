# Roadmap: iOSMessup (local app, Liquid Glass, useful insights, adaptive layouts)

Goals, in the order the user gave them:
1. A **local, persistent, no-login app** on SwiftData – no backend, no auth (done in milestone 1).
2. **Refactor** the old codebase onto current SwiftUI/Swift APIs.
3. **Redesign** with Liquid Glass.
4. **Support every form factor**: iPhone (incl. Air), iPad, and the **iPhone Duo** simulator device.
5. **Make the app useful** (added after Phase 4): it recorded data but answered nothing. Budgets, monthly balance, insights and fast capture come before the adaptive-layout work, because they change what the screens contain.

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
2. **"iPhone Duo" = the `iPhone Duo` simulator device type** in Xcode 27.1. Because there is no hinge API, support it through size-class/width-adaptive layout, not device checks. Phase 7 measures its real geometry first.
3. **Local DB = SwiftData in all builds** (Debug and Release), no backend and no login. Domain stays plain `struct`s (project rule); `@Model` records map to/from them. Sample data is Debug-only.
4. **Adopt `MUDesignSystem` as a real dependency** of the app and delete the app's duplicate components (today the app does not import it). Alternative: delete the package. Recommended: adopt, because glass tokens/components then live in one place.
5. **Clean cutover, no shims**: each phase migrates every caller and deletes the old path.
6. **Deposits become general income; contributions reduce the balance** (decided). Money in is "Income"; the saving goal is funded by explicit contributions, not by summing every deposit. **Balance = income − expenses − contributions** (what is left to spend); the balance card also shows income, expenses and "Saved" so the split stays visible.
7. **Recurring expenses / "upcoming payments" are parked** (decided): they only make sense once the user declares recurrences, and the manual-entry question the app answers is "how am I doing this month?". Revisit if users re-enter the same expenses every month.
8. **Each phase ships its own tests** (pure logic in Swift Testing) and previews; Phase 9 only adds the cross-cutting UI tests, CI and release work.

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
- [x] Tab bar: `.tabBarMinimizeBehavior(.onScrollDown)` and `.tabViewStyle(.sidebarAdaptable)` (`Tab` API was already in place). `sidebarAdaptable` is only exercised on iPhone so far; iPad is Phase 7.
- [x] Chrome that fought glass removed: `.buttonStyle(.plain)` on toolbars (all screens), the `.ultraThinMaterial` label fill in `IncomeObjectiveView` (now `.quaternary`), and the hard-coded `.white` stop in the goal-summary gradient (it rendered a white band in dark mode; now `systemBackground`). There were no custom bar/sheet backgrounds.
- [x] Primary action: toolbar "+" is `.buttonStyle(.glassProminent)` on all four screens that have it. Modals use `.cancellationAction` / `.confirmationAction` with `Button(role: .cancel)` / `Button(role: .confirm)`, and the padding/`fixedSize` hacks are gone. No floating button / `tabViewBottomAccessory`: the toolbar action is enough until Phase 4 designs the dashboard.
- [x] Search: `.searchToolbarBehavior(.minimize)` on the All lists (expense search only exists there; the >3-character rule is unchanged).
- [x] Scroll edges: the default soft scroll-edge effect was checked in screenshots; `backgroundExtensionEffect` is not applied because no hero content sits at a scroll edge yet (revisit with the Phase 4 dashboard).
- [x] Rules written down in `AGENTS.md` (glass only on controls, never on cells; one `GlassEffectContainer` for neighbouring glass).
- [x] Accessibility, verified on iPhone 17 (iOS 27.0 simulator) in light and dark with Increase Contrast, Reduce Transparency (bars and the minimized tab bar become opaque) and `accessibility-extra-extra-large` type. Found and fixed: cells had a fixed 70 pt height (text clipped) → `minHeight` + vertical layout at accessibility sizes; chart annotations overlapped the bars → chart capped at `.xxxLarge`.
- [ ] **Not done:** new app icon via Icon Composer. It needs artwork and the Icon Composer GUI; `AppIcon.appiconset` is unchanged.

**Accept (met, except the icon):** screenshots in light/dark and Reduce Transparency on/off show no custom bar backgrounds; no `NavigationView`/`.thinMaterial` left. Screenshots were produced by a throwaway XCUITest (not committed, recipe in `AGENTS.md`). The same run exercised add → edit → delete of an expense through the UI (including swipe-to-delete in `MUCustomVerticalForEach`), which confirms the Phase 2 edit-modal fix.

**Carried to Phase 4:** the Income dashboard hero / circular progress and the section headers did not reflow at accessibility sizes (resolved in Phase 4: the dashboard was redesigned and the goal card stacks at accessibility sizes).

## Phase 4 – Screen redesign (done)
Tokens live in `MUDesignSystem` (`MUSpacer`, new `MURadius`, `MUCard`); screens consume them. Decisions taken (no input was available): **Social groups is hidden** (tab and stub deleted; it needs a data model and there is no backend), the fake Profile rows were **removed** instead of stubbed, and **Currency + data export were built** because the app hard-coded `$`.
- [x] **Expenses dashboard**: `List(.insetGrouped)` with a weekly-chart card, newest-first recent transactions (swipe-to-delete, tap to edit) and a category donut card (last 30 days, `Domain/ExpenseAnalytics.swift`); empty state with an add action. The neutral chart replaces the old gradient/threshold-coloured card.
- [x] **All transactions / All deposits**: sections by day (`Domain/DaySection.swift`), swipe-to-delete on the resolved row, search with `.searchToolbarBehavior(.minimize)`, `ContentUnavailableView` for empty and no-results.
- [x] **Income / saving goal**: new goal card (icon, name, target date with a real relative label instead of the hard-coded "In 122 days", progress bar, Earned/Left/Required tiles with `Left` clamped at 0), **goal create/edit/delete** (`SavingGoalFormView`, toolbar menu; previously there was no way to create a goal), no-goal and no-deposits empty states.
- [x] **Settings** (was Profile; tab renamed): Currency picker (live across the app via `\.currencyCode`), CSV export (`ShareLink`), About/version, Debug. Removed: subscriptions, biometry toggle (read nowhere), categories (fixed enum), SVG export, support links (`apple.com` was not a valid URL), and the stale `Settings.bundle` (its `dev`/`pro` values stopped meaning anything in Phase 1).
- [x] **Forms**: 4 near-duplicate modals → `ExpenseFormView`, `DepositFormView` (+ new `SavingGoalFormView`), each with a `Mode`; edit uses `.sheet(item:)`.
- [x] **Money formatting**: `Double.formattedMoney(code:)` / `formattedCompactMoney(code:)` replace `toMoneyString` / `toAbbreviateMoneyString`, which rounded every amount up to 0.1 and hard-coded `$`.
- [x] **Deleted as dead or replaced**: `MUCustomVerticalForEach` (native `List` swipe actions replace it), `CircularSavingProgressView` (no users after the card redesign), `LoadingScreen`, `Date.categoryFormattedDate`, `Calendar.actualMonthToString`.
- Not built: search on the dashboard (search lives on the All lists), a floating quick-add, app icon (Phase 3 leftover).

**Accept (met):** every screen has `#Preview`s for mock data and empty state; screens that call services also have a "Failing service" preview, where the error alert only appears when the user acts (alerts are driven by `@State`, so a preview cannot start in the error state). No placeholder `Text` destinations remain. Verified through the UI with a throwaway XCUITest (light, dark, Reduce Transparency, XXL type): add/edit/delete expense, delete-all → empty states, create goal, add deposit, currency switch.

## Order at a glance
| Phase | Theme | Why here |
|---|---|---|
| 5 | Money picture: periods, budget, balance, insights, new Expenses/Income/Savings screens | The app has no value today; screen contents change here, so layouts are adapted afterwards |
| 6 | Quick capture and reminders: App Intent, widgets, controls, notifications | Biggest lever for real use; needs the store in an App Group, which must precede sync |
| 7 | Adaptive layouts: iPhone, iPad, iPhone Duo | Done once the screens are settled (was Phase 5) |
| 8 | Savings and data portability: multiple goals, filters, CSV import, lock, iCloud sync | Builds on Phases 5-6 |
| 9 | Tests, QA, release | Was Phase 6 |

## Phase 5 – Money picture
Goal: opening the app answers "how am I doing this month?".
- [x] **Domain split and renames**: `Deposit` → `Income`, `FoundingSource` → `IncomeSource` (typo fixed, duplicate `.Income` case removed), `IncomeService` keeps income only, new `SavingsService` owns the goal and new `Contribution` (id, amount, date, note); goal progress = sum of contributions. `IncomeObjectiveView` is replaced by an Income tab (`IncomeView`, day-grouped list) and a Savings tab (`SavingsView`: goal card + contributions list with add/edit/delete). Tabs are now Expenses / Income / Savings / Settings. Settings export includes contributions; the Debug generator creates monthly contributions.
- [x] **SwiftData migration**: the record classes were renamed (`IncomeRecord`, new `ContributionRecord`); SwiftData's automatic lightweight migration opens an older store (verified by installing the previous build, seeding it, then installing this one over it): expenses survive, the old deposits are dropped (accepted, open question 4).
- [x] **`Period` + `PeriodSummary`** (pure, `Domain/`, unit-tested in `PeriodTests` / `PeriodSummaryTests`): week / month / year with previous/next; spent, previous-period total and relative change, daily average, linear projection (only while in progress), category totals, cumulative daily series for the current and previous period, income, contributions and balance. Tests cover month/year boundaries (end exclusive), leap years, Monday-first weeks, empty and not-yet-started periods, and the balance rule.
- [x] **Budget**: `Budget` (monthly limit + optional per-category limits, single budget), `BudgetService`/`MockBudgetService`, `BudgetFormView` (sheet from the Expenses summary card and Settings ▸ Preferences ▸ Budget; remove-budget action); `BudgetProgress` states ok / warning (≥80 %) / over. The Debug generator seeds a budget.
- [x] **Expenses screen redesign**: period selector (`PeriodPicker`), summary card (spent, change vs the previous period at the same day, projection, budget row for months), cumulative-spend chart against the previous period with touch selection and the monthly limit line, insights, categories as horizontal bars (top 5 + "Other", limit tint), recent transactions of the selected period. Replaces the 7-day bar chart and the donut (`getActualWeekExpenses` and its helper deleted).
- [x] **Income screen**: period selector and a **balance card (income − expenses − contributions)** with Income / Expenses / Saved breakdown on top of the day-grouped income list, filtered to the period.
- [x] **Insights**: up to 3 localized sentences (projection vs budget, change vs previous period, top category, daily average) from `Insight.make(from:monthlyLimit:)`, unit-tested.
- [x] **Debug sample data** (`#if DEBUG`): `SampleDataGenerator` builds ~4 months of deterministic, today-relative data (seeded RNG: expenses across categories, monthly salary plus extras, a goal) instead of the fixed mock arrays; it is extended with contributions and a budget when those models exist. The store is **auto-seeded in Debug builds when it is empty** (Settings ▸ Debug toggle "Auto-seed when empty", launch arg `-messup_autoseed NO` to test the real empty state); "Replace with sample data" / "Delete all data" stay. Release is unaffected.

**Accept:** with the sample data the Expenses screen shows a total, a comparison and a budget state; balance and projection match hand-computed values in tests; every screen has mock and empty previews; screenshots (light/dark, XXL) reviewed; `AGENTS.md` updated.

## Phase 6 – Quick capture and reminders
- [ ] **Move `LocalStore` to an App Group container** (migrate the existing store on first launch). Prerequisite for the widget/intent targets; needs the App Group entitlement in the signing setup (hand-edited pbxproj, like before).
- [x] **App Intent** `AddExpenseIntent` (amount, name, category, payment method) + `MessupShortcuts` (`AppShortcutsProvider`): Siri, Shortcuts, Spotlight, Action button. Runs in the app process with the shared `AppServices`, so no App Group was needed. Metadata is generated (verified in `Metadata.appintents`); a real Siri/Shortcuts run was not exercised (no way to drive it from the CLI), the record/validation logic is unit-tested.
- [ ] **Widgets**: spent this month vs budget (small/medium), interactive quick-add, Lock Screen widget, Control Center control. Reload timelines after every write.
- [x] **Local notifications** (opt-in in Settings, permission requested in context): budget at 80 % and 100 % (`BudgetAlert` + `BudgetAlertChecker`, unit-tested, fires from UI writes and from the intent), weekly summary (repeating Sunday 18:00, generic text). The permission prompt appearing on toggling was checked in the simulator; actual delivery on a device is a manual check.

**Accept:** an expense added from Siri/Shortcuts or the widget shows up in the app; widget values match the app; notifications fire at the thresholds (unit-tested threshold logic, manual check of delivery).

## Phase 7 – Adaptive layouts: iPhone, iPad, iPhone Duo (was Phase 5)
Applies to the screens as they stand after Phases 5-6 (period selector, charts and the new Income/Savings screens included).
- [ ] **Measure first**: boot `iPhone Duo`, record window size, size classes, safe areas and orientations the sim offers; write results here. Do not assume a fold/hinge API (none found in SDK 27.1).
- [ ] Lift iPhone portrait-only restriction (`INFOPLIST_KEY_UISupportedInterfaceOrientations`) → allow landscape.
- [ ] Width-driven layout, never device checks: `NavigationSplitView` (sidebar/list/detail) in regular width, `NavigationStack` in compact; `ViewThatFits`, `containerRelativeFrame`, `onGeometryChange` for charts/grids (adaptive `LazyVGrid` columns).
- [ ] Dashboard: single column compact → two-column (summary + chart | list) wide. Forms: sheet compact, popover/centered regular.
- [ ] Multitasking: resize window in Split View / Stage Manager on iPad; no layout jumps, no `UIScreen` use.
- [ ] Keyboard/pointer: hardware keyboard shortcuts for add (⌘N), search (⌘F), hover effects on rows.

**Test matrix (screenshot each, both orientations, light/dark):**

| Device | Purpose |
|---|---|
| iPhone 17e | smallest current iPhone |
| iPhone Air | thin form factor, large screen |
| iPhone Duo | wide/dual-pane layout |
| iPad mini (A17 Pro), iPad Pro 13 | compact→regular transitions, split view |

**Accept:** no clipped/overlapping content on any matrix device; resizing an iPad window through compact↔regular preserves state.

## Phase 8 – Savings and data portability
- [ ] **Multiple savings goals** (goal detail, archive completed); `SavingsService` already owns contributions per goal from Phase 5 (add `goalID` then).
- [ ] **Filters and sorting** in the All lists: category, date range, amount range.
- [ ] **CSV import** using the export format (bank-specific column mapping is out of scope).
- [ ] **Face ID / passcode lock** (LocalAuthentication, optional in Settings).
- [ ] **iCloud sync** (SwiftData + CloudKit). Constraints to resolve first: no `@Attribute(.unique)` (dedupe by `id` in the services), every property optional or defaulted, iCloud entitlement and paid team, CloudKit schema deployment; tests keep using in-memory/local configurations.
- [ ] Optional: receipt photo attached to an expense (VisionKit scan/OCR).

**Accept:** data survives reinstall and appears on a second device (manual check); import(export(x)) round-trips in a unit test.

## Phase 9 – Tests, QA, release (was Phase 6)
- [ ] **Commit the UI tests** used for verification so far (add → edit → delete, delete-all → empty states, goal creation, currency switch) in `iOSMessupUITests` (wire the target as a synchronized folder, recipe in `AGENTS.md`); run on iPhone and iPad.
- [ ] `performAccessibilityAudit()` in UI tests for main screens.
- [ ] Run the service contract tests against both the mock and the SwiftData services.
- [ ] CI: GitHub Actions running build + unit tests on a 27.x simulator (none exists today).
- [ ] Localization: add Spanish to the String Catalog (see open question 2) and review all strings, including generated insight sentences.
- [ ] New app icon via Icon Composer (Phase 3 leftover; needs artwork).
- [ ] Release checklist: privacy manifest, Release build has no debug code, TestFlight.

## Parked (not planned)
Recurring expenses / upcoming payments (decision 7), shared/group expenses (needs CloudKit sharing or a backend; the Social tab was removed in Phase 4), per-entry multi-currency, Live Activities, bank sync.

## Risks
| Risk | Mitigation |
|---|---|
| Raising to iOS 26 drops older devices | Explicit decision #1; revisit only if distribution needs them |
| Glass over charts hurts legibility | Glass only on controls; test Reduce Transparency / Increase Contrast each phase |
| SwiftData store diverges from mock semantics | Mock and SwiftData services implement the same protocols; contract tests run against both (Phase 9) |
| Swift 6 migration noise | Staged: Approachable Concurrency under Swift 5 first (done) |
| No iOS 26.x simulator runtime | Test on 27.x; install a 26.x runtime if a 26-specific bug is suspected |
| Renaming `@Model` classes (Phase 5) loses existing local data | Keep record class names or add a migration stage; confirm whether any data must survive (open question 4) |
| Moving the store to an App Group (Phase 6) can orphan the old store | Migrate on first launch and test it with an on-disk store |
| CloudKit forbids unique constraints and non-optional-without-default properties (Phase 8) | Schema review before Phase 8; dedupe in services |
| Period maths (time zones, month ends, leap years) | Pure `Period`/`PeriodSummary` with boundary tests before any UI |

## Open questions
1. ~~Build the Social groups feature, or hide the tab?~~ Hidden in Phase 4 (assumed default; revert by adding a `Tab` and a feature with its own data model if it is wanted).
2. Keep Spanish, English, or both (String Catalog) as launch languages? Recommendation: both; the work is scheduled in Phase 9.
3. Confirm "iPhone Duo" means the simulator device above (and not another device/feature). Needed before Phase 7.
4. Does any existing local data have to survive the Phase 5 renames (`Deposit` → `Income`)? There is no released build, so the default is: rename and wipe is acceptable.
5. ~~Do goal contributions reduce the monthly balance?~~ Yes (decision 6).

## Baseline results
Recorded before the local-only/SwiftData milestone (Xcode 27 toolchain, iPhone 17 simulator).

- `xcodebuild -scheme iOSMessup build`: **succeeded**, 14 distinct warnings (unstructured throwing `Task`s in `ExpensesView`/`AllDepositsView`/`SavingsObjectiveView`/`RegistrationView`, unused `refreshToken` in `AuthService`, `Combine` not imported in `LoadingScreen`).
- `xcodebuild -scheme iOSMessupTests test`: **succeeded**; all 9 `ExpensesServiceTests` pass.
- `cd MUDesignSystem && swift build` (macOS host): **fails** (`cannot find type 'UITextContentType' in scope` in `MUTextField`; the package is iOS-only and `swift build` targets macOS). `MUDesignSystemShowcase` not investigated. Not fixed.
- Landing-screen "before" screenshots not taken: the Landing view is deleted by this milestone and `simctl` cannot drive taps to reach tab screens.
