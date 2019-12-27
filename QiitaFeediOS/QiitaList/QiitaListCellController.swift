//
//  QiitaListCellController.swift
//  QiitaFeediOS
//
//  Created by Shinzan Takata on 2019/12/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

let noUserImage = UIImage(systemName: "nosign")!

final class QiitaListCellController {
    private let viewModel: QiitaListImageViewModel
    let item: DisplayQiitaItem

    init(viewModel: QiitaListImageViewModel, item: DisplayQiitaItem) {
        self.viewModel = viewModel
        self.item = item
    }

    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: QiitaListCell = tableView.dequeueReusableCell()
        cell.configure(item)
        if let url = item.userImageURL {
            renderUserImage(for: cell, at: indexPath, from: url)
        }
        return cell
    }

    private func renderUserImage(
        for cell: QiitaListCell, at indexPath: IndexPath, from url: URL) {
        cell.startImageLoading()
        viewModel.load(from: url) { [weak cell] result in
            cell?.setUserImage(data: try? result.get(),
                               defaultImage: noUserImage)
            cell?.stopImageLoading()
        }
    }

    func preload() {
        if let url = item.userImageURL {
            viewModel.load(from: url) { _ in }
        }
    }

    func cancel() {
        viewModel.cancel()
    }
}
