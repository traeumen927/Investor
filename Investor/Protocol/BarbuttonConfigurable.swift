//
//  BarbuttonConfigurable.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import UIKit


// MARK: RightBarButtonItems 구성을 강제하도록함
protocol BarbuttonConfigurable {
    var rightBarButtonItems: [UIBarButtonItem]? {get set}
}

