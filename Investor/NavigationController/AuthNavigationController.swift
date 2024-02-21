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
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let settingViewContoller = SettingViewController()
        settingViewContoller.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.title = "Investor"
        tabBarController.tabBar.backgroundColor = ThemeColor.primary1
        tabBarController.tabBar.tintColor = ThemeColor.tint1
        tabBarController.tabBar.unselectedItemTintColor = ThemeColor.tintDisable
        tabBarController.viewControllers = [homeViewController, settingViewContoller]
        
        let tabBarNavigation = TabNavigationController(rootViewController: tabBarController)
        tabBarNavigation.modalPresentationStyle = .fullScreen
        self.present(tabBarNavigation, animated: true)
    }
}
