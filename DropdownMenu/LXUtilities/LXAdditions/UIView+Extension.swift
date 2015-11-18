//
//  UIView+Extension.swift
//
//  Created by 从今以后 on 15/11/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

extension UIView {

    static func instantiateFromNib() -> Self {
        return instantiateFromNibWithOwner(nil, options: nil)
    }

    static func instantiateFromNibWithOwner(ownerOrNil: AnyObject?,
        options optionsOrNil: [NSObject : AnyObject]?) -> Self {

        func _instantiateWithType<T>(type: T.Type,
            ownerOrNil: AnyObject?,
            optionsOrNil: [NSObject : AnyObject]?) -> T {

            let views = UINib(nibName: String(type), bundle: nil).instantiateWithOwner(nil, options: nil)
            for view in views where view.dynamicType == type { return (view as! T) }

            fatalError("\(String(type)).xib 文件中未找到对应实例.")
        }

        return _instantiateWithType(self, ownerOrNil: ownerOrNil, optionsOrNil: optionsOrNil)
    }
}
