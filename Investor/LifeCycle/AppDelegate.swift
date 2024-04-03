//
//  AppDelegate.swift
//  Investor
//
//  Created by 홍정연 on 4/3/24.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - Place for Firebase configure
        FirebaseApp.configure()
        
        // MARK: - Place for layout For Navigation Controller
        let naviAppearance = UINavigationBarAppearance()
        naviAppearance.configureWithOpaqueBackground()
        naviAppearance.backgroundColor = ThemeColor.primary1
        naviAppearance.titleTextAttributes = [.foregroundColor: ThemeColor.tint1]
        naviAppearance.largeTitleTextAttributes = [.foregroundColor: ThemeColor.tint1]
        
        UINavigationBar.appearance().scrollEdgeAppearance = naviAppearance
        UINavigationBar.appearance().standardAppearance = naviAppearance
        UINavigationBar.appearance().tintColor = ThemeColor.tint1
        
        
        // MARK: - Place for layout For TabBar Controller
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = ThemeColor.primary1
        
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

