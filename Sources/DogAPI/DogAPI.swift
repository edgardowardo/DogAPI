import Foundation

private struct DogBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

private struct DogImagesResponse: Codable {
    let message: [String]
    let status: String
}

public protocol DogAPIProviding {
    func fetchBreeds() async throws -> [DogBreed]
    func fetchImages(from breed: DogBreed, count: Int) async throws -> [URL]
}

public class DogAPI: DogAPIProviding {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL = URL(string: "https://dog.ceo/api")!, session: URLSession = .shared) {
        self.session = session
        self.baseURL = baseURL
    }

    public func fetchBreeds() async throws -> [DogBreed] {
        let url = baseURL.appendingPathComponent("breeds/list/all")
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DogBreedsResponse.self, from: data)
        return DogAPI.flattenBreedsDict(decoded.message)
    }
    
    public func fetchImages(from breed: DogBreed, count: Int = 10) async throws -> [URL] {
        let url = baseURL.appendingPathComponent("breed/\(breed.path)/images/random/\(count)")
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DogImagesResponse.self, from: data)
        return decoded.message.map { URL(string: $0)! }
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
    
