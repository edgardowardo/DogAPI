import Foundation

//
// MARK: Private
//
private struct DogBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

private struct DogImageResponse: Codable {
    let message: String
    let status: String
}

private struct DogImagesResponse: Codable {
    let message: [String]
    let status: String
}

private protocol DogBreedsMapProviding {
    static func map(_ response: DogBreedsResponse) -> [DogBreed]
}

private extension DogBreedsMapProviding {
    static func map(_ response: DogBreedsResponse) -> [DogBreed] {
        let list = response.message.flatMap { main, subs in
            (subs.isEmpty ? [DogBreed(base: nil, name: main, subBreeds: nil)]
             : [DogBreed(base: nil, name: main, subBreeds: subs.map {
                subName in DogBreed(base: main, name: subName, subBreeds: nil) })] )
        }
        return list.sorted { lhs, rhs in lhs.name < rhs.name }
    }
}

//
// MARK: Public
//
public protocol DogAPIProviding {
    func fetchBreeds() async throws -> [DogBreed]
    func fetchImages(from breed: DogBreed, count: Int) async throws -> [URL]
    func fetchImage(from breed: DogBreed) async throws -> URL
}

public enum DogAPIError: Error {
    case invalidJSON
}

public class DogAPI: DogAPIProviding, DogBreedsMapProviding {
    
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "https://dog.ceo/api")!, session: URLSession = .shared) {
        self.session = session
        self.baseURL = baseURL
    }

    public func fetchBreeds() async throws -> [DogBreed] {
        let url = baseURL.appendingPathComponent("breeds/list/all")
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DogBreedsResponse.self, from: data)
        return DogAPI.map(decoded)
    }
    
    public func fetchImage(from breed: DogBreed) async throws -> URL {
        let url = baseURL.appendingPathComponent("breed/\(breed.name)/images/random")
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DogImageResponse.self, from: data)
        return URL(string: decoded.message.self)!
    }
    
    public func fetchImages(from breed: DogBreed, count: Int = 10) async throws -> [URL] {
        let url = baseURL.appendingPathComponent("breed/\(breed.name)/images/random/\(count)")
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(DogImagesResponse.self, from: data)
        return decoded.message.map { URL(string: $0)! }
    }
    
}
