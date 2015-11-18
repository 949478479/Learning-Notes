//
//  LXUtilities.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

///------------
/// @name 头文件
///------------

#import "LXMacro.h"
#import "NSDate+LXAdditions.h"
#import "UIView+LXAdditions.h"
#import "CALayer+LXAdditions.h"
#import "UIImage+LXAdditions.h"
#import "UIColor+LXAdditions.h"
#import "NSArray+LXAdditions.h"
#import "UIButton+LXAdditions.h"
#import "NSObject+LXAdditions.h"
#import "NSString+LXAdditions.h"
#import "UITextView+LXAdditions.h"
#import "UITextField+LXAdditions.h"
#import "UIStoryboard+LXAdditions.h"
#import "NSDictionary+LXAdditions.h"
#import "NSFileManager+LXAdditions.h"
#import "NSUserDefaults+LXAdditions.h"
#import "UIViewController+LXAdditions.h"
#import "NSAttributedString+LXAdditions.h"
#import "NSNotificationCenter+LXAdditions.h"

//#import "MBProgressHUD+LXAdditions.h"
//#import "LXImagePicker.h"
//#import "LXMulticastDelegate.h"

NS_ASSUME_NONNULL_BEGIN

///------------
/// @name 版本号
///------------

NSString * LXBundleVersionString();
NSString * LXBundleShortVersionString();

///--------------
/// @name 沙盒路径
///--------------

NSString * LXDocumentDirectory();
NSString * LXDocumentDirectoryByAppendingPathComponent(NSString *pathComponent);

NSString * LXLibraryDirectory();
NSString * LXLibraryDirectoryByAppendingPathComponent(NSString *pathComponent);

NSString * LXCachesDirectory();
NSString * LXCachesDirectoryByAppendingPathComponent(NSString *pathComponent);

///--------------
/// @name 设备信息
///--------------

BOOL LXDeviceIsPad();

///------------------
/// @name AppDelegate
///------------------

id<UIApplicationDelegate> LXAppDelegate();

///---------------------
/// @name 屏幕|窗口|控制器
///---------------------

CGSize LXScreenSize();
CGFloat LXScreenScale();

UIWindow * LXKeyWindow();
UIWindow * LXTopWindow();

UIViewController * LXTopViewController();
UIViewController * LXRootViewController();

///----------
/// @name GCD
///----------

/**
 *  创建一个基于 @c dispatch_source_t 的在主线程工作的定时器，
 *
 *  @param interval      触发时间间隔.
 *  @param leeway        可容忍的触发时间偏差.
 *  @param handler       定时器触发时执行的 block.
 *  @param cancelHandler 定时器取消时执行的 block.
 *
 *  @return 未激活的 @c dispatch_source_t，需手动调用 @c dispatch_resume() 函数激活.
 */
dispatch_source_t lx_dispatch_source_timer(NSTimeInterval secondInterval,
                                           NSTimeInterval secondLeeway,
                                           dispatch_block_t handler,
                                           _Nullable dispatch_block_t cancelHandler);

void lx_dispatch_after(NSTimeInterval delayInSeconds, dispatch_block_t handler);

///--------------
/// @name runtime
///--------------

void LXMethodSwizzling(Class cls, SEL originalSelector, SEL swizzledSelector);

NSArray<NSString *> * lx_protocol_propertyList(Protocol *protocol);

NS_ASSUME_NONNULL_END
