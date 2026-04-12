---
applyTo: '**'
---

# project.instructions.md

This file provides guidance to AI Assistant when working with code in this repository.

## Build/Lint/Test Commands

- **Build**: `xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup build`
- **Test**: `xcodebuild -project iOSMessup.xcodeproj -scheme iOSMessup test`
- **Run single test**: `xcodebuild test -project iOSMessup.xcodeproj -scheme iOSMessup -only-testing iOSMessupTests/<TestFile>/<TestName>`
- **Open in Xcode**: `open iOSMessup.xcodeproj`

## Code Style Guidelines

- **Imports**: Group imports by framework (SwiftUI/Foundation first, then third-party); alphabetize within groups
- **Naming**: Use PascalCase for types/protocols/enums; camelCase for variables/functions; UPPER_CASE for static constants
- **Formatting**: 4-space indentation; opening braces on same line; trailing closures preferred
- **Types**: Prefer structs for domain models; use `@Observable` classes for services; mark classes `final` when not subclassed
- **Access Control**: Default to `private`/`fileprivate`; explicitly mark `internal` only when needed
- **Protocols**: Suffix protocols with `Protocol` (e.g., `ExpensesServiceProtocol`); place in dedicated files
- **Comments**: Use `// MARK: -` for section headers; file headers with creation date and author
- **Error Handling**: Use `async throws` for network operations; propagate errors to UI via status enums
- **Previews**: Always include `#Preview` for SwiftUI views using mocks from `Domain/Mocks`

## Architecture Overview

iOSMessup follows a **Model-View (MV)** architecture with three clear layers: Domain, Data, and Presentation. Services are injected via SwiftUI Environment using the `@Entry` macro and are protocol-based for testability.

**Domain Layer** (`Domain/`): Contains pure domain models (structs) representing business entities like `Expense`, `Deposit`, `SavingGoal`. Includes a `Domain/Mocks/` subfolder with mock implementations of both domain objects and network responses for use in SwiftUI previews and unit tests.

**Data Layer** (`Data/`): Contains request/response DTOs (`Data/Requests/`, `Data/Responses/`) and services (`Data/Services/`) that handle network calls. Services are `@Observable` classes conforming to protocols (e.g., `ExpensesServiceProtocol`), injected via Environment values. Services use the networking client to perform API operations and maintain local state that views observe directly.

**Presentation Layer** (`Presentation/`): SwiftUI views that observe service state via `@Environment`. Views are passive and delegate actions back to injected services. Navigation uses native SwiftUI patterns (`NavigationStack`, `NavigationLink`, `.navigationDestination`) with a central `Route` enum for type-safe destinations. No view models—views bind directly to service state.

**Key Patterns**: Services are the single source of truth and are swappable between live and mock implementations via protocol conformance. Mocks live in `Domain/Mocks/` and are shared between previews and tests. The architecture eliminates traditional view models in favor of direct service observation.
