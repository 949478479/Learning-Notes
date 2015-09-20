//
//  ViewController.m
//  ChatUIDemo
//
//  Created by 从今以后 on 15/9/9.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXInputView.h"
#import "LXMessageCell.h"
#import "ViewController.h"

@interface ViewController () <NSStreamDelegate, UITableViewDataSource, UITableViewDelegate, LXInputViewDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableArray<NSString *> *messages;

@property (nonatomic, strong) LXMessageCell *templateCell;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *rowHeightCache;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet LXInputView *inputView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputViewbottomLayoutConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottonLayoutConstraint;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerKeyboardNotificaiton];
    [self setupSocket];

    _messages = [NSMutableArray new];
}

#pragma mark - 初始配置

- (void)setupSocket
{
    NSString *const host = @"127.0.0.1";
    UInt32 const port    = 12345;
    CFReadStreamRef readStream   = NULL;
    CFWriteStreamRef writeStream = NULL;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);

    _inputStream  = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    _inputStream.delegate = self;
    _outputStream.delegate = self;

    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

#pragma mark - 键盘处理

- (void)registerKeyboardNotificaiton
{
    [NSNotificationCenter lx_addObserverForKeyboardShowAndHide:self
                                               selectorForShow:@selector(keyboardWillShowHandle:)
                                               selectorForHide:@selector(keyboardWillHideHandle:)];
}

- (void)keyboardWillShowHandle:(NSNotification *)notification
{
    NSDictionary *userInfo  = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardHeight  = CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);

    // 经过反复试验发现 tableView 处于底部时不要使用动画滚动,处于中间时使用动画滚动,效果较好.
    // 由于该判断涉及到 tableView 高度,所以需放在 layoutIfNeeded 前面.
    BOOL animated = ![self isTableViewAtBottom];

    _inputViewbottomLayoutConstraint.constant = keyboardHeight;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];

    [self tableViewScrollToBottomIfNeedWithAnimated:animated];
}

- (void)keyboardWillHideHandle:(NSNotification *)notification
{
    NSDictionary *userInfo  = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    _inputViewbottomLayoutConstraint.constant = 0;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 辅助方法

- (BOOL)isTableViewAtBottom
{
    NSInteger num1 = round(_tableView.contentOffset.y + _tableView.lx_height);
    NSInteger num2 = round(_tableView.contentSize.height);

    if (num1 == num2 || _tableView.contentSize.height <= _tableView.lx_height) {
        return YES;
    }
    return NO;
}

- (void)tableViewScrollToBottomIfNeedWithAnimated:(BOOL)animated
{
    NSUInteger count = [_tableView numberOfRowsInSection:0];
    if (count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
    }
}

#pragma mark - 消息处理

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

    [self tableViewScrollToBottomIfNeedWithAnimated:YES];
}

- (void)writeDataWithMessage:(nonnull NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];

    [_outputStream write:data.bytes maxLength:data.length];

    static int count = 0;
    if (count == 0) {
        ++count;
        message = [message stringByReplacingCharactersInRange:(NSRange){0,4} withString:@"小丽: 我是"];
    }  else {
        message = [message stringByReplacingCharactersInRange:(NSRange){0,4} withString:@"小明: "];
    }
    [self reloadDataWithMessage:message];
}

- (void)readData
{
    uint8_t buff[1024];
    NSUInteger length = [_inputStream read:buff maxLength:1024];
    NSData *data = [NSData dataWithBytes:buff length:length];
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    static int count = 0;
    if (count == 0) {
        ++count;
        message = @"小丽: 我爱学人说话";
    } else {
        message = [message stringByReplacingCharactersInRange:(NSRange){message.length - 1,1}
                                                   withString:@""];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self reloadDataWithMessage:message];
    });
}

#pragma mark - IBAction

- (IBAction)connectToServer
{
    [_inputStream open];
    [_outputStream open];
}

- (IBAction)login
{
    [self writeDataWithMessage:@"iam:小丽"];
}

#pragma mark - LXInputViewDelegate

- (void)inputView:(LXInputView *)inputView sendMessage:(NSString *)message
{
    [self writeDataWithMessage:[NSString stringWithFormat:@"msg:%@", message]];
}

- (void)inputView:(LXInputView *)inputView changeHeight:(CGFloat)height
{
    // 滚动到最底部时才随着输入框高度变化滚动.不然输入框高度变化可能会导致从上面滚到底部,体验不好.
    BOOL shouldScroll = [self isTableViewAtBottom];

    [self.view layoutIfNeeded];

    if (shouldScroll && _messages.count) {
        // 这里没有选择开启动画,因为和输入框高度动画不同步.由于幅度比较小,不加动画反而效果更好.
        [self tableViewScrollToBottomIfNeedWithAnimated:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = _messages[indexPath.row];
    NSString *reuseIdentifier = [message hasPrefix:@"小明"] ? @"SendMessageCell" : @"ReciveMessageCell";

    LXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.message = message;

    return cell;
}

#pragma mark - UITableViewDelegate

- (LXMessageCell *)templateCell
{
    if (!_templateCell) {
        _templateCell = [_tableView dequeueReusableCellWithIdentifier:@"SendMessageCell"];
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

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            LXLog(@"NSStreamEventOpenCompleted");
            break;

        case NSStreamEventHasBytesAvailable:
            [self readData];
            break;

        case NSStreamEventHasSpaceAvailable:
            break;

        case NSStreamEventErrorOccurred:
            LXLog(@"NSStreamEventErrorOccurred\n%@", aStream.streamError);
            break;

        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            LXLog(@"NSStreamEventEndEncountered");
            break;
            
        case NSStreamEventNone: break;
    }
}

@end