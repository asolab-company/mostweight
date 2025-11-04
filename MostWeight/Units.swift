import SwiftUI

public let unitSystemKey = "preferredUnitSystem"

public enum UnitSystem: String, CaseIterable, Codable {
    case metric
    case imperial

    public var title: String {
        switch self {
        case .metric: return "Kilograms"
        case .imperial: return "Pounds"
        }
    }

    public var unitLabel: String {
        switch self {
        case .metric: return "kg"
        case .imperial: return "lb"
        }
    }

    public func toDisplay(fromKilograms kg: Double) -> Double {
        switch self {
        case .metric: return kg
        case .imperial: return kg * 2.20462
        }
    }

    public func toKilograms(fromDisplay v: Double) -> Double {
        switch self {
        case .metric: return v
        case .imperial: return v / 2.20462
        }
    }
}
