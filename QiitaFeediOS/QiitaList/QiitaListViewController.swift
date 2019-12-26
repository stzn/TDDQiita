//
//  QiitaListViewController.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
import QiitaFeed

final class QiitaListViewController: UIViewController, StoryboardInstantiatable {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var errorView: ErrorView!

    enum Section{
        case main
    }

    let noUserImage = UIImage(systemName: "nosign")!

    private var dataSource: UITableViewDiffableDataSource<Section, QiitaItem>!
    private var imageTasks: [IndexPath: QiitaImageLoaderTask] = [:]

    private(set) var refreshControl = UIRefreshControl()

    private(set) var listLoader: QiitaLoader!
    private(set) var imageLoader: QiitaImageLoader!

    private var isLoading: Bool {
        return indicator.isAnimating || refreshControl.isRefreshing
    }

    static func instance(loader: QiitaLoader, imageLoader: QiitaImageLoader) -> QiitaListViewController {
        let vc = instantiate()
        vc.listLoader = loader
        vc.imageLoader = imageLoader
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setRefreshControl()
        setupTableView()
        load(with: indicator) { [weak self] items in
            self?.reloadTableViewIfNeeded(with: items)
        }
    }

    private func setRefreshControl() {
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc func refresh() {
        load(with: refreshControl) { [weak self] items in
            self?.reloadTableViewIfNeeded(with: items)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.prefetchDataSource = self
        setupDataSource()
    }

    private func load(with indicator: LoadingIndicator,
                      completion: @escaping ([QiitaItem]?) -> Void) {
        errorView.message = nil
        indicator.startLoading()
        loadData { items in
            indicator.stopLoading()
            completion(items)
        }
    }

    private func loadData(completion: @escaping ([QiitaItem]?) -> Void) {
        listLoader.load { [weak self] result in
            switch result {
            case .success(let items):
                completion(items)
            case .failure(let error):
                self?.errorView?.message = error.localizedDescription
                completion(nil)
            }
        }
    }

    private func reloadTableViewIfNeeded(with items: [QiitaItem]?) {
        guard let items = items else {
            return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, QiitaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateTableViewIfNeeded(with items: [QiitaItem]?) {
        guard let items = items else {
            return
        }
        var snapshot = dataSource.snapshot()
        var currentItems = snapshot.itemIdentifiers
        currentItems.append(contentsOf: items)
        snapshot.appendItems(currentItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, QiitaItem>(tableView: tableView) { [weak self] _, indexPath, item in
            return self?.cellForRowAt(indexPath: indexPath, with: item)
        }
        reloadTableViewIfNeeded(with: [])
    }

    @discardableResult
    private func cellForRowAt(indexPath: IndexPath, with item: QiitaItem) -> QiitaListCell? {
        let cell: QiitaListCell = tableView.dequeueReusableCell()
        cell.configure(item)
        renderUserImageIfNeeded(for: cell, at: indexPath, with: item)
        return cell
    }

    private func renderUserImageIfNeeded(for cell: QiitaListCell, at indexPath: IndexPath, with item: QiitaItem) {

        guard let url = item.user?.userImageURL else {
            return
        }

        cell.startImageLoading()
        loadImage(from: url, at: indexPath) { [weak self, weak cell] data in
            cell?.setUserImage(data: data, defaultImage: self!.noUserImage)
            cell?.stopImageLoading()
            self?.imageTasks[indexPath] = nil
        }
    }

    private func loadImage(from url: URL, at indexPath: IndexPath,
                           completion: @escaping (Data?) -> Void) {
        imageTasks[indexPath] = imageLoader.load(url: url) { [weak self] result in
            guard self?.imageTasks[indexPath] != nil else {
                completion(nil)
                return
            }
            completion(try? result.get())
        }
    }
}

extension QiitaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cacncelTask(at: indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastIndexPath = tableView.indexPathsForVisibleRows?.last, !isLoading else {
            return
        }
        if lastIndexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            load(with: indicator) { [weak self] items in
                self?.updateTableViewIfNeeded(with: items)
            }
        }
    }
}

extension QiitaListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let item = dataSource.itemIdentifier(for: indexPath),
                let url = item.userImageURL else {
                return
            }
            loadImage(from: url, at: indexPath) { _ in }
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cacncelTask(at:))
    }

    private func cacncelTask(at indexPath: IndexPath) {
        imageTasks[indexPath]?.cancel()
        imageTasks[indexPath] = nil
    }
}
