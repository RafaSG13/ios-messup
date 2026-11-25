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
    @State private var isShowingBudget = false
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderSection()
                PreferencesSection(isShowingBudget: $isShowingBudget)
                NotificationsSection(error: $error)
                IntelligenceStatusSection()
                Section("Data") {
                    ExportDataRow(error: $error)
                }
                AboutSection()
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
            .errorAlert($error)
            .sheet(isPresented: $isShowingBudget) { BudgetFormView() }
        }
    }
}

// MARK: - SettingsHeaderSection

private struct SettingsHeaderSection: View {
    var body: some View {
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
            .clearListRow()
        }
    }
}

// MARK: - PreferencesSection

private struct PreferencesSection: View {
    @Environment(\.budgetService) private var budgetService
    @AppStorage(AppCurrency.storageKey) private var currencyCode = AppCurrency.defaultCode
    @Binding var isShowingBudget: Bool

    var body: some View {
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
    }
}

// MARK: - NotificationsSection

private struct NotificationsSection: View {
    @Environment(\.notificationService) private var notificationService
    @AppStorage(NotificationPreferences.budgetAlertsKey) private var budgetAlertsEnabled = false
    @AppStorage(NotificationPreferences.weeklySummaryKey) private var weeklySummaryEnabled = false
    @Binding var error: (any Error)?

    var body: some View {
        Section {
            Toggle("Budget alerts", isOn: $budgetAlertsEnabled)
            Toggle("Weekly summary", isOn: $weeklySummaryEnabled)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Budget alerts tell you when you reach 80 % of your monthly budget and when you go over it. The weekly summary arrives on Sundays.")
        }
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
    }

    /// Asks for permission in context (when a switch is turned on); explains how to fix it when it was denied.
    private func authorize() async -> Bool {
        let granted = await notificationService.requestAuthorization()
        if !granted { error = NotificationError.denied }
        return granted
    }
}

// MARK: - IntelligenceStatusSection

private struct IntelligenceStatusSection: View {
    @Environment(\.intelligenceService) private var intelligenceService

    var body: some View {
        Section {
            LabeledContent("Status") {
                Text(statusText(for: intelligenceService.availability))
            }
        } header: {
            Text("Apple Intelligence")
        } footer: {
            Text("Messup uses the on-device model to fill in expenses from text or receipts, suggest categories, summarize your spending and answer questions. Your data stays on your device.")
        }
    }

    private func statusText(for availability: IntelligenceAvailability) -> LocalizedStringKey {
        switch availability {
        case .available: "On"
        case .appleIntelligenceNotEnabled: "Off. Turn it on in Settings ▸ Apple Intelligence & Siri"
        case .deviceNotEligible: "Not supported on this device"
        case .modelNotReady: "Getting ready…"
        case .unsupportedLanguage: "Language not supported"
        }
    }
}

// MARK: - ExportDataRow

/// Owns the CSV: it is rebuilt only when the data changes, not on every Settings state change.
private struct ExportDataRow: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.incomeService) private var incomeService
    @Environment(\.savingsService) private var savingsService
    @State private var exportURL: URL?
    @Binding var error: (any Error)?

    var body: some View {
        let hasData = !expenseService.expenses.isEmpty
            || !incomeService.incomes.isEmpty
            || !savingsService.contributions.isEmpty
        let csv = CSVExporter.csv(expenses: expenseService.expenses,
                                  incomes: incomeService.incomes,
                                  contributions: savingsService.contributions)

        Group {
            if hasData, let exportURL {
                ShareLink(item: exportURL) {
                    Label("Export data", systemImage: "square.and.arrow.up")
                }
            } else {
                Label("Export data", systemImage: "square.and.arrow.up")
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: csv) { writeExport(csv, hasData: hasData) }
    }

    private func writeExport(_ csv: String, hasData: Bool) {
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

// MARK: - AboutSection

private struct AboutSection: View {
    var body: some View {
        Section("About") {
            LabeledContent("Version", value: version)
        }
    }

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
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
        let codes = self.codes

        List {
            ForEach(codes, id: \.self) { code in
                Button {
                    currencyCode = code
                } label: {
                    CurrencyOptionLabel(code: code, isSelected: code == currencyCode)
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

// MARK: - CurrencyOptionLabel

private struct CurrencyOptionLabel: View {
    let code: String
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(AppCurrency.localizedName(for: code))
                Text(code).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Selected")
            }
        }
        .contentShape(.rect)
    }
}

// MARK: - Previews

#Preview("Mock data") {
    SettingsView()
}

#Preview("Currency picker") {
    NavigationStack { CurrencyPickerView() }
}
