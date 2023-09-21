import Foundation

struct GraphQLResponse<Model: Decodable>: Decodable {
    var data: Model
}
