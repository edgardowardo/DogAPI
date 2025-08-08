import Testing
import Foundation
@testable import DogAPI

@Suite("DogAPI Dog CEO JSON Parsing Tests")
struct DogAPIBreedListTests {
    // Helper for creating session that returns the static mockBreedsJSON
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

    private func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.testData = MockDogData.mockBreedsJSON.data(using: .utf8)
        return URLSession(configuration: config)
    }

    @Test("fetchBreeds decodes and flattens breeds and subbreeds correctly")
    func testFetchBreedsParsesCorrectly() async throws {
        let session = makeMockSession()
        let api = DogAPI(session: session)
        let breeds = try await api.fetchBreeds()

        #expect(breeds.contains(DogBreed(main: "bulldog", sub: "english")), "Should contain bulldog - english")
        #expect(breeds.contains(DogBreed(main: "australian", sub: "kelpie")), "Should contain australian - kelpie")
        #expect(breeds.contains(DogBreed(main: "affenpinscher", sub: nil)), "Should contain affenpinscher (no subbreed)")
        #expect(!breeds.contains(DogBreed(main: "unicorn", sub: nil)), "Should not contain non-existent breed")
        #expect(breeds.count == 162, "Should load a substantial number of breeds+subbreeds")
    }

    @Test("fetchBreeds throws on invalid data")
    func testFetchBreedsThrowsOnInvalidData() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.testData = Data([0x00, 0x01, 0x02])
        let api = DogAPI(session: URLSession(configuration: config))
        do {
            _ = try await api.fetchBreeds()
            #expect(Bool(false), "Should throw on bad data")
        } catch {
            #expect(true)
        }
    }
}

