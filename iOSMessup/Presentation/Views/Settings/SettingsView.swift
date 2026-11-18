//
//  SettingsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - SettingsRoute

private enum SettingsRoute: Hashable {
    case currency
}

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.incomeService) private var incomeService
    @Environment(\.savingsService) private var savingsService
    @Environment(\.budgetService) private var budgetService
    @Environment(\.notificationService) private var notificationService
    @AppStorage(NotificationPreferences.budgetAlertsKey) private var budgetAlertsEnabled = false
    @AppStorage(NotificationPreferences.weeklySummaryKey) private var weeklySummaryEnabled = false
    @State private var isShowingBudget = false
    @AppStorage(AppCurrency.storageKey) private var currencyCode = AppCurrency.defaultCode
    @State private var exportURL: URL?
    @State private var error: (any Error)?

    private var csv: String {
        CSVExporter.csv(expenses: expenseService.expenses,
                        incomes: incomeService.incomes,
                        contributions: savingsService.contributions)
    }

    private var hasData: Bool {
        !expenseService.expenses.isEmpty || !incomeService.incomes.isEmpty || !savingsService.contributions.isEmpty
    }

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: MUSpacer.size02) {
                        Image("logoPNG")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 88)
                            .accessibilityHidden(true)
                        Text(verbatim: "Messup")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                Section("Preferences") {
                    NavigationLink(value: SettingsRoute.currency) {
                        LabeledContent("Currency", value: "\(AppCurrency.localizedName(for: currencyCode)) (\(currencyCode))")
                    }
                    Button {
                        isShowingBudget = true
                    } label: {
                        LabeledContent("Budget") {
                            if let budget = budgetService.budget {
                                Text(budget.monthlyLimit.formattedMoney(code: currencyCode))
                            } else {
                                Text("Not set")
                            }
                        }
                        .contentShape(.rect)
                    }
                    .foregroundStyle(.primary)
                }
                Section {
                    Toggle("Budget alerts", isOn: $budgetAlertsEnabled)
                    Toggle("Weekly summary", isOn: $weeklySummaryEnabled)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Budget alerts tell you when you reach 80 % of your monthly budget and when you go over it. The weekly summary arrives on Sundays.")
                }
                Section("Data") {
                    exportRow
                }
                Section("About") {
                    LabeledContent("Version", value: version)
                }
                #if DEBUG
                DebugSection()
                #endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .currency: CurrencyPickerView()
                }
            }
            .task(id: csv) { writeExport(csv) }
            .onChange(of: budgetAlertsEnabled) { _, isOn in
                guard isOn else { return }
                Task { if await authorize() == false { budgetAlertsEnabled = false } }
            }
            .onChange(of: weeklySummaryEnabled) { _, isOn in
                Task {
                    if isOn, await authorize() == false {
                        weeklySummaryEnabled = false
                        return
                    }
                    await notificationService.setWeeklySummary(enabled: isOn)
                }
            }
            .errorAlert($error)
            .sheet(isPresented: $isShowingBudget) { BudgetFormView() }
        }
    }

    // MARK: - Notifications

    /// Asks for permission in context (when a switch is turned on); explains how to fix it when it was denied.
    private func authorize() async -> Bool {
        let granted = await notificationService.requestAuthorization()
        if !granted { error = NotificationError.denied }
        return granted
    }

    // MARK: - Export

    @ViewBuilder
    private var exportRow: some View {
        if hasData, let exportURL {
            ShareLink(item: exportURL) {
                Label("Export data", systemImage: "square.and.arrow.up")
            }
        } else {
            Label("Export data", systemImage: "square.and.arrow.up")
                .foregroundStyle(.secondary)
        }
    }

    private func writeExport(_ csv: String) {
        guard hasData else {
            exportURL = nil
            return
        }
        let url = FileManager.default.temporaryDirectory.appending(path: "messup-export.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
        } catch {
            exportURL = nil
            self.error = error
        }
    }
}

// MARK: - CurrencyPickerView

struct CurrencyPickerView: View {
    @AppStorage(AppCurrency.storageKey) private var currencyCode = AppCurrency.defaultCode
    @State private var searchText = ""

    private var codes: [String] {
        let all = AppCurrency.supportedCodes
        guard !searchText.isEmpty else { return all }
        return all.filter {
            AppCurrency.localizedName(for: $0).localizedStandardContains(searchText)
                || $0.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(codes, id: \.self) { code in
                Button {
                    currencyCode = code
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(AppCurrency.localizedName(for: code))
                            Text(code).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if code == currencyCode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                                .accessibilityLabel("Selected")
                        }
                    }
                    .contentShape(.rect)
                }
                .foregroundStyle(.primary)
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if codes.isEmpty { ContentUnavailableView.search(text: searchText) }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Mock data") {
    SettingsView()
}

#Preview("Currency picker") {
    NavigationStack { CurrencyPickerView() }
}
