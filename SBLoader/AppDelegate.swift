//
//  AppDelegate.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-16.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit
import ObjectiveC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        application.statusBarHidden = true

        struct Static { static var onceToken: dispatch_once_t = 0 }
        dispatch_once(&Static.onceToken) {

            let method = class_getInstanceMethod(NSObject.self, "lx_animationDidStop:finished:")
            let imp    = method_getImplementation(method)
            let type   = method_getTypeEncoding(method)
            
            // "animationDidStop:finished:" 应该属于用分类声明的非正式协议方法,基类并没有实现.
            class_addMethod(NSObject.self, "animationDidStop:finished:", imp, type)
        }

        return true
    }
}

private extension NSObject {
    @objc func lx_animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if let completion: AnyObject = anim.valueForKey(CompletionBlockKey) {
            unsafeBitCast(completion, CompletionBlock.self)(flag)
        }
    }
}