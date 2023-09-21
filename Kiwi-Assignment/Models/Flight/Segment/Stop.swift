import Foundation

extension Models.Flight.Segment {
    struct Stop: Decodable {
        var id: String
        var name: String
        var code: String
        var type: String
        var city: City
        var utcTime: String
        var localTime: String
        
        enum CodingKeys: String, CodingKey {
            case utcTime
            case localTime
            case station
        }
        
        enum StationCodingKeys: String, CodingKey {
            case id
            case name
            case code
            case type
            case city
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            utcTime = try container.decode(String.self, forKey: .utcTime)
            localTime = try container.decode(String.self, forKey: .localTime)
            
            let stationContainer = try container.nestedContainer(keyedBy: StationCodingKeys.self, forKey: .station)
            id = try stationContainer.decode(String.self, forKey: .id)
            name = try stationContainer.decode(String.self, forKey: .name)
            code = try stationContainer.decode(String.self, forKey: .code)
            type = try stationContainer.decode(String.self, forKey: .type)
            city = try stationContainer.decode(City.self, forKey: .city)
        }
    }
}
