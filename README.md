# QQFriendListDemo

仿 QQ 好友下拉列表...

![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/screenshot.gif)

思路是子类化`UITableViewHeaderFooterView`,提供自定义的`headerView`.

使用一个等大的按钮作为其子控件,并设置相应图片即可.最右侧则是一个`UILabel`.如图所示:

![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/headerView.png)

设置按钮的内容左对齐,并适当调整`image`和`title`的内切距离.

![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/buttonAlignment.png)
![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/imageInset.png)
![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/titleInset.png)

为了在`headerView`被点击时能得到通知,定义了一个代理方法:

```objective-c
- (void)headerViewDidTapped:(LXHeaderView *)headerView;
```

为了标识出具体是哪一组,定义了个一个`section`属性:

```objective-c
@property (nonatomic, assign) NSInteger section;
```

在`UITableView`的代理方法中,提供自定义的`headerView`,设置代理,并绑定对应的`section`:

```objective-c
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LXHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLXHeaderViewIdentifier];

    headerView.section    = section;
    headerView.delegate   = self;
    headerView.groupModel = self.groupModels[section];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kLXHeaderViewHeight;
}
```

`headerView`被点击时,对`button`的`imageView`做一个旋转动画,并通知代理:

```objective-c
[UIView animateWithDuration:0.25 animations:^{
    _button.imageView.transform = CGAffineTransformMakeRotation(_groupModel.open ? M_PI_2 : 0);
}];

if ([_delegate respondsToSelector:@selector(headerViewDidTapped:)]) {
    [_delegate headerViewDidTapped:self];
}
```

这里有个问题就是`button`的`imageView`旋转后,小三角图片两侧会超出范围.如图:

![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/buttonImageView.png)

因此还需要对`button`进行如下设置:

```objective-c
// 防止旋转后超出范围的图片被裁剪掉.
_button.imageView.clipsToBounds = NO;
// 防止旋转后图片变形.
_button.imageView.contentMode = UIViewContentModeCenter;
```

代理收到`headerView`被点击的回调后,就可以让`tableView`刷新该组:

```objective-c
[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:headerView.section]
              withRowAnimation:UITableViewRowAnimationAutomatic];
```

最后还有个细节就是快速点击`headerView`时按钮不会呈现高亮状态,这个可以通过关闭`UIScrollView`的`delaysContentTouches`解决:

![](https://github.com/949478479/Learning-Notes/blob/master/QQFriendListDemo-screenshot/delayTouch.png)

但是这样也会导致触摸点在`headerView`上也就是`UIButton`上时无法滚动`tableView`,所以还需要继承`UITableView`,重写下面这个方法:

```objective-c
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    /* 
     此方法默认实现为若 view 为 UIControll, 则返回 NO.
     这将导致在 headerView 上滑动时, tableView 会转发消息给 button 而自己无法滑动. */
    return YES;
}
```
