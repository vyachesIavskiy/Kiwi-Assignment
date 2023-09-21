import Foundation

extension Models.Flight {
    struct BookingOption: Decodable {
        var urlString: String
        var price: Double
        var formattedPrice: String
        
        enum ParentCodingKeys: String, CodingKey {
            case node
        }
        
        enum CodingKeys: String, CodingKey {
            case urlString = "bookingUrl"
            case price
        }
        
        enum PriceCodingKeys: String, CodingKey {
            case amount
            case formattedValue
        }
        
        init(from decoder: Decoder) throws {
            let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
            let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
            urlString = try container.decode(String.self, forKey: .urlString)
            
            let priceContainer = try container.nestedContainer(keyedBy: PriceCodingKeys.self, forKey: .price)
            let priceStringValue = try priceContainer.decode(String.self, forKey: .amount)
            
            guard let priceDoubleValue = Double(priceStringValue) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: priceContainer.codingPath,
                    debugDescription: "Cannot represent price amount via '\(priceStringValue)'",
                    underlyingError: Error.invalidPriceAmountValue(priceStringValue)
                ))
            }
            
            price = priceDoubleValue
            formattedPrice = try priceContainer.decode(String.self, forKey: .formattedValue)
        }
    }
}

extension Models.Flight.BookingOption {
    enum Error: Swift.Error {
        case invalidPriceAmountValue(String)
    }
}

extension Models.Flight.BookingOption.Error: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .invalidPriceAmountValue(value):
            "'\(value)' is not a valid value to represent price amount"
        }
    }
}
