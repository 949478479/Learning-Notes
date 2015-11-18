//
//  DropdownMenu.swift
//  DropdownMenu
//
//  Created by 从今以后 on 15/11/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

// MARK: - 外观设置协议
protocol DropdownMenuAppearance {

    var separatorColor: UIColor? { get set }

    var menuTitleColor: UIColor? { get set }
    var menuBackgroundColor: UIColor? { get set }

    var menuTextFont: UIFont! { get set }
    var menuTextColor: UIColor? { get set }

    var menuCheckmarkColor: UIColor? { get set }
}

// MARK: - DropdownMenu
class DropdownMenu: UIView, DropdownMenuAppearance {

    // MARK: 公共属性
    
    var items: [String]?
    var selectedItem = 0 {
        didSet {
            menuTitleView.title = items![selectedItem]
            menuTableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedItem, inSection: 0),
                animated: false, scrollPosition: .None)
            /*
                不知为何在 didSet 里调用 sizeToFit() 更新尺寸时，size 更新了但是视图没刷新，
                将 sizeToFit() 放到设置 selectedItem 之后调用则一切正常，因此放到下个运行循环调用好了.
            */
            dispatch_async(dispatch_get_main_queue()) { self.sizeToFit() }
        }
    }
    var didSelectItemAtIndexHandler: ((item: String, index: Int) -> Void)?

    // MARK: 外观设置

    var menuWidth: CGFloat {
        set {
            menuTableView.widthConstraint.constant = newValue
        }
        get {
            return menuTableView.widthConstraint.constant
        }
    }
    var menuTextColor: UIColor? = UIColor.whiteColor()
    var menuTitleColor: UIColor? = UIColor.whiteColor()
    var menuCheckmarkColor: UIColor? = UIColor.whiteColor()
    var menuBackgroundColor: UIColor? = UIColor.whiteColor()
    var menuTextFont: UIFont! = UIFont(name: "HelveticaNeue-Bold", size: 17)!
    var separatorColor: UIColor? = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)

    // MARK: 私有属性

    @IBOutlet private var menuTitleView: _MenuTitleView!
    @IBOutlet private var menuTableView: _MenuTableView!
    @IBOutlet private var menuWrapperView: _MenuWrapperView!
    @IBOutlet private var menuBackgroundView: _MenuBackgroundView!

    private var isAnimating = false
    private var isOpen = false { didSet { performAnimation() } }
    private var menuViewConstraints: [NSLayoutConstraint]!

    // MARK: 初始化

    class func dropdownMenu() -> DropdownMenu {
        return instantiateFromNib()
    }

    // MARK: 添加菜单

    override func didMoveToWindow() {
        if let window = window {
            menuTitleView.titleColor = menuTitleColor
            menuTableView.contentInset.top = menuTableViewContentInsetTop
            menuTableView.tableHeaderView?.backgroundColor = menuBackgroundColor

            window.addSubview(menuWrapperView)
            setupMenuViewConstraintsIfNeedWithNavigationBar(superview!)
            NSLayoutConstraint.activateConstraints(menuViewConstraints)
        } else {
            menuWrapperView.removeFromSuperview()
        }
    }

    // MARK: 调整大小

    override func sizeThatFits(size: CGSize) -> CGSize {
        return systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }

    // MARK: 手势处理

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isAnimating == false {
            isOpen = !isOpen
        }
    }
}

// MARK: - DropdownMenu 私有计算属性

private extension DropdownMenu {
    var itemCount: Int {
        return items?.count ?? 0
    }
    var arrowImageViewTransform: CGAffineTransform {
        return isOpen ?
            CGAffineTransformMakeRotation(CGFloat(-M_PI*0.999999)) :
            CGAffineTransformIdentity
    }
    var menuTableViewContentInsetTop: CGFloat {
        let tableHeaderViewHeight = menuTableView.tableHeaderViewHeight
        return isOpen ?
            -tableHeaderViewHeight :
            -(menuTableView.rowHeight * CGFloat(itemCount) + tableHeaderViewHeight)
    }
    var backgroundViewAlpha: CGFloat {
        return isOpen ? 1.0 : 0.0
    }
}

// MARK: - DropdownMenu 私有方法
private extension DropdownMenu {

    func performAnimation() {
        isAnimating = true // 标记动画过程开始
        if isOpen { menuWrapperView.hidden = false } // 菜单打开则显示 menuWrapperView
        UIView.animateWithDuration(1.0,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.menuBackgroundView.alpha = self.backgroundViewAlpha
                self.menuTableView.contentInset.top = self.menuTableViewContentInsetTop
                self.menuTitleView.arrowImageView.transform = self.arrowImageViewTransform
            }, completion: { _ in
                self.isAnimating = false // 标记动画过程结束
                if !self.isOpen { self.menuWrapperView.hidden = true } // 菜单关闭则隐藏 menuWrapperView
        })
    }

    func setupMenuViewConstraintsIfNeedWithNavigationBar(navigationBar: UIView) {
        guard menuViewConstraints == nil else { return }
        let window = navigationBar.window!
        let constraints = ["topAnchor","bottomAnchor","leadingAnchor","trailingAnchor"].map {
            menuWrapperView.valueForKey($0)!.constraintEqualToAnchor(window.valueForKey($0) as! NSLayoutAnchor)!
        } + [menuBackgroundView, menuTableView].map {
            $0.topAnchor.constraintEqualToAnchor(navigationBar.bottomAnchor)!
        }
        menuViewConstraints = constraints
    }
}

