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

    enum Section{
        case main
    }

    private var dataSource: UITableViewDiffableDataSource<Section, DisplayQiitaItem>!

    var cellControllers: [QiitaListCellController] = []

    private(set) var refreshControl = UIRefreshControl()

    var viewModel: QiitaListViewModel!

    private var isLoading: Bool {
        return indicator.isAnimating || refreshControl.isRefreshing
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        setupTableView()
        load(shouldRefresh: false)
    }

    private func setRefreshControl() {
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc func refresh() {
        load(shouldRefresh: true)
    }

    func configureRefreshControl() {
        refreshControl.isRefreshing ?
            refreshControl.endRefreshing()
            : refreshControl.beginRefreshing()
    }

    func configureIndicator() {
        indicator.isAnimating ?
            indicator.stopAnimating()
            : indicator.startAnimating()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.prefetchDataSource = self
        setupDataSource()
        initTableView()
    }

    private func load(shouldRefresh: Bool) {
        errorView.message = nil
        if shouldRefresh {
            viewModel.refresh()
        } else {
            viewModel.load()
        }
    }

    func initTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisplayQiitaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cellControllers.map { $0.item })
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func updateTableView() {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(cellControllers.map { $0.item }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func setError(_ error: Error) {
        errorView.message = error.localizedDescription
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, DisplayQiitaItem>(tableView: tableView) { [weak self] _, indexPath, item in
            return self?.cellForRowAt(indexPath: indexPath, with: item)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, DisplayQiitaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @discardableResult
    private func cellForRowAt(indexPath: IndexPath, with item: DisplayQiitaItem) -> UITableViewCell? {
        return cellControllers[indexPath.row].cell(for: tableView, at: indexPath) as! QiitaListCell
    }
}

extension QiitaListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellControllers[indexPath.row].cancel()
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
