//
//  ViewController.swift
//  UIScrollViewZoomDemo
//
//  Created by 从今以后 on 15/12/18.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLayoutSubviews() {
        configureScrollViewZoomScale()
    }
}

extension ViewController {

    func configureScrollViewZoomScale() {
        imageView.sizeToFit()
        scrollView.zoomScale = 1.0

        let scrollViewFrame = scrollView.frame
        let scrollViewContentSize = scrollView.contentSize
        let scaleWidth = scrollViewFrame.width / scrollViewContentSize.width
        let scaleHeight = scrollViewFrame.height / scrollViewContentSize.height
        let minScale = min(scaleWidth, scaleHeight)

        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    func centerScrollViewContent() {

        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.frame.size

        let verticalPadding = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
        let horizontalPadding = max((scrollViewSize.width - imageViewSize.width) / 2, 0)

        let contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding,
            bottom: verticalPadding, right: horizontalPadding)

        scrollView.contentInset = contentInset
    }

    @IBAction func handleDoubleTap(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(sender.view)
        let rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
        scrollView.zoomToRect(rect, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContent()
    }
}
