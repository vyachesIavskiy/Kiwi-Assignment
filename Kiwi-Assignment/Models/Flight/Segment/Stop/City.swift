import Foundation

extension Models.Flight.Segment.Stop {
    struct City: Decodable {
        var id: String
        var legacyID: String
        var name: String
        var countryID: String
        var countryName: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case legacyID = "legacyId"
            case name
            case country
        }
        
        enum CountryCodingKeys: String, CodingKey {
            case id
            case name
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            legacyID = try container.decode(String.self, forKey: .legacyID)
            name = try container.decode(String.self, forKey: .name)
            
            let countryContainer = try container.nestedContainer(keyedBy: CountryCodingKeys.self, forKey: .country)
            countryID = try countryContainer.decode(String.self, forKey: .id)
            countryName = try countryContainer.decode(String.self, forKey: .name)
        }
    }
}
