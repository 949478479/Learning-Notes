//
//  RefreshControl.swift
//  PullRefresh
//
//  Created by 从今以后 on 15/9/1.
//  Copyright (c) 2015年 Appcoda. All rights reserved.
//

import UIKit

class RefreshControl: UIRefreshControl {

    // MARK: - 属性

    @IBOutlet private var labels: [UILabel]!
    private weak var refreshContents: UIView!
    private var currentLabelIndex = 0
    private var height: CGFloat = 0

    // MARK: - 初始化

    override init() {
        super.init()
        addCustomRefreshControl()
        addRefreshingHandle()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addCustomRefreshControl()
        addRefreshingHandle()
    }

    private func addCustomRefreshControl() {

        let refreshContents = NSBundle.mainBundle().loadNibNamed(
            "RefreshContents", owner: self, options: nil).last as! UIView

        self.refreshContents = refreshContents

        addSubview(refreshContents)

        // UIRefreshControl 内部貌似会进行判断,如果背景色为 nil ,其高度将是恒定的,而不是随着拖动变化.
        backgroundColor = backgroundColor ?? UIColor.clearColor()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        /* 初始高度是 64 (有导航栏)或者 60 (刷新控件固定高度就是 60).
        第一次下拉时,第一次触发此方法时高度一般是 64 或者 60 ,导致那一瞬间刷新控件底部会露出来,
        当然如果 cell 高度够大,或者有其他东西能遮挡住刷新控件露出来的部分,就看不见了.
        之后触发此方法时,高度基本等于 y 坐标的绝对值,可能会偏差 0.25~0.5 点.
        初始拖动时只要不是太快 frame.minY 一般会比 -3 大,例如 -0.5 , -1 之类,这个时候如果高度 >=60 ,就隐藏. */
        hidden = (bounds.height >= 60 && frame.minY > -3)
    
        refreshContents.frame = bounds
    }

    // MARK: - 刷新操作处理

    private func addRefreshingHandle() {
        addTarget(self, action: "animateRefreshStep1", forControlEvents: .ValueChanged)
    }

    override func beginRefreshing() {
        super.beginRefreshing()

        if let superview = superview as? UIScrollView {
            superview.setContentOffset(CGPoint(x: 0, y: superview.contentOffset.y - 60), animated: true)
        }
        
        animateRefreshStep1()
    }

    override func endRefreshing() {
        super.endRefreshing()

        // 防止因为中途取消造成状态不对.
        currentLabelIndex = 0
        for label in labels {
            label.transform = CGAffineTransformIdentity
            label.textColor = UIColor.blackColor()
        }
    }

    // MARK: - 刷新动画

    @objc private func animateRefreshStep1() {

        if !refreshing { return } // 若刷新结束则终止继续后面的动画.

        let label = labels[self.currentLabelIndex]

        UIView.animateWithDuration(0.1, animations: {

            // 向右旋转45°,并改变文字颜色.
            label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            label.textColor = self.getTextColor()

        }, completion: { _ in

            UIView.animateWithDuration(0.05, animations: {

                // 旋转动画结束后执行恢复原状动画.
                label.transform = CGAffineTransformIdentity
                label.textColor = UIColor.blackColor()

            }, completion: { _ in

                if !self.refreshing { return }

                // 恢复原状后执行下一个 label 的动画,全部完成后执行第二阶段动画.
                if ++self.currentLabelIndex < self.labels.count {
                    self.animateRefreshStep1()
                } else {
                    self.animateRefreshStep2()
                }
            })
        })
    }

    private func animateRefreshStep2() {

        if !refreshing { return }

        UIView.animateWithDuration(0.35, animations: {

            // 所有 label 放大动画.
            labels.map { $0.transform = CGAffineTransformMakeScale(1.5, 1.5) }

        }, completion: { _ in

            if !self.refreshing { return }

            UIView.animateWithDuration(0.25, animations: {

                // 所有 label 恢复原大小动画.
                labels.map { $0.transform = CGAffineTransformIdentity }
                    
            }, completion: { _ in

                // 若刷新还未结束就循环播放动画.
                if self.refreshing {
                    self.currentLabelIndex = 0
                    self.animateRefreshStep1()
                }
            })
        })
    }
    
    // MARK: - 辅助方法
    
    private func getTextColor() -> UIColor {

        struct TextColor {
            static let colors = [
                UIColor.magentaColor(),
                UIColor.brownColor(),
                UIColor.yellowColor(),
                UIColor.redColor(),
                UIColor.greenColor(),
                UIColor.blueColor(),
                UIColor.orangeColor()
            ]
        }

        return TextColor.colors[currentLabelIndex]
    }
}