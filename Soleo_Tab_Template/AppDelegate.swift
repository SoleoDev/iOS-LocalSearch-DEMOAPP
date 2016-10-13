//
//  AppDelegate.swift
//  Soleo_Tab_Template
//
//  Created by Victor Jimenez Delgado on 1/27/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerContainer: MMDrawerController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //The app should be ready to display...
        buildNavDrawer()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func buildNavDrawer()
    {
        //Need variables
        //Main StoryBoard
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        
        //Main Page
        let mainPage = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController

        //LeftSideMenu
        let leftMenu = mainStoryBoard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        //RightSideMenu
//        let rightMenu = mainStoryBoard.instantiateViewControllerWithIdentifier("RightViewController") as! RightViewController
        
        //Top Going to use this somewhere else.
//        let topMenu = mainStoryBoard.instantiateViewControllerWithIdentifier("TopViewController") as!
//            TopViewController
        
        //Time to Wrap
        let leftSideMenuNav = UINavigationController(rootViewController: leftMenu)
//        let RightSideMenuNav = UINavigationController(rootViewController: rightMenu)
        
        //get a drawerController
        drawerContainer = MMDrawerController(center: mainPage, leftDrawerViewController: leftSideMenuNav)
            
        
        drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.bezelPanningCenterView
        drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
        drawerContainer!.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionMode.none
        drawerContainer!.maximumLeftDrawerWidth = CGFloat(300.00)
        
        //Time to assing it to the main guy...
        //Got to love nesting
        window?.rootViewController = drawerContainer
        
    }


}

