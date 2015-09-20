## ChatUIDemo

这几天学习`XMPP`框架就试着弄了个聊天气泡和多行输入框...在这里记录下一些思路.

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/%E6%88%AA%E5%9B%BE1.gif)

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/%E6%88%AA%E5%9B%BE2.gif)

## 聊天气泡

这个用的是`UILabel`展示文字配合`UIImageView`展示气泡背景图片.貌似也有用`UIbutton`的,不过自动布局老是算不好就放弃这个方案了- -.

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/cell%20%E7%BA%A6%E6%9D%9F%E6%88%AA%E5%9B%BE.png)

指定`UILabel`的`preferredMaxLayoutWidth`,就能根据文本内容算出高度了.进而可以确定`UIImageView`以及 cell 的行高.

```objective-c
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _contentLabel.preferredMaxLayoutWidth =
        LXKeyWindow().lx_width - _labelLeadingConstraint.constant * 2;
}
```

为了计算行高,引入了一个模板 cell 以及缓存行高的数组:

```objective-c
- (LXMessageCell *)templateCell
{
    if (!_templateCell) {
        // 老外说这样获取 cell 由于没有返回会造成内存泄漏,暂时还没发现.
        _templateCell = [_tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    }
    return _templateCell;
}

- (NSMutableArray<NSNumber *> *)rowHeightCache
{
    if (!_rowHeightCache) {
        _rowHeightCache = [NSMutableArray new];
    }
    return _rowHeightCache;
}
```

然后在`UITableViewDelegate`方法中用模板 cell 根据`AutoLayout`计算并返回高度:

```objective-c
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果缓存高度存在就直接返回缓存的高度.
    NSUInteger index = indexPath.row;
    if (index < self.rowHeightCache.count) {
        return [self.rowHeightCache[index] doubleValue];
    }

    // 将文本内容设置给 cell 的 label, 根据约束计算高度.
    LXMessageCell *templateCell = self.templateCell;
    templateCell.message = _messages[index];
    
    // 触发约束以及布局过程.
    [templateCell layoutIfNeeded];
    // 获取根据约束算出的高度.
    CGFloat rowHeight = [templateCell.contentView
                         systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    // 将高度缓存
    [self.rowHeightCache addObject:@(rowHeight)];

    return rowHeight;
}
```

这个学习自这两篇博客:

[使用Autolayout实现UITableView的Cell动态布局和高度动态改变](http://www.imooc.com/wenda/detail/245446)

[优化UITableViewCell高度计算的那些事 ](http://blog.sunnyxx.com/2015/05/17/cell-height-calculation/)

以及这个库:

[UITableView-FDTemplateLayoutCell](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell)

关键在于`UILabel`必须能确定自己的宽度,我这里是一开始就手动指明了`preferredMaxLayoutWidth`.

否则就需要在代理方法中设置 cell 的宽度:

```objective-c
templateCell.lx_width = self.tableView.lx_width;
```

然后在 cell 的`layoutSubviews`方法中:

```objective-c
// 触发 contentView 的布局,从而让子控件 label 获得正确的宽度.
[self.contentView layoutIfNeeded];
// 进而设置 label 的 preferredMaxLayoutWidth.
_contentLabel.preferredMaxLayoutWidth = _contentLabel.lx_width;
```

这种里应外合的方式还是比较麻烦的,`UITableView-FDTemplateLayoutCell`这个库采用的方案是为 cell 的`contentView`临时加一个宽度约束,然后调用`systemLayoutSizeFittingSize:`方法计算出高度后再移除约束:

```objective-c
NSLayoutConstraint *tempWidthConstraint =
        [NSLayoutConstraint constraintWithItem:cell.contentView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:contentViewWidth];
[cell.contentView addConstraint:tempWidthConstraint];
// Auto layout engine does its math
fittingSize = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
[cell.contentView removeConstraint:tempWidthConstraint];
```

其实最开始用的是动态行高:

```objective-c
self.tableView.estimatedRowHeight = 233;
self.tableView.rowHeight= UITableViewAutomaticDimension;
```

结果发现这样会导致发送多行消息时气泡出来时偶尔会变形一下,猜测是预估行高和实际行高的差异造成的.

## 多行输入框

#### 输入框外观

输入框使用的是`UITextView`.由于无法设置图片,就设置的`layer`的边框圆角,宽度,颜色,效果还不错...

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/UITextView%E8%BE%B9%E6%A1%86%E8%AE%BE%E7%BD%AE%E6%88%AA%E5%9B%BE.png)

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/%E8%BE%93%E5%85%A5%E6%A1%86%E5%A4%96%E8%A7%82%E6%88%AA%E5%9B%BE.png)

