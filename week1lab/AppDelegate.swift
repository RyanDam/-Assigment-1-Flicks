//
//  AppDelegate.swift
//  week1lab
//
//  Created by Dam Vu Duy on 3/7/16.
//  Copyright © 2016 dotRStudio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let nowPlayingNavigationController = storyBoard.instantiateViewControllerWithIdentifier("MainMovieView") as! UINavigationController
        let nowPlayingController = nowPlayingNavigationController.topViewController as! MoviesCollectionViewController
        nowPlayingController.dataModeString = "now_playing"
        nowPlayingNavigationController.tabBarItem.title = "Now playing"
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "nowplaying")
        
        let topRatedNavigationController = storyBoard.instantiateViewControllerWithIdentifier("MainMovieView") as! UINavigationController
        let topRatedController = topRatedNavigationController.topViewController as! MoviesCollectionViewController
        topRatedController.dataModeString = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "toprated")
        
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        tabbarController.tabBar.barTintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.5)
        tabbarController.tabBar.tintColor = UIColor.orangeColor()
        
        window?.rootViewController = tabbarController
        window?.makeKeyAndVisible()
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

