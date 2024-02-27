//
//  AuthNavigationController.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit
import FirebaseAuth

class AuthNavigationController: UINavigationController {
    
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard user != nil else {
                print("user nil")
                return
            }
            self.presentTabBarController()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    // MARK: 로그인 성공시 메인탭 present
    private func presentTabBarController() {
        
        let tabBarController = MainTabBarController()

        let tabBarNavigation = TabNavigationController(rootViewController: tabBarController)
        tabBarNavigation.modalPresentationStyle = .fullScreen
        self.present(tabBarNavigation, animated: true)
    }
}
