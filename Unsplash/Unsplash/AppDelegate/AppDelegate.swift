//
//  AppDelegate.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UINavigationBar.appearance().barTintColor = .yellow
//        UINavigationBar.appearance().tintColor = .gray
        
        UINavigationBar.appearance().barStyle = .blackOpaque
        
        
        
        NetworkMonitor.shared.startMonitoring()
        

        return true
    }
}

