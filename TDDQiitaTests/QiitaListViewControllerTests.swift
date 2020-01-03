//
//  QiitaListViewControllerTests.swift
//  QiitaFeediOSTests
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeed
import QiitaFeediOS
@testable import TDDQiita

// swiftlint:disable:next type_body_length
class QiitaListViewControllerTests: XCTestCase {
    func testInitNotDataLoaded() {
        let (_, loader) = makeTestTarget()
        XCTAssertEqual(loader.receivedCompletions.count, 0)
    }

    func testViewDidLoadDataLoaded() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedCompletions.count, 1)
    }

    func testShowIndicatorWhenDataLoading() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, true)
        loader.complete(with: .success([anyQiitaItem]), at: 0)
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        viewController.simulateUserRefreshAction()
        XCTAssertEqual(viewController.isReloadingIndicatorShowing, true)
        loader.complete(with: .success([anyQiitaItem]), at: 1)
        XCTAssertEqual(viewController.isReloadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 2)

        viewController.simulateLoadMoreAction()
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, true)
        loader.complete(with: .success([]), at: 2)
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 3)
    }

    func testHideIndicatorEvenErrorOccured() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 0)
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        viewController.simulateUserRefreshAction()
        XCTAssertEqual(viewController.isReloadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(viewController.isReloadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 2)

        viewController.simulateUserRefreshAction()
        loader.complete(with: .success([anyQiitaItem]), at: 2)
        XCTAssertEqual(loader.receivedCompletions.count, 3)

        viewController.simulateLoadMoreAction()
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 3)
        XCTAssertEqual(viewController.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 4)
    }

    func testItemRenderedOnSuccess() {
        let item = anyQiitaItem
        let item2 = anyQiitaItem
        let item3 = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        assertThat(viewController: viewController, isRendering: [])

        loader.complete(with: .success([item]))
        assertThat(viewController: viewController, isRendering: [item])

        loader.complete(with: .success([item2, item3]))
        assertThat(viewController: viewController, isRendering: [item, item2, item3])
    }

    func testItemRenderedDoesNotChangeCurrentRenderingStateOnError() {
        let item = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item]))
        assertThat(viewController: viewController, isRendering: [item])

        loader.complete(with: .failure(anyNSError))
        assertThat(viewController: viewController, isRendering: [item])
    }

    func testErrorMessageRenderedOnError() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertNil(viewController.errorMesage)

        loader.complete(with: .failure(anyNSError))
        XCTAssertNotNil(viewController.errorMesage)

        viewController.simulateUserRefreshAction()
        XCTAssertNil(viewController.errorMesage)
    }

    func testImageRenderedWhenCellVisible() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (viewController, loader) = makeTestTarget()

        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        viewController.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL])
        viewController.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL, item1.userImageURL!])
    }

    func testImageRequestCanceledWhenCellNotVisibleAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (viewController, loader) = makeTestTarget()

        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))

        let view0 = viewController.simulateRenderedViewNotVisible(at: 0)
        loader.completeImageLoad(with: .success(anyImageData), at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL])
        XCTAssertEqual(view0?.userImage, nil)

        let view1 = viewController.simulateRenderedViewNotVisible(at: 1)
        loader.completeImageLoad(with: .success(anyImageData), at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL, item1.userImageURL!])
        XCTAssertEqual(view1?.userImage, nil)
    }

    func testShowIndicatorWhenImageLoading() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))
        let view0 = viewController.simulateRenderedViewVisible(at: 0)!
        let view1 = viewController.simulateRenderedViewVisible(at: 1)!

        XCTAssertEqual(view0.isLoadingIndicatorShowing, true)
        XCTAssertEqual(view1.isLoadingIndicatorShowing, true)

        loader.completeImageLoad(with: .success(nil), at: 0)
        XCTAssertEqual(view0.isLoadingIndicatorShowing, false)

        loader.completeImageLoad(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(view1.isLoadingIndicatorShowing, false)
    }

    func testImageRenderFromURLWhenCellVisible() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))

        let view0 = viewController.simulateRenderedViewVisible(at: 0)!
        let view1 = viewController.simulateRenderedViewVisible(at: 1)!
        XCTAssertEqual(view0.userImage, .none)
        XCTAssertEqual(view1.userImage, .none)

        let image0 = UIImage.make(color: .blue).pngData()!
        loader.completeImageLoad(with: .success(image0), at: 0)
        XCTAssertEqual(view0.userImage, image0)
        XCTAssertEqual(view1.userImage, .none)

        let image1 = UIImage.make(color: .red).pngData()!
        loader.completeImageLoad(with: .success(image1), at: 1)
        XCTAssertEqual(view0.userImage, image0)
        XCTAssertEqual(view1.userImage, image1)
    }

    func testNoUserImageRenderWhenInvalidDataLoaded() {
        let (viewController, loader) = makeTestTarget()

        viewController.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))

        let view0 = viewController.simulateRenderedViewVisible(at: 0)
        loader.completeImageLoad(with: .success(Data("invalid data".utf8)), at: 0)
        XCTAssertEqual(view0?.userImage, viewController.noUserImageData)
    }

    func testNoUserImageRenderWhenErrorOccured() {
        let (viewController, loader) = makeTestTarget()

        viewController.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem]))

        let view0 = viewController.simulateRenderedViewVisible(at: 0)
        loader.completeImageLoad(with: .failure(anyNSError), at: 0)
        XCTAssertEqual(view0?.userImage, viewController.noUserImageData)
    }

    func testNotImageRenderWhenCellNotVisibleAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (viewController, loader) = makeTestTarget()

        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))

        viewController.simulateRenderedViewNotVisible(at: 0)
        loader.completeImageLoad(with: .success(anyImageData), at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL])

        viewController.simulateRenderedViewNotVisible(at: 1)
        loader.completeImageLoad(with: .success(anyImageData), at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL, item1.userImageURL])
    }

    func testImagePreloadWhenCellNearVisible() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        viewController.simulateRenderedViewNearVisible(at: 0)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL!])

        viewController.simulateRenderedViewNearVisible(at: 1)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL!, item1.userImageURL!])
    }

    func testNotImagePreloadWhenCellNotNearAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        viewController.simulateRenderedViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL!])

        viewController.simulateRenderedViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL!, item1.userImageURL!])
    }

    func testLoadMoreReqeustNextDataLoaded() {
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        loader.complete(with: .success([anyQiitaItem]))

        viewController.simulateLoadMoreAction()
        XCTAssertEqual(loader.receivedCompletions.count, 2)
    }

    func testLoadMoreRenderNextDataLoaded() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.numberOfRows, 0)

        loader.complete(with: .success([item0]), at: 0)
        viewController.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(viewController.numberOfRows, 1)

        viewController.simulateLoadMoreAction()
        loader.complete(with: .success([item1]), at: 1)
        viewController.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(viewController.numberOfRows, 2)

        assertThat(viewController: viewController, isRendering: [item0, item1])
    }

    func testLoadMoreNotRenderNextErrorOccured() {
        let item = anyQiitaItem
        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.numberOfRows, 0)
        loader.complete(with: .success([item]), at: 0)
        XCTAssertEqual(viewController.numberOfRows, 1)

        viewController.simulateLoadMoreAction()
        loader.complete(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(viewController.numberOfRows, 1)

        assertThat(viewController: viewController, hasViewConfiredFor: item, at: 0)
    }

    func testRefreshRenderDataRefreshed() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let item2 = anyQiitaItem

        let (viewController, loader) = makeTestTarget()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.numberOfRows, 0)

        loader.complete(with: .success([item0]), at: 0)
        viewController.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(viewController.numberOfRows, 1)

        viewController.simulateLoadMoreAction()
        loader.complete(with: .success([item1]), at: 1)
        viewController.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(viewController.numberOfRows, 2)

        viewController.simulateUserRefreshAction()
        loader.complete(with: .success([item2]), at: 0)
        viewController.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(viewController.numberOfRows, 1)

        assertThat(viewController: viewController, isRendering: [item2])
    }

    // MARK: Helpers
    private func makeTestTarget(
        file: StaticString = #file, line: UInt = #line) -> (QiitaListViewController, QiitaLoaderSpy) {
        let loader = QiitaLoaderSpy()
        let viewController = QiitaListUIComposer.composeQiitaListViewController(listLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(viewController, file: file, line: line)
        return (viewController, loader)
    }

    private var anyImageData: Data {
        UIImage.make(color: .black).pngData()!
    }
}
