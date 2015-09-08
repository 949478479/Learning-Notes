//
//  CAAnimation+Delegate.swift
//  SBLoader
//
//  Created by 从今以后 on 15/9/8.
//  Copyright (c) 2015年 Satraj Bambra. All rights reserved.
//

import UIKit

let CompletionBlockKey = "completion"

typealias CompletionBlock = @objc_block Bool -> Void

extension CAAnimation {
    func addDelegate(delegate: NSObject, withCompletion completion: CompletionBlock?) {
        if let completion = completion {
            self.delegate = delegate
            setValue(unsafeBitCast(completion as CompletionBlock, AnyObject.self),
                forKey: CompletionBlockKey)
        }
    }
}