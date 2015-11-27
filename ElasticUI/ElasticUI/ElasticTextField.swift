//
//  ElasticTextField.swift
//  ElasticUI
//
//  Created by 从今以后 on 15/11/27.
//  Copyright © 2015年 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticTextField: UITextField {

    @IBInspectable var overshootAmount: CGFloat = 10.0

    private var elasticView: ElasticView!

    // MARK: 添加视图

    override func layoutSubviews() {
        super.layoutSubviews()
        setupElasticViewIfNeed()
    }

    // MARK: 激活动画
    
    override func becomeFirstResponder() -> Bool {
        elasticView.performAnimation()
        return super.becomeFirstResponder()
    }
}

private extension ElasticTextField {

    func setupElasticViewIfNeed() {
        guard elasticView == nil else { return }
        elasticView = ElasticView(frame: bounds)
        elasticView.overshootAmount = overshootAmount
        elasticView.backgroundColor = backgroundColor
        elasticView.userInteractionEnabled = false
        addSubview(elasticView)
    }
}
