//
//  AppCurrency.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

// MARK: - AppCurrency

/// The currency every amount in the app is shown and entered in.
/// Stored in `UserDefaults` under `storageKey` (written by the Settings screen through `@AppStorage`)
/// and injected into the view tree as `\.currencyCode` by `iOSMessupApp`.
enum AppCurrency {
    static let storageKey = "currencyCode"

    static var defaultCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    /// ISO 4217 codes offered in Settings, sorted by their localized name.
    static var supportedCodes: [String] {
        Locale.commonISOCurrencyCodes.sorted { localizedName(for: $0) < localizedName(for: $1) }
    }

    static func localizedName(for code: String) -> String {
        Locale.current.localizedString(forCurrencyCode: code) ?? code
    }
}

extension EnvironmentValues {
    @Entry var currencyCode: String = AppCurrency.defaultCode
}
