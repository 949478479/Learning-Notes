//
//  NSObject+LXAdditions.h
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
#import "NSObject+DLIntrospection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @c NSObject 的直接子类采纳此协议将会覆盖 @c [NSObject description] 方法,在默认实现上附带实例变量名和值.
 */
@protocol LXDescription <NSObject>
@end

@interface NSObject (LXAdditions)

///---------------------------
/// @name 获取属性和实例变量名数组
///---------------------------

/**
 *  获取实例变量名数组.
 */
+ (NSArray<NSString *> *)lx_ivarList;
/**
 *  获取实例变量名数组.
 */
- (NSArray<NSString *> *)lx_ivarList;

/**
 *  获取属性名数组.
 */
+ (NSArray<NSString *> *)lx_propertyList;
/**
 *  获取属性名数组.
 */
- (NSArray<NSString *> *)lx_propertyList;

///--------------
/// @name 关联对象
///--------------

/**
 *  使用 @c objc_setAssociatedObject 函数根据指定 @c key 关联对象.
 *
 *  @param value 关联的对象.
 *  @param key   关联对象对应的 @c key.
 */
- (void)lx_setValue:(nullable id)value forKey:(NSString *)key;

/**
 *  使用 @c objc_getAssociatedObject 函数获取 @c key 对应的关联对象.
 *
 *  @param key 关联对象的 @c key.
 *
 *  @return @c key 对应的关联对象.
 */
- (nullable id)lx_valueForKey:(NSString *)key;

///------------------
/// @name KVO 相关方法
///------------------

- (void)lx_removeAllObservers;

@end

NS_ASSUME_NONNULL_END
