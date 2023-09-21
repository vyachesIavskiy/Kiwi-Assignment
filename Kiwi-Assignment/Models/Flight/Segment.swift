import Foundation

extension Models.Flight {
    struct Segment: Decodable {
        var id: String
        var duration: Measurement<UnitDuration>
        var type: String
        var code: String
        var from: Stop
        var to: Stop
        var carrier: Carrier
        var operatingCarrier: Carrier?
        var layover: Layover?
        
        enum ParentCodingKeys: String, CodingKey {
            case segment
            case layover
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case duration
            case type
            case code
            case from = "source"
            case to = "destination"
            case carrier
            case operatingCarrier
        }
        
        init(from decoder: Decoder) throws {
            let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
            layover = try parentContainer.decodeIfPresent(Layover.self, forKey: .layover)
            
            let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .segment)
            id = try container.decode(String.self, forKey: .id)
            
            let durationInSeconds = try container.decode(Double.self, forKey: .duration)
            duration = Measurement(value: durationInSeconds, unit: .seconds)
            
            type = try container.decode(String.self, forKey: .type)
            code = try container.decode(String.self, forKey: .code)
            from = try container.decode(Stop.self, forKey: .from)
            to = try container.decode(Stop.self, forKey: .to)
            carrier = try container.decode(Carrier.self, forKey: .carrier)
            operatingCarrier = try container.decodeIfPresent(Carrier.self, forKey: .operatingCarrier)
        }
    }
}
