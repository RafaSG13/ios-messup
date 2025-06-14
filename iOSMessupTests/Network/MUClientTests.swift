////
////  MUClientTests.swift
////  iOSMessup
////
////  Created by Rafael Serrano Gamarra on 14/4/25.
////
//
//
//import Testing
//@testable import iOSMessup
//
//final class MUClientTests {
//    
//    private var client: MUClient!
//    private var tokenStore: MockTokenStore!
//    private var baseURL: URL!
//    
//    override func setUp() {
//        super.setUp()
//        baseURL = URL(string: "https://example.com")!
//        tokenStore = MockTokenStore()
//        client = MUClient(baseURL: baseURL, tokenStore: tokenStore)
//    }
//    
//    override func tearDown() {
//        client = nil
//        tokenStore = nil
//        baseURL = nil
//        super.tearDown()
//    }
//    
//    func testSend_SuccessfulResponse() async throws {
//        // Arrange
//        let mockResponseData = """
//        {
//            "id": 1,
//            "name": "Test"
//        }
//        """.data(using: .utf8)!
//        MockURLProtocol.requestHandler = { request in
//            let response = HTTPURLResponse(url: request.url!,
//                                           statusCode: 200,
//                                           httpVersion: nil,
//                                           headerFields: nil)!
//            return (response, mockResponseData)
//        }
//        
//        let request = MURequest(path: "/test", method: .get)
//        
//        // Act
//        let response: MockResponse = try await client.send(request, as: MockResponse.self)
//        
//        // Assert
//        expect(response.id).to(equal(1))
//        expect(response.name).to(equal("Test"))
//    }
//    
//    func testSend_UnauthorizedTriggersTokenRefresh() async throws {
//        // Arrange
//        tokenStore.refreshToken = "mockRefreshToken"
//        MockURLProtocol.requestHandler = { request in
//            if request.url?.path == "/test" {
//                let response = HTTPURLResponse(url: request.url!,
//                                               statusCode: 401,
//                                               httpVersion: nil,
//                                               headerFields: nil)!
//                return (response, Data())
//            } else if request.url?.path == "/refresh" {
//                let response = HTTPURLResponse(url: request.url!,
//                                               statusCode: 200,
//                                               httpVersion: nil,
//                                               headerFields: nil)!
//                let responseData = """
//                {
//                    "accessToken": "newAccessToken"
//                }
//                """.data(using: .utf8)!
//                return (response, responseData)
//            }
//            throw URLError(.badURL)
//        }
//        
//        let request = MURequest(path: "/test", method: .get)
//        
//        // Act
//        do {
//            _ = try await client.send(request, as: MockResponse.self)
//        } catch {
//            fail("Request should not fail after token refresh")
//        }
//        
//        // Assert
//        expect(tokenStore.accessToken).to(equal("newAccessToken"))
//    }
//}
//
//// MARK: - Mock Classes
//
//private final class MockTokenStore: TokenStore {
//    var accessToken: String?
//    var refreshToken: String?
//    
//    func cleanTokens() {
//        accessToken = nil
//        refreshToken = nil
//    }
//}
//
//private struct MockResponse: Decodable {
//    let id: Int
//    let name: String
//}
//
//private final class MockURLProtocol: URLProtocol {
//    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
//    
//    override class func canInit(with request: URLRequest) -> Bool {
//        return true
//    }
//    
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        return request
//    }
//    
//    override func startLoading() {
//        guard let handler = MockURLProtocol.requestHandler else {
//            fatalError("Handler is unavailable.")
//        }
//        
//        do {
//            let (response, data) = try handler(request)
//            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
//            client?.urlProtocol(self, didLoad: data)
//            client?.urlProtocolDidFinishLoading(self)
//        } catch {
//            client?.urlProtocol(self, didFailWithError: error)
//        }
//    }
//    
//    override func stopLoading() {}
//}
