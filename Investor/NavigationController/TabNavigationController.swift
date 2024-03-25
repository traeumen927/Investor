//
//  TabNavigationController.swift
//  Investor
//
//  Created by 홍정연 on 2/22/24.
//

import UIKit
import FirebaseAuth

class TabNavigationController: UINavigationController {

    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        self.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard let user = user else {
                // MARK: 로그아웃 -> 유저 서비스 정보 초기화
                UserService.shared.logoutUser()
                self.dismiss(animated: true)
                return
            }
            // MARK: 로그인 -> 유저 서비스 정보 저장
            UserService.shared.saveUser(user: user)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
