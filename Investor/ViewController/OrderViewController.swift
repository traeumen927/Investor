//
//  OrderViewController.swift
//  Investor
//
//  Created by 홍정연 on 7/31/24.
//

import UIKit

class OrderViewController: UIViewController {

    private let viewModel:OrderViewModel!
  
    init(viewModel: OrderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