// MARK: - UITableViewDataSource
extension DropdownMenu: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("DropdownMenuCell",
            forIndexPath: indexPath) as! _DropdownMenuCell

        cell.textLabel?.text = items![indexPath.row]

        cell.menuTextFont = menuTextFont
        cell.menuTextColor = menuTextColor
        cell.separatorColor = separatorColor
        cell.menuCheckmarkColor = menuCheckmarkColor
        cell.menuBackgroundColor = menuBackgroundColor
        cell.hiddenSeparator = indexPath.row == (items!.count - 1)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension DropdownMenu: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        isAnimating = true

        self.selectedItem = indexPath.row
        self.didSelectItemAtIndexHandler?(item: self.items![indexPath.row], index: indexPath.row)

        lx_dispatch_after(0.25) { self.isOpen = !self.isOpen }
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return isAnimating ? nil : indexPath // 防止连续快速点击 cell
    }
}

// MARK: - _MenuTitleView
@objc(_MenuTitleView)
private class _MenuTitleView: UIView {
    var title: String? { didSet { titleLabel.text = title } }
    var titleColor: UIColor? { didSet { titleLabel.textColor = titleColor } }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
}

// MARK: - _MenuWrapperView
@objc(_MenuWrapperView)
private class _MenuWrapperView: UIView {

    @IBOutlet var menuTableView: _MenuTableView!
    @IBOutlet weak var dropdownMenu: DropdownMenu!

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // 隐藏即菜单处于关闭状态，自身及其子视图放弃处理此次事件
        guard !hidden else {
            return nil
        }

        // 点击点位于 DropdownMenu 上，让其处理此次点击事件
        if dropdownMenu.bounds.contains(dropdownMenu.convertPoint(point, fromView: self)) {
            return dropdownMenu
        }

        // 点击不在 DropdownMenu 上，但是在导航栏上（包括状态栏），不做处理，单纯拦截掉此次事件
        if point.y < menuTableView.frame.minY {
            return self
        }

        // 点击点位于 _MenuTableView 的内容范围内，让其处理此次事件
        let contentX      = menuTableView.frame.minX
        let contentY      = menuTableView.frame.minY
        let contentWidth  = menuTableView.bounds.width
        let contentHeight = menuTableView.contentSize.height - menuTableView.tableHeaderViewHeight
        let contentFrame  = CGRect(x: contentX, y: contentY, width: contentWidth, height: contentHeight)
        if contentFrame.contains(point) { return menuTableView }

        // 点击点位于 _MenuTableView 的内容范围外的 _MenuBackgroundView 区域，让 DropdownMenu 处理，即关闭菜单
        return dropdownMenu
    }
}

// MARK: - _MenuBackgroundView
@objc(_MenuBackgroundView)
private class _MenuBackgroundView: UIView { }

// MARK: - _MenuTableView
@objc(_MenuTableView)
private class _MenuTableView: UITableView {

    let tableHeaderViewHeight: CGFloat = 233
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        widthConstraint.constant = LXScreenSize().width
        tableFooterView = UIView()
        tableHeaderView = UIView(frame:
            CGRect(origin: CGPointZero, size: CGSize(width: 0, height: tableHeaderViewHeight)))
        registerClass(_DropdownMenuCell.self, forCellReuseIdentifier: "DropdownMenuCell")
    }
}

// MARK: - _DropdownMenuCell
private class _DropdownMenuCell: UITableViewCell, DropdownMenuAppearance {

    // MARK: 外观设置

    var hiddenSeparator = false {
        didSet {
            if hiddenSeparator != oldValue {
                setNeedsDisplay()
            }
        }
    }

    var separatorColor: UIColor?

    var menuTitleColor: UIColor?
    var menuBackgroundColor: UIColor? { didSet { backgroundColor = menuBackgroundColor } }

    var menuTextFont: UIFont! { didSet { textLabel?.font = menuTextFont } }
    var menuTextColor: UIColor? { didSet { textLabel?.textColor = menuTextColor } }

    var menuCheckmarkColor: UIColor? { didSet { tintColor = menuCheckmarkColor } }

    // MARK: 初始化

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // .Default 风格时中间有个巨大的 UILabel 会盖住绘制的分隔线
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 绘制分隔线
    
    override func drawRect(rect: CGRect) {
        guard !hiddenSeparator else { return }

        let lineWidth = 1 / traitCollection.displayScale
        let y = round(rect.height) - lineWidth / 2.0 // 偏移 0.5 个像素对应的点，防止出现像素模糊

        let context = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(context, 10, y)
        CGContextAddLineToPoint(context, rect.width - 10, y)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, separatorColor?.CGColor)
        CGContextStrokePath(context)
    }

    // MARK: 标记选中

    override func setSelected(selected: Bool, animated: Bool) {
        accessoryType = selected ? .Checkmark : .None
    }
}
