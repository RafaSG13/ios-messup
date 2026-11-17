import SwiftUI

public enum MUDesignSystemColors {
    public static let darkGreen = Color(red: 0.023, green: 0.344, blue: 0.000)
    public static let genericBackground = Color(red: 0.953, green: 0.949, blue: 0.976)
    public static let mintAccent = Color(red: 0.376, green: 0.839, blue: 0.784)
    public static let accent = MUDesignSystemColors.mintAccent // Using mintAccent as the primary accent color

}

public extension Color {
    static var designSystem: MUDesignSystemColors.Type {
        MUDesignSystemColors.self
    }
}
