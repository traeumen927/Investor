//
//  UIResponder.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit

extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

