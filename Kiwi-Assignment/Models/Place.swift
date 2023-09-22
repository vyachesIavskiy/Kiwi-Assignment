import Foundation

extension Models {
    @dynamicMemberLookup
    struct Places: Decodable {
        var places: [Place]
        
        enum ParentCodingKeys: String, CodingKey {
            case places
        }
        
        enum CodingKeys: String, CodingKey {
            case edges
        }
        
        init(from decoder: Decoder) throws {
            let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
            
            let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .places)
            places = try container.decode([Place].self, forKey: .edges)
        }
        
        subscript<T>(dynamicMember keyPath: KeyPath<[Place], T>) -> T {
            places[keyPath: keyPath]
        }
    }
}

extension Models {
    struct Place: Decodable, Identifiable, Hashable {
        var id: String
        var legacyID: String
        var name: String
        var latitude: Double
        var longitude: Double
        
        enum ParentCodingKeys: String, CodingKey {
            case node
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case legacyID = "legacyId"
            case name
            case gps
        }
        
        enum GPSCodingKeys: String, CodingKey {
            case lat
            case lng
        }
        
        init(from decoder: Decoder) throws {
            let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
            
            let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
            id = try container.decode(String.self, forKey: .id)
            legacyID = try container.decode(String.self, forKey: .legacyID)
            name = try container.decode(String.self, forKey: .name)
            
            let gpsContainer = try container.nestedContainer(keyedBy: GPSCodingKeys.self, forKey: .gps)
            latitude = try gpsContainer.decode(Double.self, forKey: .lat)
            longitude = try gpsContainer.decode(Double.self, forKey: .lng)
        }
        
        init(id: String, legacyID: String, name: String, latitude: Double, longitude: Double) {
            self.id = id
            self.legacyID = legacyID
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
