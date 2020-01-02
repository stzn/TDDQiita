//
//  QiitaListUIComposer.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import UIKit
import QiitaFeature
import QiitaFeediOS

let noUserImage = UIImage(systemName: "nosign")!

struct QiitaListUIComposer {
    static func composeQiitaListViewController(listLoader: PaginationQiitaLoader, imageLoader: QiitaImageLoader) -> QiitaListViewController {
        let viewController = QiitaListViewController.instantiate()

        let viewModel = QiitaListViewModel(loader: MainQueueDispatchDecorator(decoratee: listLoader))
        viewModel.onLoad = adaptQiitaItemsTo(viewController,
                                             imageLoader: imageLoader)
        viewModel.onError = { [weak viewController] error in
            viewController?.setError(error)
        }
        viewModel.onLoadStateChange = { [weak viewController] in
            viewController?.configureIndicator()
        }
        viewModel.onRefreshStateChange = { [weak viewController] in
            viewController?.configureRefreshControl()
        }
        viewController.viewModel = viewModel

        return viewController
    }

    private static func adaptQiitaItemsTo(
        _ viewController: QiitaListViewController,
        imageLoader: QiitaImageLoader) -> ([QiitaItem]) -> Void {
        return { [weak viewController] items in
            viewController?.updateDisplay(items.map { item in
                QiitaListCellController(
                    viewModel: QiitaListImageViewModel(
                        item: convertItemForDisplay(item),
                        loader: imageLoader,
                        imageTransformer: convertToUserImage))
            })
        }
    }

    private static func convertToUserImage(_ data: Data?) -> UIImage {
        if let data = data, let image = UIImage(data: data) {
            return image
        } else {
            return noUserImage
        }
    }

    private static func convertItemForDisplay(_ item: QiitaItem) -> DisplayQiitaItem {
        DisplayQiitaItem(
            title: item.title,
            userName: item.user?.githubLoginName ?? "",
            likesCount: String(describing: item.likesCount),
            commentsCount: String(describing: item.commentsCount),
            updatedAt: item.updatedAt.string(format: .japaneseFormat),
            userImageURL: item.user?.userImageURL)
    }
}
