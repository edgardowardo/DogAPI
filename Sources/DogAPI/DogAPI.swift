import Foundation

public struct DogBreed: Equatable, Codable {
    public let main: String
    public let sub: String?
    public var name: String { (sub ?? "") + main }
}

private struct DogBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

public protocol DogAPIProviding {
    func fetchBreeds() async throws -> [DogBreed]
}

public class DogAPI: DogAPIProviding {
    private let session: URLSession
    private let endpoint = URL(string: "https://dog.ceo/api/breeds/list/all")!
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchBreeds() async throws -> [DogBreed] {
        let (data, _) = try await session.data(from: endpoint)
        let decoded = try JSONDecoder().decode(DogBreedsResponse.self, from: data)
        return DogAPI.flattenBreedsDict(decoded.message)
    }
    
    private static func flattenBreedsDict(_ dict: [String: [String]]) -> [DogBreed] {
        let list = dict.flatMap { main, subs in
            (subs.isEmpty ? [DogBreed(main: main, sub: nil)] : subs.map { DogBreed(main: main, sub: $0) })
        }
        return list.sorted { lhs, rhs in
            lhs.main < rhs.main || (lhs.main == rhs.main && (lhs.sub ?? "") < (rhs.sub ?? ""))
        }
    }
}
    
