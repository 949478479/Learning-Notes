# UISearchController

学习自 `RayWenderlich` 的教程 [UISearchController Tutorial: Getting Started](http://www.raywenderlich.com/113772/uisearchcontroller-tutorial)。

iOS 8 引入了 `UISearchController`，可以非常方便地实现搜索功能，虽然暂时不支持 IB，但是使用代码创建也非常方便：

```swift
// 指定一个视图控制器来展示搜索结果，如果传入 nil，则使用当前的视图控制器
let searchController = UISearchController(searchResultsController: nil)

override func viewDidLoad() {
    super.viewDidLoad()
    
    // 搜索框内容变化时，会通知该代理来更新搜索结果，一般可设置为当前的控制器
    searchController.searchResultsUpdater = self
    // 搜索框激活时，是否产生蒙版效果，由于使用同一个视图控制器来展示搜索结果，因此不需要这种蒙版效果
    searchController.dimsBackgroundDuringPresentation = false
    // 让当前视图控制器定义上下文，否则在搜索框激活的情况下，跳转到其他视图控制器后搜索框依然会存在
    definesPresentationContext = true
    // 直接将搜索框设置为 tableHeaderView 即可
    tableView.tableHeaderView = searchController.searchBar
}
```

搜索框内容变化时，会通知 `searchResultsUpdater`，作为代理需实现 `UISearchResultsUpdating` 协议：

```swift
func updateSearchResultsForSearchController(searchController: UISearchController) {
    // 搜索框内容变化时，根据搜索框内容对数据进行适当过滤
    filteredDataArray = dataArray.filter {
        $0.rangeOfString(searchController.searchBar.text!, options: .CaseInsensitiveSearch) != nil
    }
    // 使用同一个表视图来展示搜索结果
    tableView.reloadData()
}
```

在数据源方法中，可以进行判断，决定显示普通数据，还是搜索结果，例如：

```swift
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.active && !searchController.searchBar.text!.isEmpty {
        // 搜索框激活，且内容不为空，此时显示对应搜索结果
        return filteredDataArray.count
    } else {
        // 其他情况下，显示正常的数据
        return dataArray
    }
}
```

另外，`UISearchController` 还有个 `delegate` 属性，支持如下代理方法：

```swift
protocol UISearchControllerDelegate : NSObjectProtocol {
    // 只有手动激活或者取消搜索控制器时才会触发这些方法
    optional func willPresentSearchController(searchController: UISearchController)
    optional func didPresentSearchController(searchController: UISearchController)
    optional func willDismissSearchController(searchController: UISearchController)
    optional func didDismissSearchController(searchController: UISearchController)
    
    // 当搜索控制器被激活，无论是点击搜索框激活还是设置 active 属性为 true 来激活，均会调用此方法，
    // 可以在这里自定义搜索控制器的 present 过程，否则系统会使用默认的效果
    optional func presentSearchController(searchController: UISearchController)
}
```