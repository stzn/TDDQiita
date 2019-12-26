//
//  URLSessionHTTPClientTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

#if DEBUG
extension HTTPClientError: Equatable {
    public static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        switch (lhs, rhs) {
        case (.noResponse, .noResponse),
             (.noData, .noData):
            return true
        case (.invalidStatusCode(let lCode), .invalidStatusCode(let rCode)):
            return lCode == rCode
        case (.unknown(let lError), .unknown(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        case (.unknown, .noResponse),
             (.unknown, .invalidStatusCode),
             (.unknown, .noData),
             (.invalidStatusCode, .noResponse),
             (.invalidStatusCode, .noData),
             (.invalidStatusCode, .unknown),
             (.noData, .noResponse),
             (.noData, .invalidStatusCode),
             (.noData, .unknown),
             (.noResponse, .invalidStatusCode),
             (.noResponse, .noData),
             (.noResponse, .unknown):
            return false
        }
    }
}
#endif

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()

        URLProtocolStub.startInterceptRequests()
    }

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.stopInterceptRequests()
    }

    func testGetRequest() {
        let url = anyURL
        let client = makeTestTarget()
        let exp = expectation(description: "testGetRequest")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }

        client.get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }

    func testGet() {
        let data = anyData
        let error = anyNSError

        let testCases: [(result: URLSessionHTTPClient.Result, data: Data?, response: HTTPURLResponse?, error: Error?)] = [
            (.success(data), data, anyHTTPURLResponse, nil),
            (.failure(.unknown(error)), anyData, anyHTTPURLResponse, error),
            (.failure(.unknown(error)), nil, nil, error)
        ]
        for testCase in testCases {
            expect(testCase.result, data: testCase.data, response: testCase.response, error: testCase.error)
        }
    }

    private func makeTestTarget(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let target = URLSessionHTTPClient()
        trackForMemoryLeaks(target, file: file, line: line)
        return target
    }

    private func expect(_ expected: URLSessionHTTPClient.Result,
                        data: Data?, response: HTTPURLResponse?, error:Error?,
                        file: StaticString = #file,
                        line: UInt = #line) {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let client = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expectSuccess")

        var received: URLSessionHTTPClient.Result!
        client.get(from: anyURL) {
            received = $0
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        switch (received, expected) {
        case (.success(let received), .success(let expected)):
            XCTAssertEqual(received, expected, file: file, line:line)
        case (.failure(let received), .failure(let expected)):
            XCTAssertEqual(received as NSError, expected as NSError, file: file, line:line)
        default:
            XCTFail("expect \(expected), but got \(received!)")
        }
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest)-> Void) {
            requestObserver = observer
        }

        static func startInterceptRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
