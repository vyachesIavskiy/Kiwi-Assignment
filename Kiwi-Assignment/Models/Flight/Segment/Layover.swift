import Foundation

extension Models.Flight.Segment {
    struct Layover: Decodable {
        var duration: Measurement<UnitDuration>
        var isBaggageRecheck: Bool
        var transferDuration: Measurement<UnitDuration>?
        var transferType: String?
        
        enum CodingKeys: CodingKey {
            case duration
            case isBaggageRecheck
            case transferDuration
            case transferType
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let durationInSeconds = try container.decode(Double.self, forKey: Models.Flight.Segment.Layover.CodingKeys.duration)
            duration = Measurement(value: durationInSeconds, unit: .seconds)
            
            isBaggageRecheck = try container.decode(Bool.self, forKey: .isBaggageRecheck)
            
            let transferDurationInSeconds = try container.decodeIfPresent(Double.self, forKey: .transferDuration)
            transferDurationInSeconds.map {
                transferDuration = Measurement(value: $0, unit: .seconds)
            }
            
            transferType = try container.decodeIfPresent(String.self, forKey: .transferType)
        }
    }
}