#### 输入框高度

每当`UITextView`的`contentSize.height`变化,动画更新高度约束即可.

打印发现`UITextView`创建出来时`contentSize.height`只有`20`,开始输入后才会变为正常.经过试验,发现`contentSize.height`刚好等于`ceil(font.lineHeight + textContainerInset.top + textContainerInset.bottom)`.

这样在`awakeFromNib`方法中修改`UITextView`的高度约束即可,光标也会随之垂直居中显示了:

```objective-c
CGFloat height = ceil(font.lineHeight + textContainerInset.top + textContainerInset.bottom);
_textViewHeightConstraint.constant = height;
```

后来发现达到最大高度进入滚动模式时,输入框上部超出可见范围的行不能完全滚出屏幕,总是会露出文字下半部分.

这就需要设置上下间距为文本的行间距,而普通文本的行间距为`0`,这样会显得上下间距非常拥挤.

经过各种坑方案,发现只要在`awakeFromNib`方法中设置`UITextView`的`typingAttributes`属性即可:

```objective-c
// 修改行间距.
NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
paragraphStyle.lineSpacing = kLXLineSpacing;
NSDictionary *attributes = @{ NSFontAttributeName : _textView.font,
                              NSParagraphStyleAttributeName : paragraphStyle };
_textView.typingAttributes = attributes;

// 修改上下间距为行间距.这样进入滚动模式后能精确的换行,上一行的字不会露出来一部分.
_textView.textContainerInset = UIEdgeInsetsMake(kLXLineSpacing, 0, kLXLineSpacing, 0);
```

换行效果如下:

