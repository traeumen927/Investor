//
//  SettingViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa
import SnapKit



class SettingViewController: UIViewController, BarbuttonConfigurable {
    
    var rightBarButtonItems: [UIBarButtonItem]?
    
    private var disposebag = DisposeBag()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("logout", for: .normal)
        button.setTitleColor(ThemeColor.tint2, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
    }
    
    private func layout() {
        self.view.backgroundColor = ThemeColor.background
        
        self.view.addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func bind() {
        self.logoutButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.signOut()
            }).disposed(by: disposebag)
    }
    
    // MARK: 로그아웃
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
