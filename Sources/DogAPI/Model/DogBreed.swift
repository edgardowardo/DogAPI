import Foundation

public struct DogBreed: Equatable, Codable, Hashable {
    public let base: String?
    public let name: String
    public let subBreeds: [DogBreed]?
    
    public init(base: String? = nil, name: String, subBreeds: [DogBreed]? = nil) {
        self.base = base
        self.name = name
        self.subBreeds = subBreeds
    }
}
