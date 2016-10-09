# JavaScriptCore 学习笔记

参考资料：

- [iOS与JS交互实战篇](http://mp.weixin.qq.com/s?__biz=MzIzMzA4NjA5Mw==&mid=214063688&idx=1&sn=903258ec2d3ae431b4d9ee55cb59ed89#rd)
- [NSHipster: JavaScriptCore](http://nshipster.cn/javascriptcore/)
- [Objective-C与JavaScript交互的那些事](http://www.jianshu.com/p/f896d73c670a)
- [JavaScript和Objective-C交互的那些事(续)](http://www.jianshu.com/p/939db6215436)
- [JSValue Class Reference 等相关类文档](http://congjinyihoudeimac.local:58745/Dash/kmjixytg/documentation/JavaScriptCore/Reference/JSValue_Ref/index.html#//apple_ref/doc/uid/TP40016590)
- [WWDC 2013 Session 615: Integrating JavaScript into Native Apps](https://developer.apple.com/videos/play/wwdc2013/615)

包含内容：

- [JSValue](#JSValue)
- [JSContext](#JSContext)
- [JSVirtualMachine](#JSVirtualMachine)
	- [并发执行 JavaScript 代码](Threading_and_Concurrent_JavaScript_Execution)
	- [导出对象的内存管理](Managing_Memory_for_Exported_Objects)
- [JSManagedValue](#JSManagedValue)
- [JSExport](#JSExport)
- [内存管理注意事项](#memory_management_caveats)
	- [避免在闭包中捕获 JSValue 或 JSContext 对象](#Capturing_JavaScriptCore_Object)
	- [避免直接储存 JSValue 对象](#Managed_References)
- [简单使用示例](#Simple_Example)

## JSValue

`JSValue` 用于表示 `JavaScript` 中的值。利用这个类，可以将基本类型值（例如数字或字符串）在原生代码和 `JavaScript` 代码间进行转换。该类型还可以创建原生代码中自定义对象相对应的 `JavaScript` 对象，以及由原生代码中的方法或是闭包来提供实现的 `JavaScript` 函数。

每个 `JSValue` 都来源于 `JSContext`，后者表示前者的 `JavaScript` 执行环境。`JSValue` 会持有自己所属的 `JSContext` 的强引用，这意味着，只要还有一个 `JSValue` 存在，其对应的 `JSContext` 就不会被销毁。通过一个 `JSValue` 得到的另一个 `JSValue` 也将同属于同一个 `JSContext`。

每个 `JSContext` 都关联着一个 `JSVirtualMachine`，因此每个 `JSValue` 也都间接关联着一个 `JSVirtualMachine`。`JSVirtualMachine` 表示底层的 `JavaScript` 执行环境。只能将 `JSValue` 传递给同属于同一个 `JSVirtualMachine` 的 `JSValue` 或 `JSContext`，否则将会引发异常。

## JSContext

`JSContext` 表示 `JavaScript` 执行环境，通过该对象来执行来源自原生代码的 `JavaScript` 脚本，使用原生代码中的对象、方法和函数，而原生代码也能获取由 `JavaScript` 定义或者计算而得的值。

## JSVirtualMachine

`JSVirtualMachine` 表示一个自包含的 `JavaScript` 执行环境。该类有两个作用，即支持 `JavaScript` 并发执行，以及管理对象在原生代码和 `JavaScript` 代码之间桥接时的内存问题。

<a name="Threading_and_Concurrent_JavaScript_Execution"></a>
### 并发执行 JavaScript 代码

每个 `JSContext` 都从属于一个 `JSVirtualMachine`。每个  `JSVirtualMachine` 可以包含多个 `JSContext`，并允许 `JSValue` 在多个 `JSContext` 间传递。然而，每个 `JSVirtualMachine` 是不同的，不可以将 `JSValue` 在多个 `JSVirtualMachine` 间传递。

`JavaScriptCore` 的 `API` 是线程安全的，例如，一个 `JSValue` 的创建和使用可以分别处于不同线程。然而，当其他线程试图使用同一个 `JSVirtualMachine` 时将会进入等待。因此，为了在多个线程间并发执行 `JavaScript` 代码，应该为每个线程提供一个独立的 `JSVirtualMachine`。

<a name="Managing_Memory_for_Exported_Objects"></a>
### 导出对象的内存管理

避免直接引用 `JSValue`，否则很容易导致引用循环。`JSValue` 和 `JSContext` 之间会互相强引用，`JSValue` 也会强引用其包装的原生对象。`JavaScript` 的垃圾回收器能够解决这些循环引用，然而一旦引入了来自外部的强引用，处理不慎就很容易导致内存泄露。作为一种良好地实践，使用 `JSManagedValue` 来包装 `JSValue`，在原生代码中持有 `JSManagedValue` 的强引用，并使用 `JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法进行注册。相应的，当不再需要时，使用 `removeManagedReference(_:withOwner:)` 方法移除注册。当注册的引用全部被移除时，相关对象才能被垃圾回收器回收。

## JSManagedValue

`JSManagedValue` 用于包装 `JSValue`，从而解决原生代码持有 `JSValue` 的强引用时可能引发的循环引用问题。

只要满足下列条件之一，`JSManagedValue` 就会保留 `JSValue`：

- 被包装的 `JSValue` 未被 `JavaScript` 的垃圾回收器回收。
- `JSManagedValue` 被原生对象持有，并使用 `JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法注册。

如果上述两个条件均不满足，`JSManagedValue` 会将其 `value` 属性设置为 `nil`，并释放其包装的 `JSValue`。

`JSManagedValue` 对 `JSValue` 的引用可以理解为“垃圾收集型引用”。如果没有使用 `JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法进行注册，这种引用类似于弱引用，一旦 `JSValue` 被回收，`JSManagedValue` 的 `value` 属性会自动变为 `nil`。而注册之后，这种引用类似于强引用，在移除注册前，`JSValue` 会被一直保留。`JSManagedValue` 会在 `delloc` 方法中自动移除注册。

## JSExport

`JSExport` 协议用于将原生代码中的类，及其实例方法、类型方法以及属性暴露给 `JavaScript`。

将原生代码暴露给 `JavaScript`：

```Objective-C
@protocol MyPointExports <JSExport>
@property double x;
@property double y;
- (NSString *)description;
- (instancetype)initWithX:(double)x y:(double)y;
+ (MyPoint *)makePointWithX:(double)x y:(double)y;
@end
 
@interface MyPoint : NSObject <MyPointExports>
// 此方法不在协议中，因此不会暴露给 JavaScript
- (void)myPrivateMethod;  
@end
 
@implementation MyPoint
// 方法实现。。。
@end
```

在 `JavaScript` 中使用时：

```Objective-C
// 暴露 MyPoint
context[@"MyPoint"] = [MyPoint class];
```

```JavaScript
// 构造器
var point = new MyPoint(1, 2);
// 属性
point.x;
point.x = 10;
// 实例方法
point.description();
// 类型方法
var q = MyPoint.makePointWithXY(0, 0);
```

对于属性特性，有如下特点：

- `readonly` 特性对应 `writable: false，enumerable: false，configurable: true`
- `readwrite` 特性对应 `writable: true，enumerable: true，configurable: true`

`Objective-C` 选择器暴露给 `JavaScript` 后，所有冒号（`:`）都会被移除，并且冒号之后的第一个小写字母会变为大写，例如 `doFoo:withBar:` 会变为 `doFooWithBar`。对于具有参数的选择器，可以使用 `JSExportAs` 宏来重命名，如下示例将 `doFoo:withBar:` 重名为 `doFoo`：

```Objective-C
@protocol MyClassJavaScriptMethods <JSExport>
JSExportAs(doFoo, - (void)doFoo:(id)foo withBar:(id)bar);
@end
```

<a name="memory_management_caveats"></a>
## 内存管理注意事项

<a name="Capturing_JavaScriptCore_Object"></a>
### 避免在闭包中捕获 JSValue 或 JSContext 对象

若要在闭包中访问这些对象，应将其作为参数传入，或是通过 `JSContext` 在闭包内获取相关 `JSValue` 对象，可通过 `[JSContext currentContext]` 在闭包中获取 `JSContext`。

```Objective-C
JSContext *context = [[JSContext alloc] init];
context[@"callback"] = ^(NSString *text){
	JSValue *object = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
	object[@"x"] = 2;
	object[@"y"] = 3;
	return object;
}
```

<a name="Managed_References"></a>
### 避免直接储存 JSValue 对象

`JSValue` 像其他原生对象一样，可以作为实例变量或属性：

```Objective-C
@interface NativeObject () { 
	JSValue *_value1;
}
@property (nonatomic) JSValue *value2;
@end
```

这时候要格外注意不要引发循环引用。举个例子，通过如下代码添加一个 `JavaScript` 函数，用于弹出一个原生弹窗，并且点击弹窗的 `success` 和 `failure` 两个按钮则应分别调用相应的 `JavaScript` 函数。两个 `JavaScript` 回调函数以 `JSValue` 的形式作为闭包参数传入，`NativeAlertView` 需要保存它们以供按钮被点击时调用相对应的 `JavaScript` 函数。

```Objective-C
self.context[@"presentNativeAlert"] = ^(JSValue *success, JSValue *failure) {
	JSContext *context = [JSContext currentContext]; 
	NativeAlertView *alertView = [[NativeAlertView alloc]
		initWithSuccess:success failure:failure context:context];
	[alertView show];
};
```

`NativeAlertView` 不应直接持有两个 `JavaScript` 函数的 `JSValue`，而是应该使用 `JSManagedValue` 对 `JSValue` 进行包装：

```Objective-C
@interface NativeAlertView() <UIAlertViewDelegate>
@property (nonatomic) JSContext *context;
@property (nonatomic) JSManagedValue *successHandler;
@property (nonatomic) JSManagedValue *failureHandler;
@end

...

// 在初始化方法中
_context = context;
_successHandler = [JSManagedValue managedValueWithValue:success];
[context.virtualMachine addManagedReference:_successHandler withOwner:self];
_failureHandler = [JSManagedValue managedValueWithValue:failure];
[context.virtualMachine addManagedReference:_failureHandler withOwner:self];
```

在弹窗按钮被点击时，调用相应的回调函数，并从 `JSVirtualMachine` 移除之前添加的 `JSManagedValue` 对象：

```Objective-C
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (/*点击 failure 按钮*/) { 
		JSValue *function = [self.failureHandler value]; 
		[function callWithArguments:@[]];
	} else {
		JSValue *function = [self.successHandler value];
		[function callWithArguments:@[]]; }
	}
	
	[self.context.virtualMachine removeManagedReference:self.failureHandler withOwner:self];
	[self.context.virtualMachine removeManagedReference:self.successHandler withOwner:self];
}

```

<a name="Simple_Example"></a>
## 简单使用示例

```JavaScript
<html>
	<head>
		<meta charset="UTF-8">
		<script>
			var share = function() {
				OCDelegate.share({"title":"我是标题", "content":"我是内容", "time":233});
				presentNativeAlert("分享成功");
			}
			var changeButtonTitle = function(title) {
				document.getElementById("shareButton").value = title;
				return 233;
			}
		</script>
	</head>
	<body>
		<input type="button" id="shareButton" value="分享" onclick="share()">
	</body>
</html>
```

在上述代码中，点击分享按钮会调用 `OCDelegate` 对象的 `share` 方法，并传入参数字典。稍后会设置一个代理对象作为 `OCDelegate` 对象，并实现 `share:` 方法，这样点击网页上的分享按钮就会调用代理对象的相应方法。`presentNativeAlert` 函数则会由原生代码通过闭包来提供具体实现。`changeButtonTitle` 则是为了演示原生代码调用 `JavaScript` 函数。

如前所述，原生代码通过 `<JSExport>` 协议将方法暴露给 `JavaScript`，针对上面的情况，这里将 `share:` 方法暴露出去：

```Objective-C
@protocol LXJSExport <JSExport>
- (void)share:(NSDictionary *)json;
@end
```

然后引入一个代理对象来实现该协议：

```Objective-C
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
```

在示例中，使用的 `UIWebView` 加载网页，可在网页加载完毕后设置执行环境：

```Objective-C
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
```
