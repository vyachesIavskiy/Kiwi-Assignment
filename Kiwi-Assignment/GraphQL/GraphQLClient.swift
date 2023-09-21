import Foundation
import OSLog

final class GraphQLClient {
    private let urlSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        return URLSession(configuration: configuration)
    }()
    
    private let logger = Logger(subsystem: "com.breath.Kiwi-Assignment.graphql-client", category: "Network")
    
    func fetch<Model: Decodable>(_ modelType: Model.Type, request: GraphQLRequest) async throws -> Model {
        logger.debug("Fetching '\(modelType)' for '\(request.debugDescription)'")
        let data = try await data(from: request)
        let response = try decode(modelType, from: data)
        return response.data
    }
}

private extension GraphQLClient {
    func data(from request: GraphQLRequest) async throws -> Data {
        let urlRequest = buildURLRequest(from: request)
        return try await data(from: urlRequest)
    }
    
    func data(from request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        logger.debug("Received \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.responseIsNotHTTPResponse
        }
        
        logger.debug("Received URL response with status code: \(httpResponse.statusCode)")
        
        guard (200...300).contains(httpResponse.statusCode) else {
            let responseStringRepresentation = String(data: data, encoding: .utf8)
            throw Error.badResponse(with: responseStringRepresentation)
        }
        
        return data
    }
    
    func buildURLRequest(from request: GraphQLRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.path)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body.data(using: .utf8)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    func decode<Model: Decodable>(_: Model.Type, from data: Data) throws -> GraphQLResponse<Model> {
        let decoder = JSONDecoder()
        return try decoder.decode(GraphQLResponse<Model>.self, from: data)
    }
}

private extension GraphQLClient {
    enum Error: Swift.Error {
        case responseIsNotHTTPResponse
        case badResponse(with: String?)
    }
}

extension GraphQLClient.Error: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .responseIsNotHTTPResponse:
            return "[This should never happen] URLSession returned URLResponse which is not an HTTPURLResponse"
            
        case let .badResponse(with: message):
            var result = "Request returned an error"
            if let message {
                result.append(": \(message)")
            }
            return result
        }
    }
}
