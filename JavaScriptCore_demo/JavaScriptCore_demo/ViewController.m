//
//  ViewController.m
//  JavaScriptCore_demo
//
//  Created by 从今以后 on 16/2/5.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "ViewController.h"
@import JavaScriptCore;

@protocol LXJSExport <JSExport>
- (void)share:(NSDictionary *)json;
@end


@interface LXOCDelegate : NSObject <LXJSExport>
@end
@implementation LXOCDelegate

- (void)dealloc
{
    NSLog(@"%@ delloc", self.class);
}

- (void)share:(NSDictionary *)json
{
    // 这里的调用线程是子线程
    NSLog(@"%s %@", __FUNCTION__, [NSThread currentThread]);

    NSLog(@"%@", json);
}

@end


@interface ViewController () <UIWebViewDelegate>
@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) JSContext *context;
@end

@implementation ViewController

- (void)dealloc
{
    NSLog(@"%@ delloc", self.class);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 从 webView 中获取 JSContext
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

    // 设置 JavaScript 代码中的 OCDelegate 对象
    // 注意这里如果使用 self 作为 OCDelegate 对象的话则会导致内存泄漏
    // JSContext 会保留 self，而 self 会保留 UIWebView，后者则会保留 JSContext
    self.context[@"OCDelegate"] = [LXOCDelegate new];

    // 为 JavaScript 代码中的 presentNativeAlert 函数提供实现
    __weak typeof(self) weakSelf = self;
    self.context[@"presentNativeAlert"] = ^(NSString *text){

        // 这里的调用线程是子线程
        NSLog(@"%s %@", __FUNCTION__, [NSThread currentThread]);

        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;

            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:text
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *action =
            [UIAlertAction actionWithTitle:@"朕知道了"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       __strong typeof(weakSelf) self = weakSelf;
                                       // 调用 JavaScript 代码中的函数
                                       JSValue *changeButtonTitle = self.context[@"changeButtonTitle"];
                                       JSValue *reuslt = [changeButtonTitle callWithArguments:@[@"已分享！！！"]];
                                       NSLog(@"reuslt.toInt32: %d", reuslt.toInt32);
                                   }];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    };
}

@end
