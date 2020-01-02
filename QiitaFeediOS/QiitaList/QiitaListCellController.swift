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

    private var cell: QiitaListCell?

    private func bind(in tableView: UITableView) -> QiitaListCell {
        viewModel.onLoad = { [weak self] image in
            self?.cell?.setUserImage(from: image)
        }
        viewModel.onLoadingStateChange = { [weak self] in
            guard let cell = self?.cell else {
                return
            }
            cell.isLoading
                ? cell.stopImageLoading()
                : cell.startImageLoading()
        }
        cell = tableView.dequeueReusableCell()
        cell?.configure(viewModel.item)
        loadImage()
        return cell!
    }

    func cell(in tableView: UITableView) -> UITableViewCell {
        return bind(in: tableView)
    }

    private func loadImage() {
        viewModel.load()
    }

    func preload() {
        loadImage()
    }

    func cancel() {
        viewModel.cancel()
        cell = nil
    }
}
