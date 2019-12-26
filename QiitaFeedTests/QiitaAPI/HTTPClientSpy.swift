//
//  HTTPClientSpy.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
@testable import QiitaFeed

final class DummyHTTPClientTask: HTTPClientTask {
    func cancel() {}
}

final class HTTPClientSpy: HTTPClient {
    var receivedValues: [(url: URL, completion: Completion)] = []

    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        receivedValues.append((url, completion))
        return DummyHTTPClientTask()
    }

    func completeWith(result: HTTPClient.Result, at index: Int = 0) {
        receivedValues[index].completion(result)
    }
}
