import Foundation

public struct DogBreed: Equatable, Codable {
    public let base: String?
    public let name: String
    public let subBreeds: [DogBreed]?
}
