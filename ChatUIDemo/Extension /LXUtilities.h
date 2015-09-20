//
//  LXUtilities.h
//  LXWeChat
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#ifndef LXUtilities_h
#define LXUtilities_h
@class AppDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 类扩展头文件

#import "UIView+LXExtension.h"
#import "UIImage+LXExtension.h"
#import "NSObject+LXExtension.h"
#import "NSString+LXExtension.h"
#import "UITextField+LXExtension.h"
#import "UIStoryboard+LXExtension.h"
#import "NSNotificationCenter+LXExtension.h"
//#import "MBProgressHUD+LXExtension.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 沙盒路径

NSString * LXDocumentDirectory();

NSString * LXLibraryDirectory();

NSString * LXCachesDirectory();

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 常用

AppDelegate * LXAppDelegate();

UIWindow * LXKeyWindow();

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 方法交换

void LXMethodSwizzling(Class cls, SEL originalSelector, SEL swizzledSelector);

NS_ASSUME_NONNULL_END

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - log 宏

#ifdef DEBUG

/**
 *  附带 文件名,行号,函数名 的 log 宏.
 */
// 如果有警告把注释打开.
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
#define LXLog(format, ...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wcstring-format-directive\"") \
NSLog(@"[%@ : %d] %s\n\n%@\n\n", \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
__FUNCTION__, \
[NSString stringWithFormat:(format), ##__VA_ARGS__]) \
_Pragma("clang diagnostic pop")
//#pragma clang diagnostic pop

/**
 *  打印 CGRect.
 */
#define LXLogRect(rect) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wcstring-format-directive\"") \
LXLog(@"%s => %@", #rect, NSStringFromCGRect(rect)) \
_Pragma("clang diagnostic pop")

/**
 *  打印 CGSize.
 */
#define LXLogSize(size) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wcstring-format-directive\"") \
LXLog(@"%s => %@", #size, NSStringFromCGSize(size)) \
_Pragma("clang diagnostic pop")

/**
 *  打印 CGPoint.
 */
#define LXLogPoint(point) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wcstring-format-directive\"") \
LXLog(@"%s => %@", #point, NSStringFromCGPoint(point)) \
_Pragma("clang diagnostic pop")

#else

#define LXLog(format, ...)
#define LXLogRect(rect)
#define LXLogSize(size)
#define LXLogPoint(point)

#endif

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 单例 宏

/**
 *  生成单例接口的宏.
 *
 *  单例使用 dispatch_once 函数实现,限制了 allocWithZone: 和 copyWithZone: 方法.
 *
 *  @param methodName 单例方法名.
 */
#define LX_SINGLETON_INTERFACE(methodName) + (instancetype)methodName;

/**
 *  生成单例实现的宏.
 */
#define LX_SINGLETON_IMPLEMENTTATION(methodName) \
\
+ (instancetype)methodName \
{ \
static id sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedInstance = [[super allocWithZone:NULL] init]; \
}); \
return sharedInstance; \
} \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
return [self methodName]; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#endif