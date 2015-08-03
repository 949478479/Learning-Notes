//
//  CardView.swift
//  CardAnimation
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate {
    func numberOfCardsInCardView(cardView: CardView) -> Int
    func cardView(cardView: CardView, imageForCardAtIndex index: Int) -> UIImage
}

class CardView: UIView {

    @IBOutlet weak var IBOutletDelegate: NSObject? {
        set {
            delegate = newValue as? CardViewDelegate
        }
        get {
            return delegate as? NSObject
        }
    }
    weak var delegate: CardViewDelegate?

    var animationDuration         = 0.4
    var maxCountOfCardsForDisplay = 5
    var maxRotation               = CGFloat(M_PI_2 / 6)

    private var lastFrame    = CGRectNull
    private var isBackside   = false // 表示最前面的卡片是否被翻转.
    private var currentIndex = 0 // 最前面的卡片的图片索引.
    private var totalOfCards = 0

    private var visibleCards = [UIImageView]()
    private lazy var reuseCard: UIImageView! = self.createCard()

    private var maxOffset: CGFloat { return bounds.width / 2 }
    private var totalOfSurplusCards: Int { return totalOfCards - currentIndex }
    private var shouldReuse: Bool { return totalOfSurplusCards > maxCountOfCardsForDisplay }

    // MARK: - 初始化

    override func awakeFromNib() {
        super.awakeFromNib()
        createCards()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createCards()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCards()
    }

    private func layoutCards() {
        if lastFrame != frame { // 动画中会频繁调用此方法,限制一下.
            lastFrame = frame
            for (index, card) in enumerate(visibleCards) {
                let layerTransform   = card.layer.transform
                card.layer.transform = CATransform3DIdentity
                card.frame           = CGRectInset(bounds, 20, 100)
                card.layer.transform = layerTransform
            }
        }
    }

    // MARK: - 创建卡片

    private func createCards() {
        totalOfCards = delegate!.numberOfCardsInCardView(self)
        let count = (maxCountOfCardsForDisplay < totalOfCards) ? maxCountOfCardsForDisplay : totalOfCards
        for index in 0..<count {
            let card = createCard()
            card.image = delegate?.cardView(self, imageForCardAtIndex: index)
            configureCard(card, atIndex: index)
            configureCardTransform(card, atIndex: index)
            visibleCards.append(card)
            insertSubview(card, atIndex: 0)
        }
    }

    private func createCard() -> UIImageView {
        let card = UIImageView(frame: CGRectInset(bounds, 20, 100))

        card.userInteractionEnabled = true
        card.contentMode            = .ScaleAspectFill

        card.layer.cornerRadius  = 10
        card.layer.masksToBounds = true
        card.layer.transform.m34 = -1 / 1_000

        return card
    }

    // MARK: - 配置卡片

    private func configureCardTransform(card: UIImageView, atIndex index: Int) {
        // 随着索引变换,每次缩放变化 10%, 向上平移 8 点距离.
        card.layer.setValue(1 - 0.1 * CGFloat(index), forKeyPath: "transform.scale.x")
        card.layer.setValue(-8 * CGFloat(index), forKeyPath: "transform.translation.y")
    }

    private func configureCard(card: UIImageView, atIndex index: Int) {
        if index == 0 {
            card.layer.zPosition = UIScreen.mainScreen().bounds.width // 确保最前面的卡片有足够的空间旋转.

            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapGestureHandle:"))
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureHandle:"))
        } else {
            card.layer.zPosition = 0
            
            if let gestureRecognizers = card.gestureRecognizers as? [UIGestureRecognizer] {
                gestureRecognizers.map { card.removeGestureRecognizer($0) }
            }
        }
    }

    // MARK: - 手势识别

    @objc private func tapGestureHandle(tap: UITapGestureRecognizer) {
        isBackside = !isBackside
        UIView.animateWithDuration(2 * animationDuration) {
            tap.view!.layer.setValue(CGFloat(M_PI), forKeyPath: "transform.rotation.y")
        }
    }
    
    @objc private func panGestureHandle(pan: UIPanGestureRecognizer) {
        let offset = pan.translationInView(self).x

        switch pan.state {
        case .Changed:
            if abs(offset) > maxOffset {
                throwCardWithAnimation()
                showNewCardWithAnimation()
                pan.enabled = false // 超过最大幅度后立即终止手势交互,会立即触发 .Cancelled .
            } else {
                transformCardsForOffset(offset)
            }
        case .Ended, .Cancelled:
            if !pan.enabled {
                pan.enabled = true
            } else {
                resetCardsWithAnimation()
            }

        default: break
        }
    }

    // MARK: - 重用卡片

    private func reuseCard(card: UIImageView) {
        if totalOfSurplusCards < maxCountOfCardsForDisplay { return }

        configureCard(reuseCard, atIndex: visibleCards.count)
        configureCardTransform(reuseCard, atIndex: visibleCards.count)
        reuseCard.image = delegate?.cardView(self, imageForCardAtIndex: currentIndex + maxCountOfCardsForDisplay - 1)

        visibleCards.append(reuseCard)
        insertSubview(reuseCard, atIndex: 0)

        reuseCard = shouldReuse ? card : nil
    }

    // MARK: - 动画

    private func resetCardsWithAnimation() {
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0, options: nil, animations: {
            self.transformCardsForOffset(0)
        }, completion: nil)
    }

    private func throwCardWithAnimation() {
        ++currentIndex

        var shouldReset = false
        if isBackside {
            isBackside  = false
            shouldReset = true
        }

        let firstCard          = visibleCards.removeAtIndex(0)
        let initalTranslationX = firstCard.layer.valueForKeyPath("transform.translation.x") as! CGFloat
        let finalTranslationX  = ((initalTranslationX > 0) ? 1 : -1) * (bounds.width + bounds.height * sin(maxRotation))

        reuseCard(firstCard)

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

    private func showNewCardWithAnimation() {
        for (index, card) in enumerate(self.visibleCards) {
            configureCard(card, atIndex: index)
            transformCard(card, forOffset: maxOffset, atIndex: index) // 调整偏移至最大,让动画更明显.
        }
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0, options: nil, animations: {
            for (index, card) in enumerate(self.visibleCards) {
                self.configureCardTransform(card, atIndex: index)
                self.transformCard(card, forOffset: 0, atIndex: index)
            }
        }, completion: nil)
    }

    // MARK: - 变换卡片

    private func transformCard(card: UIImageView, forOffset offset: CGFloat, atIndex index: Int) {
        // 使 card 的平移量和索引挂钩,越靠后平移量越小.
        let translationX = (offset != 0) ? offset * (1 - CGFloat(index) / CGFloat(visibleCards.count)) : 0
        card.layer.setValue(translationX, forKeyPath: "transform.translation.x")

        // 如果第一张被翻转到背面,需额外旋转 M_PI, 否则会被倒置.
        let adjust = (index == 0 && isBackside) ? CGFloat(M_PI) : 0
        let rotationZ = translationX / maxOffset * maxRotation + adjust
        card.layer.setValue(rotationZ, forKeyPath: "transform.rotation.z")
    }

    private func transformCardsForOffset(offset: CGFloat ) {
        for (index, card) in enumerate(self.visibleCards) {
            transformCard(card, forOffset: offset, atIndex: index)
        }
    }
}