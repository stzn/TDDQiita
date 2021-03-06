//
//  QiitaListViewController.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

public final class QiitaListViewController: UIViewController, StoryboardInstantiatable {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var errorView: ErrorView!

    enum Section {
        case main
    }

    private var cellControllers: [QiitaListCellController] = []
    public var viewModel: QiitaListViewModel!

    private var dataSource: UITableViewDiffableDataSource<Section, DisplayQiitaItem>!
    private(set) var refreshControl = UIRefreshControl()
    private var isLoading: Bool {
        return isRefreshing || isNextLoading
    }

    private var isRefreshing: Bool {
        !refreshControl.isHidden || refreshControl.isRefreshing
    }

    private var isNextLoading: Bool {
        indicator.isAnimating
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        setupTableView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load(shouldRefresh: false)
    }

    private func setRefreshControl() {
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refreshRequest), for: .valueChanged)
    }

    @objc func refreshRequest() {
        load(shouldRefresh: true)
    }

    public func configureRefreshControl() {
        isRefreshing ?
            refreshControl.endRefreshing()
            : refreshControl.beginRefreshing()
    }

    public func configureIndicator() {
        isNextLoading ?
            indicator.stopAnimating()
            : indicator.startAnimating()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.prefetchDataSource = self
        setupDataSource()
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, DisplayQiitaItem>(
        tableView: tableView) { [weak self] _, indexPath, item in
            return self?.cellForRowAt(indexPath: indexPath, with: item)
        }
        clearDataSource()
    }

    private func clearDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisplayQiitaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func load(shouldRefresh: Bool) {
        errorView.message = nil
        if shouldRefresh {
            refresh()
        } else {
            viewModel.load()
        }
    }

    private func refresh() {
        cellControllers = []
        clearDataSource()
        viewModel.refresh()
    }

    public func updateDisplay(_ cellControllers: [QiitaListCellController]) {
        self.cellControllers.append(contentsOf: cellControllers)
        updateTableView()
    }

    private func updateTableView() {
        var snapshot = dataSource.snapshot()
        let items = cellControllers
            .map { $0.item }
            .filter { !snapshot.itemIdentifiers.contains($0) }
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    public func setError(_ error: Error) {
        errorView.message = error.localizedDescription
    }

    @discardableResult
    private func cellForRowAt(indexPath: IndexPath, with item: DisplayQiitaItem) -> UITableViewCell? {
        // swiftlint:disable:next force_cast
        return cellControllers[indexPath.row].cell(in: tableView) as! QiitaListCell
    }
}

extension QiitaListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          didEndDisplaying cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {
        cacncel(at: indexPath)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastIndexPath = tableView.indexPathsForVisibleRows?.last, !isLoading else {
            return
        }
        if lastIndexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            load(shouldRefresh: false)
        }
    }
}

extension QiitaListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath.row].preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cacncel(at:))
    }

    private func cacncel(at indexPath: IndexPath) {
        cellControllers[indexPath.row].cancel()
    }
}
