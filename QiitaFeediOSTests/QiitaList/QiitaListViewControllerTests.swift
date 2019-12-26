//
//  QiitaListViewControllerTests.swift
//  QiitaFeediOSTests
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeed
@testable import QiitaFeediOS

class QiitaListViewControllerTests: XCTestCase {
    func testInitNotDataLoaded() {
        let (_, loader) = makeTestTarget()
        XCTAssertEqual(loader.receivedCompletions.count, 0)
    }

    func testViewDidLoadDataLoaded() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedCompletions.count, 1)
    }

    func testShowIndicatorWhenDataLoading() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.isLoadingIndicatorShowing, true)
        loader.complete(with: .success([anyQiitaItem]), at: 0)
        XCTAssertEqual(vc.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        vc.simulateUserRefreshAction()
        XCTAssertEqual(vc.isReloadingIndicatorShowing, true)
        loader.complete(with: .success([anyQiitaItem]), at: 1)
        XCTAssertEqual(vc.isReloadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 2)

        vc.simulateLoadMoreAction()
        XCTAssertEqual(vc.isLoadingIndicatorShowing, true)
        loader.complete(with: .success([]), at: 2)
        XCTAssertEqual(vc.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 3)
    }

    func testHideIndicatorEvenErrorOccured() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.isLoadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 0)
        XCTAssertEqual(vc.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        vc.simulateUserRefreshAction()
        XCTAssertEqual(vc.isReloadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(vc.isReloadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 2)

        vc.simulateUserRefreshAction()
        loader.complete(with: .success([anyQiitaItem]), at: 2)

        vc.simulateLoadMoreAction()
        XCTAssertEqual(vc.isLoadingIndicatorShowing, true)
        loader.complete(with: .failure(anyNSError), at: 3)
        XCTAssertEqual(vc.isLoadingIndicatorShowing, false)
        XCTAssertEqual(loader.receivedCompletions.count, 4)
    }

    func testItemRenderedOnSuccess() {
        let item = anyQiitaItem
        let item2 = anyQiitaItem
        let item3 = anyQiitaItem

        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        assertThat(vc: vc, isRendering: [])

        loader.complete(with: .success([item]))
        assertThat(vc: vc, isRendering: [item])

        loader.complete(with: .success([item, item2, item3]))
        assertThat(vc: vc, isRendering: [item, item2, item3])
    }

    func testItemRenderedDoesNotChangeCurrentRenderingStateOnError() {
        let item = anyQiitaItem

        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        loader.complete(with: .success([item]))
        assertThat(vc: vc, isRendering: [item])

        loader.complete(with: .failure(anyNSError))
        assertThat(vc: vc, isRendering: [item])
    }

    func testErrorMessageRenderedOnError() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertNil(vc.errorMesage)

        loader.complete(with: .failure(anyNSError))
        XCTAssertNotNil(vc.errorMesage)

        vc.simulateUserRefreshAction()
        XCTAssertNil(vc.errorMesage)
    }

    func testImageRenderedWhenCellVisible() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (vc, loader) = makeTestTarget()

        vc.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        vc.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL])
        vc.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL, item1.userImageURL!])
    }

    func testImageRequestCanceledWhenCellNotVisibleAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (vc, loader) = makeTestTarget()

        vc.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))

        let view0 = vc.simulateRenderedViewNotVisible(at: 0)
        loader.completeImageLoad(with: .success(anyImageData), at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL])
        XCTAssertEqual(view0?.userImage, vc.noUserImageData)

        let view1 = vc.simulateRenderedViewNotVisible(at: 1)
        loader.completeImageLoad(with: .success(anyImageData), at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL, item1.userImageURL!])
        XCTAssertEqual(view1?.userImage, vc.noUserImageData)
    }

    func testShowIndicatorWhenImageLoading() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))
        let view0 = vc.simulateRenderedViewVisible(at: 0)!
        let view1 = vc.simulateRenderedViewVisible(at: 1)!

        XCTAssertEqual(view0.isLoadingIndicatorShowing, true)
        XCTAssertEqual(view1.isLoadingIndicatorShowing, true)

        loader.completeImageLoad(with: .success(nil), at: 0)
        XCTAssertEqual(view0.isLoadingIndicatorShowing, false)

        loader.completeImageLoad(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(view1.isLoadingIndicatorShowing, false)
    }

    func testImageRenderFromURLWhenCellVisible() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))

        let view0 = vc.simulateRenderedViewVisible(at: 0)!
        let view1 = vc.simulateRenderedViewVisible(at: 1)!
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
        let (vc, loader) = makeTestTarget()

        vc.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem, anyQiitaItem]))

        let view0 = vc.simulateRenderedViewVisible(at: 0)
        loader.completeImageLoad(with: .success(Data("invalid data".utf8)), at: 0)
        XCTAssertEqual(view0?.userImage, vc.noUserImageData)
    }

    func testNoUserImageRenderWhenErrorOccured() {
        let (vc, loader) = makeTestTarget()

        vc.loadViewIfNeeded()
        loader.complete(with: .success([anyQiitaItem]))

        let view0 = vc.simulateRenderedViewVisible(at: 0)
        loader.completeImageLoad(with: .failure(anyNSError), at: 0)
        XCTAssertEqual(view0?.userImage, vc.noUserImageData)
    }

    func testNotImageRenderWhenCellNotVisibleAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem
        let (vc, loader) = makeTestTarget()

        vc.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))

        vc.simulateRenderedViewNotVisible(at: 0)
        loader.completeImageLoad(with: .success(anyImageData), at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL])

        vc.simulateRenderedViewNotVisible(at: 1)
        loader.completeImageLoad(with: .success(anyImageData), at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL, item1.userImageURL])
    }

    func testImagePreloadWhenCellNearVisible() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        vc.simulateRenderedViewNearVisible(at: 0)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL!])

        vc.simulateRenderedViewNearVisible(at: 1)
        XCTAssertEqual(loader.receivedURLs, [item0.userImageURL!, item1.userImageURL!])
    }

    // TODO: タイミングによってはキャンセル時にデータの取得が終わっているのではないか？
    func testNotImagePreloadWhenCellNotNearAnymore() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        loader.complete(with: .success([item0, item1]))
        vc.simulateRenderedViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL!])

        vc.simulateRenderedViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.canceledURLs, [item0.userImageURL!, item1.userImageURL!])
    }

    func testLoadMoreReqeustNextDataLoaded() {
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedCompletions.count, 1)

        loader.complete(with: .success([anyQiitaItem]))

        vc.simulateLoadMoreAction()
        XCTAssertEqual(loader.receivedCompletions.count, 2)
    }

    func testLoadMoreRenderNextDataLoaded() {
        let item0 = anyQiitaItem
        let item1 = anyQiitaItem

        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 0)

        loader.complete(with: .success([item0]), at: 0)
        vc.simulateRenderedViewVisible(at: 0)
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 1)

        vc.simulateLoadMoreAction()
        loader.complete(with: .success([item1]), at: 1)
        vc.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 2)

        assertThat(vc: vc, isRendering: [item0, item1])
    }

    func testLoadMoreNotRenderNextErrorOccured() {
        let item = anyQiitaItem
        let (vc, loader) = makeTestTarget()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 0)
        loader.complete(with: .success([item]), at: 0)
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 1)

        vc.simulateLoadMoreAction()
        loader.complete(with: .failure(anyNSError), at: 1)
        XCTAssertEqual(vc.numberOfRows(inSection: vc.sectionForItems), 1)

        assertThat(vc: vc, hasViewConfiredFor: item, at: 0)
    }

    // MARK: Helpers
    private func makeTestTarget(file: StaticString = #file, line: UInt = #line) -> (QiitaListViewController, QiitaLoaderSpy) {
        let loader = QiitaLoaderSpy()
        let vc = QiitaListViewController.instance(loader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(vc, file: file, line: line)
        return (vc, loader)
    }

    private var anyImageData: Data {
        UIImage.make(color: .black).pngData()!
    }
}
