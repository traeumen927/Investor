//
//  HomeViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
    }
}
