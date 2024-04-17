//
//  AccountViewController.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import RxSwift
import SnapKit

class AccountViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background1
        self.title = "투자내역"
    }
    
    private func bind() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.fetchAccounts()
    }
}
