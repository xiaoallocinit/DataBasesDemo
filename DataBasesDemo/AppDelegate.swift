//
//  AppDelegate.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/6.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()

        let vc  = ViewController()
        let nav = UINavigationController.init(rootViewController:vc)
        self.window?.rootViewController =  nav
        RealmManager.shared.start()
        return true
    }

    

}

