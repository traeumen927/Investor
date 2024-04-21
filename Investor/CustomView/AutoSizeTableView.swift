//
//  AutoSizeTableView.swift
//  Investor
//
//  Created by 홍정연 on 4/21/24.
//

import UIKit

final class AutoSizeTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric,
                     height: contentSize.height + adjustedContentInset.top)
    }
}
