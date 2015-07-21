//
//  CardView.swift
//  CardAnimation
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate {
    func numberOfCardsInCardView(cardView: CardView) -> Int
    func cardView(cardView: CardView, imageForCardAtIndex index: Int) -> UIImage
}

class CardView: UIView {

    @IBOutlet weak var tmp: NSObject? { // 不知道 delegate 为毛拖不了线,先用这个凑合一下...
        didSet {
            delegate = tmp as? CardViewDelegate
        }
    }
    weak var delegate: CardViewDelegate?

    var animationDuration         = 0.4
    var maxCountOfCardsForDisplay = 5
    var maxRotation               = CGFloat(M_PI_2 / 6)

    private var isBackside   = false // 表示最前面的卡片是否被翻转.
    private var animating    = false
    private var currentIndex = 0 // 最前面的卡片的图片索引.
    private var totalOfCards = 0

    private var visibleCards = [UIImageView]()
    private lazy var reuseCard: UIImageView! = self.p_createCard()

    private var maxOffset: CGFloat { return bounds.width / 2 }
    private var totalOfSurplusCards: Int { return totalOfCards - currentIndex }
    private var shouldReuse: Bool { return totalOfSurplusCards > maxCountOfCardsForDisplay }

    // MARK: - 初始化

    override func awakeFromNib() {
        super.awakeFromNib()
        p_createCards()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        p_createCards()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - 创建卡片

    private func p_createCards() {
        totalOfCards = delegate!.numberOfCardsInCardView(self)
        let count = maxCountOfCardsForDisplay < totalOfCards ? maxCountOfCardsForDisplay : totalOfCards
        for index in 0..<count {
            let card = p_createCard()
            card.image = delegate?.cardView(self, imageForCardAtIndex: index)
            p_configureCard(card, atIndex: index)
            p_configureCardTransform(card, atIndex: index)
            visibleCards.append(card)
            insertSubview(card, atIndex: 0)
        }
    }

    private func p_createCard() -> UIImageView {
        let card = UIImageView(frame: CGRectInset(bounds, 20, 100))

        card.userInteractionEnabled = true
        card.contentMode            = .ScaleAspectFill

        card.layer.cornerRadius  = 10
        card.layer.masksToBounds = true
        card.layer.transform.m34 = -1 / 1_000

        return card
    }

    // MARK: - 配置卡片

    private func p_configureCardTransform(card: UIImageView, atIndex index: Int) {
        // 随着索引变换,每次缩放变化 10%, 向上平移 8 点距离.
        card.layer.setValue(1 - 0.1 * CGFloat(index), forKeyPath: "transform.scale.x")
        card.layer.setValue(-8 * CGFloat(index), forKeyPath: "transform.translation.y")
    }

    private func p_configureCard(card: UIImageView, atIndex index: Int) {
        if index == 0 {
            card.layer.zPosition = UIScreen.mainScreen().bounds.width // 确保最前面的卡片有足够的空间旋转.

            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "p_tapGestureHandle:"))
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "p_panGestureHandle:"))
        } else {
            card.layer.zPosition = 0
            
            if let gestureRecognizers = card.gestureRecognizers as? [UIGestureRecognizer] {
                gestureRecognizers.map { card.removeGestureRecognizer($0) }
            }
        }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        p_layoutCards()
    }

    private func p_layoutCards() {
        if animating { return } // 动画中会频繁调用此方法,限制一下.
        for (index, card) in enumerate(visibleCards) {
            let layerTransform   = card.layer.transform
            card.layer.transform = CATransform3DIdentity
            card.frame           = CGRectInset(bounds, 20, 100)
            card.layer.transform = layerTransform
        }
    }

    // MARK: - 手势识别

    @objc private func p_tapGestureHandle(tap: UITapGestureRecognizer) {
        isBackside = !isBackside
        animating  = true
        UIView.animateWithDuration(2 * animationDuration, animations: {
            tap.view!.layer.setValue(CGFloat(M_PI), forKeyPath: "transform.rotation.y")
        }, completion: { _ in
            self.animating = false
        })
    }
    
    @objc private func p_panGestureHandle(pan: UIPanGestureRecognizer) {
        let offset = pan.translationInView(self).x

        switch pan.state {
        case .Changed:
            if abs(offset) > maxOffset {
                p_throwCardWithAnimation()
                p_showNewCardWithAnimation()
                pan.enabled = false // 超过最大幅度后立即终止手势交互,会立即触发 .Cancelled .
            } else {
                p_transformCardsForOffset(offset)
            }

        case .Began:
            animating = true // 为了拖动时不要触发 layoutSubviews.

        case .Ended, .Cancelled:
            if !pan.enabled {
                pan.enabled = true
            } else {
                p_resetCardsWithAnimation()
            }

        default: break
        }
    }

    // MARK: - 重用卡片

    private func p_reuseCard(card: UIImageView) {
        if totalOfSurplusCards < maxCountOfCardsForDisplay { return }

        p_configureCard(reuseCard, atIndex: visibleCards.count)
        p_configureCardTransform(reuseCard, atIndex: visibleCards.count)
        reuseCard.image = delegate?.cardView(self, imageForCardAtIndex: currentIndex + maxCountOfCardsForDisplay - 1)

        visibleCards.append(reuseCard)
        insertSubview(reuseCard, atIndex: 0)

        reuseCard = shouldReuse ? card : nil
    }

    // MARK: - 动画

    private func p_resetCardsWithAnimation() {
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0, options: nil, animations: {
            self.p_transformCardsForOffset(0)
        }, completion: { _ in
            self.animating = false
        })
    }

    private func p_throwCardWithAnimation() {
        ++currentIndex

        var shouldReset = false
        if isBackside {
            isBackside  = false
            shouldReset = true
        }

        let firstCard          = visibleCards.removeAtIndex(0)
        let initalTranslationX = firstCard.layer.valueForKeyPath("transform.translation.x") as! CGFloat
        let finalTranslationX  = ((initalTranslationX > 0) ? 1 : -1) * (bounds.width + bounds.height * sin(maxRotation))

        p_reuseCard(firstCard)

        UIView.animateWithDuration(animationDuration, animations: {
            firstCard.layer.setValue(finalTranslationX, forKeyPath: "transform.translation.x")
        }, completion: { finish in
            if self.shouldReuse && shouldReset {
                // 若卡片被旋转过,则需要转回来,否则复用后图片是倒置的.
                firstCard.layer.setValue(CGFloat(M_PI), forKeyPath: "transform.rotation.y")
            }
            firstCard.removeFromSuperview()
        })
    }

    private func p_showNewCardWithAnimation() {
        for (index, card) in enumerate(self.visibleCards) {
            p_configureCard(card, atIndex: index)
            p_transformCard(card, forOffset: maxOffset, atIndex: index) // 调整偏移至最大,让动画更明显.
        }
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0, options: nil, animations: {
            for (index, card) in enumerate(self.visibleCards) {
                self.p_configureCardTransform(card, atIndex: index)
                self.p_transformCard(card, forOffset: 0, atIndex: index)
            }
        }, completion: { _ in
            self.animating = false
        })
    }

    // MARK: - 变换卡片

    private func p_transformCard(card: UIImageView, forOffset offset: CGFloat, atIndex index: Int) {
        // 使 card 的平移量和索引挂钩,越靠后平移量越小.
        let translationX = (offset != 0) ? offset * (1 - CGFloat(index) / CGFloat(visibleCards.count)) : 0
        card.layer.setValue(translationX, forKeyPath: "transform.translation.x")

        // 如果第一张被翻转到背面,需额外旋转 M_PI, 否则会被倒置.
        let adjust = (index == 0 && isBackside) ? CGFloat(M_PI) : 0
        let rotationZ = translationX / maxOffset * maxRotation + adjust
        card.layer.setValue(rotationZ, forKeyPath: "transform.rotation.z")
    }

    private func p_transformCardsForOffset(offset: CGFloat ) {
        for (index, card) in enumerate(self.visibleCards) {
            p_transformCard(card, forOffset: offset, atIndex: index)
        }
    }
}