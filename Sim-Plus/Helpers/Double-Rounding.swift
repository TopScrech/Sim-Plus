import Foundation

extension Double {
    // Rounds a Double to a specific number of decimal places, leaving
    // it as a Double.
    func rounded(dp decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
}
