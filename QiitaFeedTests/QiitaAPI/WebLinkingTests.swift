//
//  WebLinkingTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class LinkTests: XCTestCase {
    var link:Link!

    override func setUp() {
        super.setUp()
        link = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    }

    func testHasURI() {
        XCTAssertEqual(link.uri, "/style.css")
    }

    func testHasParameters() {
        XCTAssertEqual(link.parameters, ["rel": "stylesheet", "type": "text/css"])
    }

    func testHasUnorderedParameters() {
        XCTAssertEqual(link.parameters, ["type": "text/css", "rel": "stylesheet"])
    }

    func testHasRelationType() {
        XCTAssertEqual(link.relationType, "stylesheet")
    }

    func testHasReverseRelationType() {
        let link = Link(uri: "/style.css", parameters: ["rev": "document"])
        XCTAssertEqual(link.reverseRelationType, "document")
    }

    func testHasType() {
        XCTAssertEqual(link.type, "text/css")
    }
}

class LinkHeaderTests: XCTestCase {
    var link:Link!

    override func setUp() {
        super.setUp()
        link = Link(uri: "/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
    }

    func testConversionToHeader() {
        XCTAssertEqual(link.header, "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
    }

    func testParsingHeader() {
        let parsedLink = Link(header: "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
        XCTAssertEqual(parsedLink, link)
    }

    func testParsingLinksHeader() {
        let links = parseLink(header: "</style.css>; rel=\"stylesheet\"; type=\"text/css\"")
        XCTAssertEqual(links[0], link)
        XCTAssertEqual(links.count, 1)
    }

    func testResponseLinks() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\"",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])

        XCTAssertEqual(response.links, [link])
    }

    func testResponseFindLinkParameters() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\", </style.css>; rel=\"stylesheet\"; type=\"text/css\"",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
        let foundLink = response.findLink(["rel": "stylesheet"])!

        XCTAssertEqual(foundLink, link)
    }

    func testResponseFindNoLinkParameters() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "random; text",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let foundLink = response.findLink(["rel": "stylesheet"])

        XCTAssertNil(foundLink)
    }

    func testResponseNoLinkParameters() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link2": "random text",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let foundLink = response.findLink(["rel": "stylesheet"])

        XCTAssertNil(foundLink)
    }

    func testResponseNotALinkParameters() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "random text",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let foundLink = response.findLink(["rel": "stylesheet"])

        XCTAssertNil(foundLink)
    }

    func testResponseFindAnotherLinkParameters() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\", </style.css>; rel=\"stylesheet\"; type=\"text/css\"",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let foundLink = response.findLink(["rel": "someImage"])

        XCTAssertNil(foundLink)
    }

    func testResponseFindLinkRelation() {
        let url = URL(string: "http://test.com/")!
        let headers = [
            "Link": "</style.css>; rel=\"stylesheet\"; type=\"text/css\", </style.css>; rel=\"stylesheet\"; type=\"text/css\"",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
        let link = Link(uri: "http://test.com/style.css", parameters: ["rel": "stylesheet", "type": "text/css"])
        let foundLink = response.findLink(relation: "stylesheet")!

        XCTAssertEqual(foundLink, link)
    }
}


class LinkWihoutParamentersTests: XCTestCase {
    var link:Link!

    override func setUp() {
        super.setUp()
        link = Link(uri: "/style.css")
    }

    func testHasURI() {
        XCTAssertEqual(link.uri, "/style.css")
    }

    func testHasParameters() {
        XCTAssertEqual(link.parameters, [:])
    }
}


class EmptyHeaderLinkTests: XCTestCase {
    var link:Link!

    override func setUp() {
        super.setUp()
        link = Link(header: String())
    }

    func testHasURI() {
        XCTAssertEqual(link.uri, "")
    }

    func testHasParameters() {
        XCTAssertEqual(link.parameters, [:])
    }

}
