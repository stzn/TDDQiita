//
//  QiitaListViewController+.swift
//  QiitaFeediOSTests
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
@testable import QiitaFeediOS

extension QiitaListViewController {
    func simulateUserRefreshAction() {
        refreshControl.simulatePullToRefresh()
    }

    @discardableResult
    func simulateRenderedViewVisible(at index: Int) -> QiitaListCell? {
        return renderedView(at: index)
    }

    @discardableResult
    func simulateRenderedViewNotVisible(at index: Int) -> QiitaListCell? {
        guard let view = simulateRenderedViewVisible(at: index) else {
            return nil
        }
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: sectionForItems)
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
        return view
    }

    func simulateRenderedViewNearVisible(at index: Int) {
        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: sectionForItems)
        prefetchDataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateRenderedViewNotNearVisible(at index: Int) {
        simulateRenderedViewNearVisible(at: index)

        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: sectionForItems)
        prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    func simulateLoadMoreAction() {
        tableView.delegate?.scrollViewDidScroll?(tableView)
    }

    var isLoadingIndicatorShowing: Bool {
        !indicator.isHidden
    }

    var isReloadingIndicatorShowing: Bool {
        refreshControl.isRefreshing
    }

    var errorMesage: String? {
        errorView?.message
    }

    func numberOfRows(inSection section: Int) -> Int {
        tableView.numberOfRows(inSection: section)
    }

    var sectionForItems: Int { 0 }

    func renderedView(at row: Int) -> QiitaListCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: sectionForItems)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath) as? QiitaListCell
    }

    var noUserImageData: Data {
        QiitaListViewController.noUserImage.pngData()!
    }
}
