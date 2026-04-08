import SwiftUI

enum DesignTokens {
    static let cornerRadius: CGFloat = 14
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8

    static let cardShadowColor: Color = .black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 8

    static let primaryGreen = Color(red: 0.1, green: 0.6, blue: 0.4)
    static let accentOrange = Color(red: 0.95, green: 0.55, blue: 0.2)

    static func gradientForCategory(_ category: ProductCategory) -> LinearGradient {
        let colors: [Color] = switch category {
        case .bakery:
            [Color(red: 0.85, green: 0.6, blue: 0.25), Color(red: 0.72, green: 0.42, blue: 0.15)]
        case .restaurant:
            [Color(red: 0.82, green: 0.22, blue: 0.18), Color(red: 0.62, green: 0.14, blue: 0.12)]
        case .grocery:
            [Color(red: 0.22, green: 0.7, blue: 0.38), Color(red: 0.12, green: 0.55, blue: 0.28)]
        case .cafe:
            [Color(red: 0.58, green: 0.38, blue: 0.22), Color(red: 0.42, green: 0.28, blue: 0.18)]
        case .pastry:
            [Color(red: 0.85, green: 0.42, blue: 0.62), Color(red: 0.68, green: 0.28, blue: 0.48)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
