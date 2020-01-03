//
//  HTTPClientStub.swift
//  TDDQiitaTests
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeed

final class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> HTTPClient.Result
    init(_ stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }

    private class Task: HTTPClientTask {
        func cancel() {}
    }

    func get(from url: URL, completion: @escaping HTTPClient.Completion) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }

    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }

    static var offline: HTTPClientStub {
        HTTPClientStub { _ in .failure(.unknown(anyNSError)) }
    }
}
