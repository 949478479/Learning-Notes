//
//  ViewController.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-16.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
    }

    private func addHolderView() {
        let loaderView = LoaderView()
        loaderView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100))
        loaderView.center = view.center
        view.addSubview(loaderView)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.subviews.map { $0.removeFromSuperview() }
        addHolderView()
    }
}