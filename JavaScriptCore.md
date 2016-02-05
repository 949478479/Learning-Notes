# JavaScriptCore 学习笔记

## JSValue

`JSValue` 用于表示 `JavaScript` 中的值。利用这个类，可以将基本类型值（例如数字或字符串）在原生代码和 `JavaScript` 代码间进行转换。该类型还可以创建包装了原生代码中自定义类的对象的 `JavaScript` 对象，以及由原生代码中的方法或是闭包来提供实现的 `JavaScript` 函数。

每个 `JSValue` 都来源于 `JSContext`，后者表示前者的 `JavaScript` 执行环境。`JSValue` 会持有自己所属的 `JSContext` 的强引用，这意味着，只要还有一个 `JSValue` 存在，其对应的 `JSContext` 就不会被销毁。通过一个 `JSValue` 得到的另一个 `JSValue` 也将同属于同一个 `JSContext`。

每个 `JSContext` 都关联着一个 `JSVirtualMachine`，因此每个 `JSValue` 也都间接关联着一个 `JSVirtualMachine`。`JSVirtualMachine` 表示底层的执行环境。只能将 `JSValue` 传递给同属于同一个 `JSVirtualMachine` 的 `JSValue` 或 `JSContext`，否则将会引发异常。

## JSContext

`JSContext` 表示 `JavaScript` 执行环境，通过该对象来执行来源自原生代码的 `JavaScript` 脚本，使用原生代码中的对象、方法和函数，而原生代码也能获取由 `JavaScript` 定义或者计算而得的值。

## JSVirtualMachine

`JSVirtualMachine` 表示一个自包含的 `JavaScript` 执行环境。该类有两个作用，即支持 `JavaScript` 并发执行，以及管理对象在原生代码和 `JavaScript` 代码之间桥接时的内存问题。

### 线程与 JavaScript 并发执行

每个 `JSContext` 都从属于一个 `JSVirtualMachine`。每个  `JSVirtualMachine` 可以包含多个 `JSContext`，并允许 `JSValue` 在多个 `JSContext` 间传递。然而，每个 `JSVirtualMachine` 是不同的，不可以将 `JSValue` 在多个 `JSVirtualMachine` 间传递。

`JavaScriptCore` 的 `API` 是线程安全的，例如，一个 `JSValue` 的创建和使用可以分别处于不同线程。然而，当其他线程试图使用同一个 `JSVirtualMachine` 时将会进入等待。因此，为了在多个线程间并发执行 `JavaScript` 代码，应该为每个线程提供一个独立的 `JSVirtualMachine`。

### 管理转换对象的内存

转换原生对象到 `JSValue` 时，必须确保该原生对象没有持有该 `JSValue` 的强引用，否则将导致引用循环，这是因为 `JSValue` 持有其所属的 `JSContext` 的强引用，而 `JSContext` 会持有被转换的原生对象的强引用。作为一种替代方式，使用 `JSManagedValue` 来包装 `JSValue`，让原生对象持有 `JSManagedValue` 的强引用，并使用 `JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法进行注册。相应的，当不再需要时，使用 `removeManagedReference(_:withOwner:)` 方法移除注册。当注册的引用全部被移除时，相关对象才能被垃圾回收器回收。

## JSManagedValue

`JSManagedValue` 用于包装 `JSValue`，从而解决原生对象持有 `JSValue` 的引用时可能引发的循环引用问题。

只要满足下列条件之一，`JSManagedValue` 就会保留 `JSValue`：

- 被包装的 `JSValue` 未被 `JavaScript` 的垃圾回收器回收。
- `JSManagedValue` 被原生对象持有，并使用`JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法注册。

如果上述两个条件均不满足，`JSManagedValue` 会将其 `value` 属性设置为 `nil`，并释放其包装的 `JSValue`。

`JSManagedValue` 的行为非常类似 `weak` 引用，如果没有使用 `JSVirtualMachine` 的 `addManagedReference(_:withOwner:)` 方法来保留被包装的 `JSValue`，当 `JavaScript` 的垃圾回收器销毁 `JSValue` 后，`JSManagedValue` 的 `value` 属性会自动变为 `nil`。

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
// 构造器
var point = MyPoint(1, 2);
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

`Objective-C` 选择器暴露给 `JavaScript` 后，所有冒号（`:`）都会被移除，并且冒号之后的第一个小写字母会变为大写，例如 `doFoo:withBar:` 会变为 `doFooWithBar`。对于具有参数的选择器，可以使用 `JSExportAs` 来重命名，如下示例将 `doFoo:withBar:` 重名为 `doFoo`：

```Objective-C
@protocol MyClassJavaScriptMethods <JSExport>
JSExportAs(doFoo, - (void)doFoo:(id)foo withBar:(id)bar);
@end
```

## 内存管理陷阱

`Objective-C` 和 `Swift` 使用引用计数来管理内存，`JavaScript` 则使用垃圾回收器来管理内存，在相互通信的过程中需要注意一些内存管理问题。

### 避免在闭包中捕获 JavaScriptCore 对象

使用闭包来定义 `JavaScript` 函数时，一定要避免捕获 JavaScriptCore 对象。`JSContext` 持有它所管理的所有 `JSValue` 的强引用，而 `JSValue` 又会持有它所包装的原生对象以及它所属的 `JSContext` 的强引用。`JSContext` 和 `JSValue` 之间虽然形成了循环引用，但 `JavaScript` 的垃圾回收器能够处理这种内部循环引用的情况。但是，一旦闭包捕获了 `JavaScriptCore` 对象，引入了来自外部的强引用，垃圾回收器就不会对相关对象进行回收，导致内存泄漏。

在这种闭包中，若要访问相关 `JavaScriptCore` 对象，应该使用 `JSContext` 的 `current...` 系列方法获取，而不是直接捕获。即使使用 `__weak` 引用，也是不可取的，例如下面这样的代码：

```Objective-C
JSValue *name = [JSValue valueWithObject:@"bar" inContext:_context];__weak JSValue *weakName = name;__weak ViewController *weakSelf = self;_context[@"foo"] = ^{
	__strong typeof(weakSelf) strongSelf = weakSelf;	[strongSelf doSomething:weakName];};
```

正确的做法是将需要的变量作为参数传入：

```Objective-C__weak ViewController *weakSelf = self;_context[@"foo"] = ^(NSString *bar){
	__strong typeof(weakSelf) strongSelf = weakSelf;	[strongSelf doSomething:bar];};
```

### JSManagedValue

`JSValue` 像其他原生对象一样，可以作为实例变量或属性：

```Objective-C
@interface ViewController () { 
	JSValue *value1;}
@property (nonatomic) JSValue *value2;
@end
```

然而，这非常容易引发循环引用，而且，将引用计数和垃圾回收混杂在一起也并非正确做法。`JavaScriptCore` 专门提供了 `JSManagedValue` 来解决这个问题。