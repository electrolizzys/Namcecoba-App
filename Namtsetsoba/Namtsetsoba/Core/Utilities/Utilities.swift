import Foundation

enum Utilities {
    static func formatMoneyGel(_ amount: Decimal) -> String {
        let n = amount as NSDecimalNumber
        return "\(n.stringValue) ₾"
    }
}
