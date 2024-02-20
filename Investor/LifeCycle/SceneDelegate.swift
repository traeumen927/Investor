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
            window.rootViewController = vc
            self.window = window
            window.makeKeyAndVisible()
    }
}

