//
//  MURadius.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

/// Corner radii. Use with `.clipShape(.rect(cornerRadius:))` / `.background(_, in: .rect(cornerRadius:))`.
public enum MURadius {
    /// Badges, small chips and icon tiles.
    public static let small: CGFloat = 8
    /// Rows and inline surfaces.
    public static let medium: CGFloat = 12
    /// Cards that group content (charts, goal summary).
    public static let large: CGFloat = 20
}
