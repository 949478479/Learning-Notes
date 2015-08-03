//
//  ViewController.swift
//  CardAnimation
//
//  Created by 从今以后 on 15/7/20.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CardViewDelegate {

    func numberOfCardsInCardView(cardView: CardView) -> Int {
        return 20
    }

    func cardView(cardView: CardView, imageForCardAtIndex index: Int) -> UIImage {
        return UIImage(named: "\(index % 10)")!
    }
}