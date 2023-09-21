import Foundation

extension Models.Flight {
    struct Carrier: Decodable {
        var id: String
        var name: String
        var code: String
    }
}
