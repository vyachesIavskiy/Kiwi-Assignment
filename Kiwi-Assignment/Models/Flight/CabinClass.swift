import Foundation

extension Models.Flight {
    enum CabinClass: Decodable, CaseIterable, Identifiable {
        case economy
        case premiumEconomy
        case firstClass
        case business
        
        // This is a good point to get localized strings for cabin class
        // but I don't localize the app.
        var stringValue: String {
            switch self {
            case .economy: "Economy"
            case .premiumEconomy: "Premium economy"
            case .firstClass: "First class"
            case .business: "Business"
            }
        }
        
        var id: Self { self }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = switch value {
            case "ECONOMY": .economy
            case "PREMIUM_ECONOMY": .premiumEconomy
            case "FIRST_CLASS": .firstClass
            case "BUSINESS": .business
                
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot construct CabinClass from '\(value)'",
                    underlyingError: Error.invalidValue(value)
                ))
            }
        }
    }
}

extension Models.Flight.CabinClass {
    enum Error: Swift.Error {
        case invalidValue(String)
    }
}

extension Models.Flight.CabinClass.Error: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .invalidValue(value): "'\(value)' is an invalid option for CabinClass"
        }
    }
}
