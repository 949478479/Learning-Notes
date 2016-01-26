# iOS 8 后读取、更新、删除数据的新功能

## 使用 NSAsynchronousFetchRequest 异步读取数据

`iOS 8` 引入了 `NSAsynchronousFetchRequest`，可以方便地异步读取数据，该操作直接作用于持久化存储，不会影响 Managed Object Context。不过目前这部分内容并没有详细文档，只在头文件中稍有提及。

```swift
let fetchRequest = NSFetchRequest(entityName: "Department")
// NSAsynchronousFetchRequest 并非 NSFetchRequest 子类，而是 NSPersistentStoreRequest 子类，二者是平级的
let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { 
    [unowned self] result: NSAsynchronousFetchResult in
    let departments = result.finalResult as! [Department]
}

do {
    // 可以用 NSPersistentStoreAsynchronousResult 取消读取操作，只需调用 cancel() 方法
    let result = try managedObjectContext.executeRequest(asyncFetchRequest) as! NSPersistentStoreAsynchronousResult
} catch let error as NSError {
    print("Could not fetch. \(error.localizedDescription)")
}
```

## 使用 NSBatchUpdateRequest 批量更新数据

`iOS 8` 引入了 `NSBatchUpdateRequest`，可以直接作用于持久化存储，而不用加载数据到内存，从而高效地批量更新数据，减少内存开销。这部分内容也没有详细文档，另外，由于直接作用于持久化存储，无法对数据进行验证操作。

```swift
let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Book")
// 指定要更新的属性，字典的键是 NSPropertyDescription 或属性名称，值是常量值或结果为常量值的 NSExpression
batchUpdateRequest.propertiesToUpdate = ["favorite":true]
// 指定返回结果，这里为被更新对象的数量，指定 UpdatedObjectIDsResultType 可获取被更新对象的 NSManagedObjectID 数组
batchUpdateRequest.resultType = .UpdatedObjectsCountResultType
// 指定要操作的持久化存储
batchUpdateRequest.affectedStores = managedObjectContext.persistentStoreCoordinator!.persistentStores

do {
    let batchResult = try managedObjectContext.executeRequest(batchUpdate) as! NSBatchUpdateResult
    print("Records updated \(batchResult.result!)")
} catch let error as NSError {
    print("Could not update. \(error.localizedDescription)")
}
```

## 使用 NSBatchDeleteRequest 批量删除数据

`iOS 9` 引入了 `NSBatchDeleteRequest`，支持批量删除数据，用法和特点与 `NSBatchUpdateRequest` 十分类似。

## 使用 NSExpressionDescription 对结果进行处理

这个和新特性无关，只是一点补充。

例如，要统计各个 `Department` 中的 `employeeCount` 之和，可以使用 `NSExpressionDescription` 来完成：

```swift
let sumExpressionDescription = NSExpressionDescription()
// 指定表达式名字，这会作为结果字典中的键
sumExpressionDescription.name = "sum" 
// 由于是求和，因此根据函数 sum: 构建表达式，其他支持的函数可参阅 NSExpression 文档
// 参数 arguments 的类型是 [NSExpression]，
// 下面指定的这个表达式会根据 valueForKeyPath: 获取 Department 实例的 employeeCount 的值，从而进行求和
sumExpressionDescription.expression = NSExpression(forFunction: "sum:",
    arguments: [NSExpression(forKeyPath: "employeeCount")])
// 指定返回结果的类型
sumExpressionDescription.expressionResultType = .Integer32AttributeType

let fetchRequest = NSFetchRequest(entityName: "Department")
// 这种情况下返回结果类型必须是 DictionaryResultType
fetchRequest.resultType = .DictionaryResultType
// 设置要 fetch 的属性，也就是 NSPropertyDescription 及其子类实例
fetchRequest.propertiesToFetch = [sumExpressionDescription]

do {
    // 使用 DictionaryResultType 类型时，结果数组中的元素是一个字典，根据表达式的名字从字典中取出表达式的结果
    let results = try managedObjectContext.executeFetchRequest(fetchRequest)
    print("sum: \(results[0][sumExpressionDescription.name]!)")
} catch let error as NSError {
    print("Could not fetch. \(error.localizedDescription)")
}
```
