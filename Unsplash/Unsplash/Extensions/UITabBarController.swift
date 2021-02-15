//
//  UITabBarController.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/13.
//

import UIKit

extension UITabBarController {
    func hideTabBar() {
        var frame = self.tabBar.frame
        guard frame.origin.y == self.view.frame.size.height - frame.size.height else {return}
        
        frame.origin.y = self.view.frame.size.height + frame.size.height
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBar.frame = frame
        })
    }
    
    func showTabBar() {
        var frame = self.tabBar.frame
        guard frame.origin.y == self.view.frame.size.height + frame.size.height else {return}
        
        frame.origin.y = self.view.frame.size.height - frame.size.height
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBar.frame = frame
        })
    }
}
