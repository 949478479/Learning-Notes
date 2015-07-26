//
//  DetailViewController.swift
//  MagicMove
//
//  Created by 从今以后 on 15/7/18.
//  Copyright (c) 2015年 949478479. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var poetryLabel: UILabel!
    @IBOutlet var overviewLabel: UITextView!
    
    var role: Role!
    private var interactiveTransition: UIPercentDrivenInteractiveTransition!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = role.name
        
        imageView.image    = role.image
        poetryLabel.text   = role.poetry
        overviewLabel.text = role.overview
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }

    // MARK: - pop 手势处理

    @IBAction func popGestureRecognizerHandle(sender: UIPanGestureRecognizer) {

        let progress = sender.enabled ? max(0, min(sender.translationInView(view).x / view.bounds.width, 1)) : 0

        switch sender.state {
        case .Began:
            if sender.velocityInView(view).x < 0 {
                sender.enabled = false
            } else {
                interactiveTransition = UIPercentDrivenInteractiveTransition()
                navigationController?.popViewControllerAnimated(true)
            }
        case .Changed:
            interactiveTransition.updateInteractiveTransition(progress)
        default:
            if sender.enabled {
                progress > 0.5 ? interactiveTransition.finishInteractiveTransition() : interactiveTransition.cancelInteractiveTransition()
                interactiveTransition = nil
            } else {
                sender.enabled = true
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension DetailViewController: UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopAnimationController()
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}