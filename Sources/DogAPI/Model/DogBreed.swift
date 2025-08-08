import Foundation

public struct DogBreed: Equatable, Codable {
    public let main: String
    public let sub: String?
    public var path: String { main + (sub == nil ? "" : "/") + (sub ?? "") }
}
