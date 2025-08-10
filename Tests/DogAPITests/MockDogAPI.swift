import Foundation
@testable import DogAPI

public class MockDogAPI: DogAPIProviding, DogBreedsMapProviding {
    public func fetchBreeds() async throws -> [DogBreed] {
        guard let data = MockDogJSON.breedsList.data(using: .utf8) else { throw DogAPIError.invalidJSON }
        let decoded = try JSONDecoder().decode(DogBreedsResponse.self, from: data)
        return DogAPI.map(decoded)
    }
    
    public func fetchImages(from breed: DogBreed, count: Int) async throws -> [URL] {
        guard let data = MockDogJSON.houndList.data(using: .utf8) else { throw DogAPIError.invalidJSON }
        let decoded = try JSONDecoder().decode(DogImagesResponse.self, from: data)
        return decoded.message.map { URL(string: $0)! }
    }
    
    public func fetchImage(from breed: DogBreed) async throws -> URL {
        guard let data = MockDogJSON.houndSingle.data(using: .utf8) else { throw DogAPIError.invalidJSON }
        let decoded = try JSONDecoder().decode(DogImageResponse.self, from: data)
        return URL(string: decoded.message.self)!
    }
}
