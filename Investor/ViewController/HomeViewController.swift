//
//  HomeViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit

class HomeViewController: UIViewController, BarbuttonConfigurable {
    
    var rightBarButtonItems: [UIBarButtonItem]?
    
    
    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        button.tintColor = ThemeColor.tint1
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        self.rightBarButtonItems = [searchButton]
    }
}
