//
//  QiitaListCellController.swift
//  QiitaFeediOS
//
//  Created by Shinzan Takata on 2019/12/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

public final class QiitaListCellController {
    var item: DisplayQiitaItem { viewModel.item }

    private let viewModel: QiitaListImageViewModel<UIImage>
    public init(viewModel: QiitaListImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    private func binded(tableView: UITableView,
                        at indexPath: IndexPath) -> QiitaListCell {
        let cell: QiitaListCell = tableView.dequeueReusableCell()

        viewModel.onLoad = { [weak cell] image in
            cell?.setUserImage(from: image)
        }
        viewModel.onLoadingStateChange = { [weak cell] in
            guard let cell = cell else {
                return
            }
            cell.isLoading
                ? cell.stopImageLoading()
                : cell.startImageLoading()
        }

        cell.configure(viewModel.item)
        loadImage()
        return cell
    }

    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return binded(tableView: tableView, at: indexPath)
    }

    private func loadImage() {
        viewModel.load()
    }

    func preload() {
        loadImage()
    }

    func cancel() {
        viewModel.cancel()
    }
}
