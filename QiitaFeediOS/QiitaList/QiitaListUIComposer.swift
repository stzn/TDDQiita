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
        let vc = QiitaListViewController.instantiate()

        let viewModel = QiitaListViewModel(loader: listLoader)
        viewModel.onLoad = adaptQiitaItemToQiitaListViewController(to: vc, imageLoader: imageLoader)
        viewModel.onError = { [weak vc] error in
            vc?.setError(error)
        }
        viewModel.onLoadStateChange = { [weak vc] in
            vc?.configureIndicator()
        }
        viewModel.onRefreshStateChange = { [weak vc] in
            vc?.configureRefreshControl()
        }
        vc.viewModel = viewModel

        return vc
    }

    private static func adaptQiitaItemToQiitaListViewController(
        to viewController: QiitaListViewController,
        imageLoader: QiitaImageLoader) -> ([QiitaItem]) -> Void {
        return { [weak viewController] items in
            let cellControllers: [QiitaListCellController] = items.map { item in
                let viewModel = QiitaListImageViewModel(loader: imageLoader)
                let displayItem = convertItemForDisplay(item)
                return QiitaListCellController(viewModel: viewModel, item: displayItem)
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
