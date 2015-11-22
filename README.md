# 初窥 iOS 9 Contacts Framework

出自 `AppCoda` 的教程 [A First Look at Contacts Framework in iOS 9](http://www.appcoda.com/ios-contacts-framework/) 。

中文版传送门 [初窥 iOS 9 Contacts Framework](http://www.cocoachina.com/ios/20151111/14077.html) 。

这里主要是记录一些学习笔记。

- [请求权限](#RequestAccess)
- [获取联系人](#FetchContact)
- [创建与更新联系人](#Create&Update)
- [联系人姓名与地址格式化](#Format)
- [CNContactPickerViewController](#CNContactPickerViewController)
- [CNContactViewController](#CNContactViewController)

<a name="RequestAccess"></a>
## 请求权限

在获取联系人时，以及创建、保存、更新联系人时，都需要用户同意。使用`CNContactStore`的如下实例方法获取权限：

```swift
/*!
 * @discussion 此方法用于获取访问权限，只会在初次询问用户时弹窗，之后都会沿用用户先前的选择结果。
 *             此方法完成后，会在后台线程调用闭包，因此官方建议在此闭包中调用 CNContactStore
 *             的其他实例方法来操作联系人数据库，从而避免阻塞 UI 线程。
 *
 * @param entityType 该参数为 CNEntityType 枚举类型，目前只有一个值 .Contacts。
 * @param completionHandler 此闭包会在获取权限完成时调用。
 *                          若用户许可，则 granted 为 true，且 error 为 nil。
 *                          否则 granted 为 false，且伴随一个 error 值。
*/
func requestAccessForEntityType(entityType: CNEntityType, completionHandler: (Bool, NSError?) -> Void)
```

具体使用类似这样：

```swift
// CNContactStore 并未提供单例方法，所以需要自己创建一个实例
CNContactStore().requestAccessForEntityType(.Contacts) { granted, error in
    guard granted else {
        // 用户拒绝
        return
    }
    // 用户许可
}
```

还可以使用下面这个类方法来查看当前权限：

```swift
class func authorizationStatusForEntityType(entityType: CNEntityType) -> CNAuthorizationStatus
```

权限状态总共有四种：

```swift
enum CNAuthorizationStatus : Int {
    case NotDetermined // 用户尚未决定。
    case Restricted    // 应用无权限访问，用户也由于家长控制之类的原因无权限修改设置。
    case Denied        // 用户禁止。
    case Authorized    // 用户许可。 
}
```

<a name="FetchContact"></a>
## 获取联系人

每个联系人用`CNContact`对象表示，它提供了很多表示联系人资料的属性，例如`familyName`，`birthday`，
`emailAddresses`，`phoneNumbers`等。

一般可通过`CNContactStore`的以下几个实例方法获取联系人：

```swift
/*!
 * @discussion 根据指定谓词来获取匹配的联系人若要获取全部联系人，则可使用
 *             enumerateContactsWithFetchRequest(_:error:usingBlock:) 实例方法。 
 *
 * @param predicate 该谓词必须是使用 CNContact 的类方法创建的谓词，不能自行创建。
 * @param keys 通过 key 或 CNKeyDescriptor 指定要获取 CNContact 对象的属性。
 *
 * @return 返回 CNContact 对象的数组，若无匹配的联系人则返回空数组。
 */
func unifiedContactsMatchingPredicate(predicate: NSPredicate, keysToFetch keys: [CNKeyDescriptor])
    throws -> [CNContact]
```
```swift
// 利用 CNContact 提供的相应类方法生成谓词。
let predicate = CNContact.predicateForContactsMatchingName("联系人名字")
// 通过 key 指定要获取的各种属性，对于 CNContact 对象，只有获取过的属性才可以被访问，否则会引发异常。
let keysToFetch = [
    CNContactEmailAddressesKey,    // 对应 CNContact 对象的 emailAddresses 属性。
    CNContactBirthdayKey,          // 对应 CNContact 对象的 birthday 属性。
    CNContactThumbnailImageDataKey // 对应 CNContact 对象的 thumbnailImageData 属性。
    // 除了可以指定 key，还可以指定 CNKeyDescriptor，可以看做是一系列 key 的合集。
    // 例如，可以使用 CNContactFormatter 的类方法生成一系列 .FullName 风格下需要的 key。
    // 这将包括 CNContactGivenNameKey，CNContactMiddleNameKey，CNContactFamilyNameKey 等一系列 key。
    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
]
do {
    let contacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
} catch {
    print("\((error as NSError).localizedDescription)")
}
```
```swift
/*!
 * @discussion 根据指定 CNContact 对象的 identifier 获取指定联系人。若要获取一批联系人，可以使用
 *             CNContact 的类方法 predicateForContactsWithIdentifiers(_:) 生成对应谓词，然后使用
 *             CNContactStore 的实例方法 unifiedContactsMatchingPredicate(_:keysToFetch:) 方法来获取。
 *
 * @param identifier CNContact 对象的 identifier，可通过其同名属性获得。
 * @param keys 通过 key 或 CNKeyDescriptor 指定要获取的 CNContact 对象的属性。
 *
 * @return 返回获取到的 CNContact 对象，若不存在则抛出 CNErrorCodeRecordDoesNotExist 错误。
     */
func unifiedContactWithIdentifier(identifier: String, keysToFetch keys: [CNKeyDescriptor])
    throws -> CNContact
```
```swift
// 访问 CNContact 的某个属性时，该属性必须获取过，否则会抛出 CNContactPropertyNotFetchedExceptionName 异常。
// 因此上面的方法常用于重新获取某个联系人，可通过下面这个 CNContact 的实例方法检测对应属性是否已获取。
if !aContact.isKeyAvailable(CNContactFamilyNameKey) {
    do {
        // 由于 familyName 属性未获取，则需要重新获取该联系人，才可以访问其 familyName 属性。
        let keysToFetch = [CNContactFamilyNameKey]
        let refetchedContact = try CNContactStore().unifiedContactWithIdentifier(aContact.identifier,
            keysToFetch: keysToFetch)
    } catch {
        print("\((error as NSError).localizedDescription)")
    }
}
```
```swift
/*!
 * @discussion 根据获取请求获取联系人并进行遍历。
 *
 * @param fetchRequest 利用一个 CNContactFetchRequest 对象指定获取请求。
 * @param block 每匹配到一个联系人就会调用一次闭包。通过设置 *stop 为 true 来停止遍历。
 */
func enumerateContactsWithFetchRequest(fetchRequest: CNContactFetchRequest, 
    usingBlock block: (CNContact, UnsafeMutablePointer<ObjCBool>) -> Void) throws
```
```swift
let keysToFetch = [CNContactFamilyNameKey]
let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
do {
    try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { contact, stop in
        // 针对遍历到的 CNContact 对象做些处理。
        // stop.memory = true 可通过设置 stop 为 true 来停止遍历。
    }
} catch {
    print("\((error as NSError).localizedDescription)")
}
```

另外，使用`CNContactStore`时，文档给出了以下建议：

- 应该只获取`CNContact`要被访问的属性，不要获取用不到的属性。
- 获取大量联系人数据时，应该先拿到`identifier`，然后根据需要利用这些`identifier`分批次获取具体属性。
- 缓存了联系人数据时，一旦收到`CNContactStoreDidChangeNotification`通知，则应该移除旧数据，重新获取新数据。

<a name="Create&Update"></a>
## 创建与更新联系人

创建与更新联系人需要创建相应的`CNSaveRequest`对象，然后用`CNContactStore`对象执行请求：

```swift
// CNContact 对象都是不可变的，想要编辑属性需要使用可变子类 CNMutableContact，可通过 mutableCopy() 获取。
let newContact = CNMutableContact()
newContact.givenName = "..."
newContact.familyName = "..."
// emailAddresses 是个数组，其内容为 CNLabeledValue 对象，需要指定标签和值。
// 这里使用系统提供的 CNLabelHome 标签。
newContact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: "xxx@example.com")]

// 创建请求，由于是新建联系人，因此使用 addContact(_:toContainerWithIdentifier:) 方法。
let saveRequest = CNSaveRequest()
saveRequest.addContact(newContact, toContainerWithIdentifier: nil)

// 执行创建请求。
do {
    try CNContactStore().executeSaveRequest(saveRequest) 
} catch {
    print("\((error as NSError).localizedDescription)")
}
```

另外，创建联系人时，最好检查下联系人是否已经存在，否则会重复。

更新与删除联系人时，可使用`CNSaveRequest`的以下方法，用法大同小异：

```swift
func updateContact(contact: CNMutableContact)
func deleteContact(contact: CNMutableContact)
```

<a name="Format"></a>
## 联系人姓名与地址格式化

`CNContactFormatter`提供了一些格式化联系人姓名的方法；`CNPostalAddressFormatter`则提供了一些格式化联系人地址的方法。

根据文档建议，有很多联系人需要格式化时，应该创建实例使用实例方法，否则，使用类方法即可。

```swift
class func stringFromContact(contact: CNContact, style: CNContactFormatterStyle) -> String?
class func attributedStringFromContact(contact: CNContact, style: CNContactFormatterStyle,
    defaultAttributes attributes: [NSObject : AnyObject]?) -> NSAttributedString?
    
func stringFromContact(contact: CNContact) -> String?
func attributedStringFromContact(contact: CNContact, 
    defaultAttributes attributes: [NSObject : AnyObject]?) -> NSAttributedString?
```
```swift
class func stringFromPostalAddress(postalAddress: CNPostalAddress, 
    style: CNPostalAddressFormatterStyle) -> String
class func attributedStringFromPostalAddress(postalAddress: CNPostalAddress, 
    style: CNPostalAddressFormatterStyle,
    withDefaultAttributes attributes: [NSObject : AnyObject]) -> NSAttributedString
    
func stringFromPostalAddress(postalAddress: CNPostalAddress) -> String
func attributedStringFromPostalAddress(postalAddress: CNPostalAddress, 
    withDefaultAttributes attributes: [NSObject : AnyObject]) -> NSAttributedString
```

<a name="CNContactPickerViewController"></a>
## CNContactPickerViewController

除了`Contacts`框架，还有个`ContactsUI`框架，提供了一些 UI 支持，非常好用。

例如，想选择一些联系人时，使用`CNContactPickerViewController`即可，十分方便：

```swift
let contactsPickerVC = CNContactPickerViewController()
// 通过谓词指定列表中的哪些联系人可以选中，不符合要求的联系人则不可选中。
contactsPickerVC.predicateForEnablingContact = NSPredicate(format: "birthday != nil")
contactsPickerVC.delegate = self
showDetailViewController(contactsPickerVC, sender: nil)
```

然后实现相应代理方法即可：

```swift
func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
    // 实现此方法则 CNContactPickerViewController 支持多项选择。
    // 若实现 func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact)，
    // 则只支持单项选择。
}
```

<a name="CNContactViewController"></a>
## CNContactViewController

若想展示联系人详细信息，可以使用`CNContactViewController`：

```swift
// 需要注意，必须确保 CNContact 的相应属性都已获取，否则会引发异常。
// 可以通过 CNContactViewController 的类方法 descriptorForRequiredKeys() 获取全部所需的 key。
let requiredKeys = [CNContactViewController.descriptorForRequiredKeys()]
do {
    let refetchedContact = try CNContactStore().unifiedContactWithIdentifier(aContact.identifier,
        keysToFetch: requiredKeys)
    let contactVC = CNContactViewController(forContact: refetchedContact)
    showViewController(contactVC, sender: nil)
} catch {
    print("\((error as NSError).localizedDescription)")
}
```

还有几个常用属性：

```swift
var allowsEditing: Bool // 是否允许编辑属性，默认为 true。
var allowsActions: Bool // 是否可以执行操作，例如发短信打电话之类，默认为 true。
var displayedPropertyKeys: [AnyObject]? // 只显示指定的联系人信息，例如电话、地址之类的。
```
