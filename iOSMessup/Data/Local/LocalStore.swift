//
//  LocalStore.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import SwiftData

final class LocalStore: Sendable {
    enum Storage {
        case file(URL)
        case inMemory
    }

    static let shared = LocalStore(storage: .file(URL.applicationSupportDirectory.appending(path: "Messup.store")))

    let container: ModelContainer

    init(storage: Storage) {
        let schema = Schema([ExpenseRecord.self, IncomeRecord.self, ContributionRecord.self, SavingGoalRecord.self])
        let configuration: ModelConfiguration
        switch storage {
        case .file(let url):
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true)
            } catch {
                fatalError("LocalStore: \(error)")
            }
            configuration = ModelConfiguration(schema: schema, url: url)
        case .inMemory:
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        }
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("LocalStore: \(error)")
        }
    }

    var context: ModelContext { container.mainContext }
}
