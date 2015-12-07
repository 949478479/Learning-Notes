# 利用 SFSafariViewController 为应用内置 Safari 浏览器

iOS 9 引入了 `SFSafariViewController`，其效果就是个应用内的 Safari 浏览器，使用起来非常方便，如下所示：

```swift
let url = NSURL(string: "https://baidu.com")!
let safariVC = SFSafariViewController(URL: url)
showDetailViewController(safariVC, sender: nil)
```

`SFSafariViewController` 还有三个代理方法，如下所示：

```swift
protocol SFSafariViewControllerDelegate : NSObjectProtocol {
    // 点击 Action 按钮后，会弹出活动菜单，可通过此方法提供额外的功能
    func safariViewController(controller: SFSafariViewController, activityItemsForURL URL: NSURL, title: String?) -> [UIActivity]
    // 在 modal 模式下，点击 Done 按钮后，此方法就会调用
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    // 初始化 SFSafariViewController 的 URL 加载完毕后，此方法会调用
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool)
}
```
