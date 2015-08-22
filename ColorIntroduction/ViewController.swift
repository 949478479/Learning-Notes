//
//  ViewController.swift
//  ColorIntroduction
//
//  Created by Marin Todorov on 7/9/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//  
//  Public domain "Prince frog" fairy tale taken from:
//  http://www.feedbooks.com/books?category=FBFIC010000
//
//  Public domain frog image
//  http://www.publicdomainpictures.net/view-image.php?image=57441&picture=frog-illustration
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var label: UILabel!

    private let story = "One fine evening a young princess put on her bonnet and clogs, and went out to take a walk by herself in a wood; and when she came to a cool spring of water, that rose in the midst of it, she sat herself down to rest a while.\n\nNow she had a golden ball in her hand, which was her favourite plaything; and she was always tossing it up into the air, and catching it again as it fell.\n\nAfter a time she threw it up so high that she missed catching it as it fell... \n\nAnd here our story begins ..."

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        addGradientLayer()

        addFrogImage()

        punchTextAtIndex(story.startIndex)
    }

    // MARK: - 梯度图层

    private func addGradientLayer() {

        // 创建一个梯度图层.
        let gradient = CAGradientLayer()

        // 使其和控制器根视图一样大小.
        gradient.frame = view.bounds

        // 设置其梯度方向为 左上角 => 右下角.默认则是 顶边中点 => 底边中点.
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)

        // 设置梯度图层的渐变颜色.
        // 数组元素只有两个则分别表示起点和终点的颜色,当然也可以多来几个.另外不指定 locations 数组的话,默认是均匀渐变的.
        // 注意这里要求是 CGColor 类型.
        gradient.colors = [
            UIColor(red: 0,     green: 1,    blue: 0.752, alpha: 1).CGColor,
            UIColor(red: 0.949, green: 0.03, blue: 0.913, alpha: 1).CGColor
        ]
        
        // 将梯度图层添加到控制器根视图的图层上显示出来.
        view.layer.addSublayer(gradient)

        // 将文本标签的图层用作梯度图层的 mask.
        // 由于 mask 的特点,只有文本标签不是完全透明的部分(也就是文字)才会露出背后的梯度图层.
        gradient.mask = label.layer
    }

    // MARK: - 文字输入动画

    private func punchTextAtIndex(index: String.Index) {

        // 往文本标签上拼接一个字符.
        label.text?.append(story[index])

        // 拼接下一个字符,直到当前字符已经是最后一个字符.
        // 注意 endIndex 表示末尾索引的下一个索引,endIndex.predecessor() 才是末尾索引.
        if index < story.endIndex.predecessor() {
            // 每隔 0.04s 拼接下一个字符.
            delay(seconds: 0.04) {
                self.punchTextAtIndex(index.successor())
            }
        }
        // 故事讲完了,添加 3 个圆圈.
        else {
            delay(seconds: 0.5, addButtonRing)
            delay(seconds: 1.0, addButtonRing)
            delay(seconds: 1.5, addButtonRing)
        }
    }

    // MARK: - 圆圈缩放动画

    private func addButtonRing() {

        // 圆圈直径.
        let diameter: CGFloat = 60

        // 图层是个 CAShapeLayer 图层.
        let button = CAShapeLayer()

        // 设置图层的路径为圆形路径.
        button.path =
            UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: diameter, height: diameter)).CGPath

        // 将图层置于文本标签底部往上 20 点且水平居中.
        // CAShapeLayer 可以看做是一个点,由于圆形路径以该点为原点,所以 x 坐标需减去半径, y 坐标需减去直径方符合需求.
        button.position =
            CGPoint(x: label.bounds.midX - diameter / 2, y: label.bounds.maxY - diameter - 20)

        // 设置描边颜色,由于 mask 的特点,什么颜色不重要,只要不是透明的就行.
        button.strokeColor = UIColor.blackColor().CGColor

        // 清除填充颜色,否则由于 mask 的特点,背后的梯度图层会露出来.
        button.fillColor = nil

        // 为了好看,调整下透明度.
        button.opacity = 0.5

        // 将图层添加到文本标签上显示出来.
        label.layer.addSublayer(button)

        // 添加图层动画.
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = 0.67
        scaleAnimation.duration = 2
        scaleAnimation.repeatCount = Float.infinity
        scaleAnimation.autoreverses = true
        button.addAnimation(scaleAnimation, forKey: nil)
    }

    // MARK: - 添加青蛙图案

    private func addFrogImage() {
        let frogImageView = UIImageView(image: UIImage(named: "frog"))
        frogImageView.center.x = label.bounds.midX
        label.addSubview(frogImageView)
    }
}