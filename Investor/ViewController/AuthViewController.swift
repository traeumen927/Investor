//
//  AuthViewController.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SnapKit

class AuthViewController: UIViewController {
    
    lazy var googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = .dark
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
    }
    
    private func layout() {
        
        self.view.backgroundColor = ThemeColor.background
        self.view.addSubview(googleButton)
        
        googleButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    private func bind() {
        
    }
}
