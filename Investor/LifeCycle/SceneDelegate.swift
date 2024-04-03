//
//  SceneDelegate.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // MARK: 마켓 viewController
        let marketViewController = MarketViewController()
        marketViewController.tabBarItem = UITabBarItem(title: "거래소", image: UIImage(systemName: "bitcoinsign"), tag: 0)
        
        // MARK: 설정 viewController
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 1)
        
        
        // MARK: tabBarController
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = ThemeColor.tint1
        tabBarController.tabBar.unselectedItemTintColor = ThemeColor.tintDisable
        tabBarController.viewControllers = [wrapInNavigationController(viewController: marketViewController),
                                            wrapInNavigationController(viewController: settingViewController)]
        
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // MARK: viewcontroller를 uiNavigationController로 감싸서 반환
    private func wrapInNavigationController(viewController: UIViewController) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}

