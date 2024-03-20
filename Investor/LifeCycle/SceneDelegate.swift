//
//  SceneDelegate.swift
//  Investor
//
//  Created by 홍정연 on 2/19/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let vc = AuthViewController()
        let nc = AuthNavigationController(rootViewController: vc)
        window.rootViewController = nc
        self.window = window
        window.makeKeyAndVisible()
    }
}

