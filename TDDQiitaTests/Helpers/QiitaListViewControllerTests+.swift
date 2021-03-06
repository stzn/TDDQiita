//
//  QiitaListViewControllerTests+.swift
//  QiitaFeediOSTests
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeediOS

extension QiitaListViewControllerTests {
    func assertThat(viewController: QiitaListViewController, isRendering items: [QiitaItem],
                    file: StaticString = #file, line: UInt = #line) {
        let numberOfRows = viewController.numberOfRows
        guard numberOfRows == items.count else {
            XCTFail("\(items.count) is not equal to \(numberOfRows)", file: file, line: line)
            return
        }
        items.enumerated().forEach { index, item in
            assertThat(viewController: viewController, hasViewConfiredFor: item, at: index, file: file, line: line)
        }
    }

    func assertThat(viewController: QiitaListViewController, hasViewConfiredFor item: QiitaItem, at index: Int,
                    file: StaticString = #file, line: UInt = #line) {
        let view = viewController.renderedView(at: index)
        guard let cell = view else {
            XCTFail("Expected \(QiitaListCell.self), but \(String(describing: view))")
            return
        }
        XCTAssertEqual(cell.title, item.title, file: file, line: line)
        XCTAssertEqual(cell.userName, item.user?.githubLoginName, file: file, line: line)
        XCTAssertEqual(cell.likeCount, String(item.likesCount), file: file, line: line)
        XCTAssertEqual(cell.commentCount, String(item.commentsCount), file: file, line: line)
        XCTAssertEqual(cell.updatedAt, item.updatedAt.string(format: .japaneseFormat), file: file, line: line)
    }
}
