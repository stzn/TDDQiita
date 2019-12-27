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

struct QiitaListUIComposer {
    static func composeQiitaListViewController(listLoader: QiitaLoader, imageLoader: QiitaImageLoader) -> QiitaListViewController {
        let viewController = QiitaListViewController.instantiate()

        let viewModel = QiitaListViewModel(loader: listLoader)
        viewModel.onLoad = adaptQiitaItemsTo(viewController, imageLoader: imageLoader)
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

    private static func adaptQiitaItemsTo(_ viewController: QiitaListViewController,
                                         imageLoader: QiitaImageLoader) -> ([QiitaItem]) -> Void {
        return { [weak viewController] items in
            let cellControllers: [QiitaListCellController] = items.map { item in
                QiitaListCellController(
                    viewModel: QiitaListImageViewModel(loader: imageLoader),
                    item: convertItemForDisplay(item))
            }
            viewController?.cellControllers.append(contentsOf: cellControllers)
            viewController?.updateTableView()
        }
    }

    private static func convertItemForDisplay(_ item: QiitaItem) -> DisplayQiitaItem {
        DisplayQiitaItem(
            title: item.title,
            userName: item.user?.githubLoginName ?? "",
            likesCount: String(describing: item.likesCount),
            commentsCount: String(describing: item.commentsCount),
            updatedAt: item.updatedAt.description,
            userImageURL: item.user?.userImageURL)
    }
}
