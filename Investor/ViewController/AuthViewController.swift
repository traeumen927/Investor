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
import RxSwift
import RxCocoa

class AuthViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = AuthViewModel()
    
    
    // MARK: 구글 로그인 버튼
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
        
        // 버튼 탭 이벤트를 구독하여 로그인 로직을 실행
        googleButton.tapped
            .subscribe(onNext: { [weak self] _ in
                guard let clientID = FirebaseApp.app()?.options.clientID, let self = self else { return }
                
                // Create Google Sign In configuration object.
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                    guard error == nil else {
                        print("error: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: user.accessToken.tokenString)
                    self.signIn(with: credential)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: 로그인
    private func signIn(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { result, error in
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                return
            }
        }
    }
}
