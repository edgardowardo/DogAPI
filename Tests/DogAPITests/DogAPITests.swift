import Testing
import Foundation
@testable import DogAPI

@Suite("DogAPI Dog CEO JSON Parsing Tests", .serialized)
struct DogAPIBreedListTests {

    @Test("fetchBreeds decodes and flattens breeds and subbreeds correctly")
    func testFetchBreedsParsesCorrectly() async throws {
        let data = MockDogJSON.breedsList.data(using: .utf8)
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        let breeds = try await api.fetchBreeds()

        #expect(breeds.contains(DogBreed(base: nil, name: "bulldog", subBreeds: ["boston", "english", "french"].map { DogBreed(base: "bulldog", name: $0, subBreeds: nil)})), "Should contain bulldog and sub breeds - english")
        #expect(breeds.contains(DogBreed(base: nil, name: "australian", subBreeds: ["kelpie", "shepherd"].map { DogBreed(base: "australian", name: $0, subBreeds: nil)})), "Should contain australian - kelpie")
        #expect(breeds.contains(DogBreed(base: nil, name: "affenpinscher", subBreeds: nil)), "Should contain affenpinscher (no subbreed)")
        #expect(!breeds.contains(DogBreed(base: nil, name: "unicorn", subBreeds: [])), "Should not contain non-existent breed")
        #expect(breeds.count == 107, "Should load a substantial number of breeds+subbreeds")
    }

    @Test("fetchBreeds throws on invalid data")
    func testFetchBreedsThrowsOnInvalidData() async {
        let data = Data([0x00, 0x01, 0x02])
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        do {
            _ = try await api.fetchBreeds()
            #expect(Bool(false), "Should throw on bad data")
        } catch {
            #expect(true)
        }
    }
    
    @Test("fetchImages decodes hound URLs correctly")
    func testFetchImagesParsesCorrectly() async throws {
        let data = MockDogJSON.houndList.data(using: .utf8)
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        let breed = DogBreed(base: nil, name: "hound", subBreeds: [])
        let images = try await api.fetchImages(from: breed, count: 3)

        let expectedURLs = [
            "https://images.dog.ceo/breeds/hound-afghan/n02088094_13145.jpg",
            "https://images.dog.ceo/breeds/hound-afghan/n02088094_3982.jpg",
            "https://images.dog.ceo/breeds/hound-afghan/n02088094_4195.jpg"
        ].compactMap(URL.init)

        #expect(images == expectedURLs, "Should decode exactly the three expected URLs")
    }

    @Test("fetchImages throws on invalid data")
    func testFetchImagesThrowsOnInvalidData() async {
        let data = Data([0x00, 0x01, 0x02])
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        do {
            _ = try await api.fetchImages(from: DogBreed(base: nil, name: "hound", subBreeds: []), count: 3)
            #expect(Bool(false), "Should throw on bad data")
        } catch {
            #expect(true)
        }
    }
    
    
    @Test("fetchImage decodes hound URL correctly")
    func testFetchImageParsesCorrectly() async throws {
        let data = MockDogJSON.houndSingle.data(using: .utf8)
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        let breed = DogBreed(base: nil, name: "hound", subBreeds: [])
        let images = try await api.fetchImage(from: breed)
        let expectedURL = URL(string: "https://images.dog.ceo/breeds/hound-english/n02089973_255.jpg")!
        #expect(images == expectedURL, "Should decode exactly the expected URL")
    }

    @Test("fetchImage throws on invalid data")
    func testFetchImageThrowsOnInvalidData() async {
        let data = Data([0x00, 0x01, 0x02])
        let session = makeMockSession(data)
        let api = DogAPI(session: session)
        do {
            _ = try await api.fetchImage(from: DogBreed(base: nil, name: "hound", subBreeds: []))
            #expect(Bool(false), "Should throw on bad data")
        } catch {
            #expect(true)
        }
    }
    
}

//
// MARK: Helpers specifically for mocking the session data
//
private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var testData: Data?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        if let data = MockURLProtocol.testData {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private func makeMockSession(_ data: Data?) -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    MockURLProtocol.testData = data
    return URLSession(configuration: config)
}

