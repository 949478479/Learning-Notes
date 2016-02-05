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

@interface ViewController () <UIWebViewDelegate, LXJSExport>
@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) JSContext *context;
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.html" withExtension:nil];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// 从 webView 中获取 JSContext
	_context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

	// 让控制器作为 JavaScript 代码中的 OCDelegate 对象
	_context[@"OCDelegate"] = self;

	// 为 JavaScript 代码中的 presentNativeAlert 函数提供实现
	__weak typeof(self) weakSelf = self;
	_context[@"presentNativeAlert"] = ^(NSString *text){

		// 这里的调用线程是子线程
		NSLog(@"%s %@", __FUNCTION__, [NSThread currentThread]);

		dispatch_async(dispatch_get_main_queue(), ^{

			UIAlertController *alert =
			[UIAlertController alertControllerWithTitle:text
												message:nil
										 preferredStyle:UIAlertControllerStyleAlert];

			UIAlertAction *action =
			[UIAlertAction actionWithTitle:@"朕知道了"
									 style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction *action) {

			    // 调用 JavaScript 代码中的函数
				JSValue *changeButtonTitle = weakSelf.context[@"changeButtonTitle"];
				JSValue *reuslt = [changeButtonTitle callWithArguments:@[@"已分享！！！"]];
				NSLog(@"%d", reuslt.toInt32);
			}];

			[alert addAction:action];

			[weakSelf presentViewController:alert animated:YES completion:nil];
		});
	};
}

- (void)share:(NSDictionary *)json
{
	// 这里的调用线程是子线程
	NSLog(@"%s %@", __FUNCTION__, [NSThread currentThread]);

	NSLog(@"%@", json);
}

@end
