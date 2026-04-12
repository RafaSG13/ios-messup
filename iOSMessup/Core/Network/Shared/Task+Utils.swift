//
//  AnyTaskCancellable.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 12/4/26.
//


import Foundation

/// A thread-safe, `@MainActor` isolated store for managing the lifecycle of unique asynchronous tasks.
///
/// `TaskStore` is designed to prevent duplicate task executions (e.g., rapid-fire button presses) by using
/// a unique identifier for each operation. It automatically cleans up tasks once they complete.
@MainActor
public final class TaskStore {
    private var tasks: [AnyHashable: Task<Void, Never>] = [:]

    public init() {}

    /// Executes an asynchronous operation explicitly on the Main thread.
    ///
    /// This method guarantees that the provided operation will run on the `@MainActor`, making it the safest
    /// choice for UI updates or interacting with state properties that drive SwiftUI views.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the task (can be a String, Enum, etc.).
    ///   - operation: The `@MainActor` isolated asynchronous closure to execute.
    public func main(_ id: AnyHashable, operation: @escaping @Sendable @MainActor () async throws -> Void) {
        guard tasks[id] == nil else { return }

        tasks[id] = Task { @MainActor [weak self] in
            _ = try? await operation()
            self?.tasks[id] = nil
        }
    }

    /// Executes an asynchronous operation in the current inherited context.
    ///
    /// If a task with the same `id` is already running, the new operation is silently ignored, preventing duplicate executions.
    /// The task is automatically removed from the store upon completion.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the task.
    ///   - operation: The asynchronous closure to execute.

    public func run(_ id: AnyHashable, operation: @escaping @Sendable () async throws -> Void) {
        guard tasks[id] == nil else { return }

        tasks[id] = Task { [weak self] in
            _ = try? await operation()
            self?.tasks[id] = nil
        }
    }

    /// Executes an asynchronous operation in a detached background thread, isolated from the current context.
    ///
    /// Ideal for heavy computational tasks that shouldn't block the main thread. Like `run`, it prevents duplicate executions
    /// for the same `id` and automatically cleans up upon completion.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the task.
    ///   - priority: The optional priority for the detached task.
    ///   - operation: The `@Sendable` asynchronous closure to execute in the background.
    public func detached(_ id: AnyHashable, priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Void) {
        guard tasks[id] == nil else { return }

        tasks[id] = Task.detached(priority: priority) { [weak self] in
            _ = try? await operation()

            // Route back to the main thread only to safely clean up the dictionary
            await MainActor.run { [weak self] in
                self?.tasks[id] = nil
            }
        }
    }

    /// Cancels and removes a specific task matching the given identifier.
    ///
    /// - Parameter id: The unique identifier of the task to cancel.
    public func cancel(_ id: AnyHashable) {
        tasks[id]?.cancel()
        tasks[id] = nil
    }

    /// Cancels all currently active tasks and empties the store.
    ///
    /// Highly recommended to be called during the `onDisappear` phase of a view or the `deinit` of a manager/service.
    public func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

//MARK: - AnyTaskCancellable


/// A type-erased wrapper for a `Task` that allows you to store tasks with different success and failure types in a single collection.
///
/// This is conceptually similar to Combine's `AnyCancellable`, providing a convenient way to manage the lifecycle
/// of asynchronous tasks without exposing their underlying generic types.
public struct AnyTaskCancellable {
    private let cancelBlock: () -> Void

    /// Initializes a type-erased cancellable from a generic `Task`.
    /// - Parameter task: The task to be wrapped and managed.
    public init<Success, Failure>(_ task: Task<Success, Failure>) {
        self.cancelBlock = { task.cancel() }
    }

    /// Cancels the underlying task.
    public func cancel() {
        cancelBlock()
    }
}

public extension Task {
    /// Stores the task in the provided collection of cancellables.
    ///
    /// - Parameter bag: An `inout` array of `AnyTaskCancellable` where the task will be stored.
    func store(in bag: inout [AnyTaskCancellable]) {
        bag.append(AnyTaskCancellable(self))
    }
}

public extension Array where Element == AnyTaskCancellable {
    /// Cancels all tasks stored in the array and removes them, freeing up resources.
    mutating func cancelAll() {
        self.forEach { $0.cancel() }
        self.removeAll()
    }
}
