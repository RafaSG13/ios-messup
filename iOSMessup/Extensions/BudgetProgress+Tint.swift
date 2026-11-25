//
//  BudgetProgress+Tint.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import MUDesignSystem
import SwiftUI

extension BudgetProgress.State {
    /// Accent while within the limit, orange from the warning threshold, red once over.
    var tint: Color {
        switch self {
        case .ok: .accentColor
        case .warning: Color.designSystem.warning
        case .over: Color.designSystem.critical
        }
    }
}
