//
//  HomeViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, BarbuttonConfigurable {
    
    var rightBarButtonItems: [UIBarButtonItem]?
    
    var disposeBag = DisposeBag()
    
    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        button.tintColor = ThemeColor.tint1
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
        bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        self.rightBarButtonItems = [searchButton]
    }
    
    private func bind() {
        self.searchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let searchViewController = SearchViewController()
                let nc = UINavigationController(rootViewController: searchViewController)
                nc.modalPresentationStyle = .formSheet
                self?.parentViewController?.present(nc, animated: true)
            }).disposed(by: disposeBag)
    }
}