![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/%E6%8D%A2%E8%A1%8C%E6%88%AA%E5%9B%BE1.png)
![](https://github.com/949478479/Learning-Notes/blob/master/ChatUIDemo-screenshot/%E6%8D%A2%E8%A1%8C%E6%88%AA%E5%9B%BE2.png)

另一个问题是进入滚动模式时,自动换行无法完全滚至最底部,有点难看,手动按换行键则不存在这个问题.

试着子类化`UITextView`并实现下面这个方法,解决了这个问题:

```objective-c
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // 强制滚动至底部.可修复输入框达到最大高度时自动换行无法完全滚动至最底部的问题.
    rect.size.height = self.contentSize.height - rect.origin.y;
    [super scrollRectToVisible:rect animated:animated];
}
```

关于输入框最大高度,经过试验发现,每换一行高度增加`round(font.lineHeight + kLXLineSpacing)`.个别情况可能会偏差一个点,所以干脆用`ceil`上舍入好了:

```objective-c
_maxHeight = height + round(_textView.font.lineHeight) * (kLXMaxCountOfRows - 1);
```

在`UITextView`的代理方法`textViewDidChange:`中对`contentSize.height`进行判断,一旦和高度约束不一样,就更新高度约束.而一旦超过了最大高度,就不再更新,从而进入滚动状态:

```objective-c
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGFloat contentSizeHeight = _textView.contentSize.height;
    CGFloat delta = contentSizeHeight - _textViewHeightConstraint.constant;

    // 尚未达到最大高度,且高度发生了变化.(达到最大高度后会进入滚动模式,高度不再增大,只可能减小.)
    if (contentSizeHeight <= _maxHeight && ABS(delta))
    {
        _textViewHeightConstraint.constant = contentSizeHeight;
        [UIView animateWithDuration:kLXAnimationDuration animations:^{
            // 如果代理不实现就自己调用 layoutIfNeeded.
            if ([_delegate respondsToSelector:@selector(inputView:changeHeight:)]) {
                [_delegate inputView:self changeHeight:contentSizeHeight];
            } else {
                [self layoutIfNeeded];
            }
        }];
    }
}
```

#### 输入框高度变化的影响

由于输入框高度可能会变化,所以定义了这个代理方法来通知代理更新布局:

```objective-c
- (void)inputView:(LXInputView *)inputView changeHeight:(CGFloat)height
```

代理在此方法中根据需要更新布局,在这里是让 tableView 在输入框高度改变时滚到最后一行,否则会因为高度变化被遮挡:

```objective-c
- (void)inputView:(LXInputView *)inputView changeHeight:(CGFloat)height
{
    // 滚动到最底部时才随着输入框高度变化滚动.不然输入框高度变化可能会导致从上面滚到底部,体验不好.
    // 由于该判断涉及到 tableView 高度,所以需放在 layoutIfNeeded 前面.
    BOOL shouldScroll = [self isTableViewAtBottom];

    [self.view layoutIfNeeded];

    if (shouldScroll && _messages.count) {
        // 这里没有选择开启动画,因为和输入框高度动画不同步.由于变化幅度比较小,不加动画反而效果更好.
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
    }
}
```

还有个细节就是发送按钮按下时通知代理的时机.我定义了这个代理方法:

```objective-c
- (void)inputView:(LXInputView *)inputView sendMessage:(NSString *)message;
```

在发送按钮按下时代理会在该方法中发送消息并刷新表格之类的.但是由于`UITableView`底部约束加在了输入框的顶部,导致发送多行消息时,由于输入框内容被清空导致高度变化,从而影响`UITableView`的高度,这个动画和刷新表格的动画同时发生时效果很不自然.

最后采取的办法是单行时直接通知代理,多行时等输入框高度变化的动画结束时再通知代理.

## 键盘处理

因为 tableView 的底部和输入框的顶部约束在了一起,所以键盘弹出时,更改输入框底部距离屏幕底部的约束为键盘高度即可, tableView 会随之上移.

在这个过程还需要让 tableView 滚动至最后一行,否则高度的减小会导致 cell 被遮挡.这高度动画和滚动动画的重叠导致效果有些不自然.

经过试验,当 tableView 已经位于最后一行时,就不要使用动画滚动,这样的效果就是 tableView 好像直接平移上来一样.
而当 tableView 未处于最后一行时,则使用动画滚动,效果差强人意.

```objective-c
- (void)keyboardWillShowHandle:(NSNotification *)notification
{
    NSDictionary *userInfo  = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight  = CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);

    // 由于该判断涉及到 tableView 高度,所以需放在 layoutIfNeeded 前面.
    BOOL animated = ![self isTableViewAtBottom];

    _inputViewbottomLayoutConstraint.constant = keyboardHeight;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];

    if (_messages.count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
    }
}
```

## 表视图刷新

每次发送和接收消息时,插入新行,并让 tableView 滚动至最后一行,呈现出新消息滚入屏幕的效果.

而处于 tableView 的中部时,由于滚动动画涉及到很多行,非常眼晕,这里采取的是先无动画切换到倒数第二行,然后再滚动.

```objective-c
- (void)reloadDataWithMessage:(nonnull NSString *)message
{
    [_messages addObject:message];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];

    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if (![self isTableViewAtBottom] && _messages.count >= 2) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 2 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
    }

    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:YES];
}
```
