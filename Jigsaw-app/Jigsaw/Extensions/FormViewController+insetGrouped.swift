//
//  FormViewController+insetGrouped.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/31/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Eureka

extension FormViewController {
    /// To mimic Apple's iOS 13's new inset grouped table view style, manually load the table view.
    /// - Note: Please refer to [here](https://github.com/xmartlabs/Eureka/blob/c37e0c9f6089cf320d108223ced90a791d68b4fb/Source/Core/Core.swift#L450)
    ///         for the original implementation.
    func loadInsetGroupedTableView() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: .insetGrouped)
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
    }
}
