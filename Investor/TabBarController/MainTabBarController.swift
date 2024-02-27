//
//  MainTabBarController.swift
//  Investor
//
//  Created by 홍정연 on 2/27/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
        configure()
    }
    
    private func layout() {
        self.title = "Investor"
        self.tabBar.backgroundColor = ThemeColor.primary1
        self.tabBar.tintColor = ThemeColor.tint1
        self.tabBar.unselectedItemTintColor = ThemeColor.tintDisable
    }
    
    private func configure() {
        self.delegate = self
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let settingViewContoller = SettingViewController()
        settingViewContoller.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 1)
        
        self.viewControllers = [homeViewController, settingViewContoller]
    }
    
    // MARK: TabBarController 진입시, 선택된 ViewController의 RightBarButtonItems 채용
    override func viewWillAppear(_ animated: Bool) {
        guard let viewController = selectedViewController as? BarbuttonConfigurable else {
            self.navigationItem.rightBarButtonItems = nil
            return
        }
        self.navigationItem.rightBarButtonItems = viewController.rightBarButtonItems
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    // MARK: 탭 Index변경시 해당 ViewController의 RightBarButtonItems 채용
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard let viewController = viewController as? BarbuttonConfigurable else {
            tabBarController.navigationItem.rightBarButtonItems = nil
            return
        }
        tabBarController.navigationItem.rightBarButtonItems = viewController.rightBarButtonItems
    }
}
