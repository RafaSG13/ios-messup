//
//  Colors.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 3/2/25.
//

import SwiftUI

public enum MUDesignSystemColors {
    public static let darkGreen = Color(red: 0.023, green: 0.344, blue: 0.000)
    public static let genericBackground = Color(red: 0.953, green: 0.949, blue: 0.976)
    public static let mintAccent = Color(red: 0.376, green: 0.839, blue: 0.784)
    public static let accent = MUDesignSystemColors.mintAccent // Using mintAccent as the primary accent color
    public static let tangerine = Color(red: 0.976, green: 0.525, blue: 0.098)
    public static let sunYellow = Color(red: 0.976, green: 0.753, blue: 0.106)
    public static let bubblegum = Color(red: 0.910, green: 0.639, blue: 0.753)
    public static let deepBlue = Color(red: 0.082, green: 0.310, blue: 0.639)

}

public extension Color {
    static var designSystem: MUDesignSystemColors.Type {
        MUDesignSystemColors.self
    }
}
