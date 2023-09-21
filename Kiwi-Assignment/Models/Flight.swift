import Foundation

extension Models {
    @dynamicMemberLookup
    struct Flights: Decodable {
        var flights: [Flight]
        
        enum ParentCodingKeys: String, CodingKey {
            case onewayItineraries
        }
        
        enum CodingKeys: String, CodingKey {
            case itineraries
        }
        
        init(from decoder: Decoder) throws {
            let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
            
            let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .onewayItineraries)
            flights = try container.decode([Flight].self, forKey: .itineraries)
        }
        
        subscript<T>(dynamicMember keyPath: KeyPath<[Flight], T>) -> T {
            flights[keyPath: keyPath]
        }
    }
}

extension Models {
    struct Flight: Decodable {
        var id: String
        var duration: Measurement<UnitDuration>
        var cabinClasses: [CabinClass]
        var bookingOptions: [BookingOption]
        var segments: [Segment]
        
        enum CodingKeys: CodingKey {
            case id
            case duration
            case cabinClasses
            case bookingOptions
            case sector
        }
        
        enum BookingOptionsCodingKeys: String, CodingKey {
            case edges
        }
        
        enum SectorCodingKeys: String, CodingKey {
            case segments = "sectorSegments"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            
            let durationInSeconds = try container.decode(Double.self, forKey: .duration)
            duration = Measurement(value: durationInSeconds, unit: .seconds)
            
            cabinClasses = try container.decode([CabinClass].self, forKey: .cabinClasses)
            
            let bookingOptionsContainer = try container.nestedContainer(keyedBy: BookingOptionsCodingKeys.self, forKey: .bookingOptions)
            bookingOptions = try bookingOptionsContainer.decode([BookingOption].self, forKey: .edges)
            
            let sectorContainer = try container.nestedContainer(keyedBy: SectorCodingKeys.self, forKey: .sector)
            segments = try sectorContainer.decode([Segment].self, forKey: .segments)
        }
    }
}
