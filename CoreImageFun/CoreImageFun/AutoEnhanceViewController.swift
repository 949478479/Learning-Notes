//
//  AutoEnhanceViewController.swift
//  CoreImageFun
//
//  Created by 从今以后 on 15/12/31.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

final class AutoEnhanceViewController: UIViewController {

    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var outputImage = CIImage(image: self.imageView2.image!)!
            outputImage.autoAdjustmentFiltersWithOptions(nil).forEach {
                $0.setValue(outputImage, forKey: kCIInputImageKey)
                outputImage = $0.outputImage!
                print($0.attributes[kCIAttributeFilterDisplayName]!)
            }

            // 直接生成 UIImage 会忽略 UIImageView 的 contentMode
            let cg_outputImage = CIContext(options: nil).createCGImage(outputImage, fromRect: outputImage.extent)
            let ui_outputImage = UIImage(CGImage: cg_outputImage, scale: 2.0, orientation: .Up)
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView2.image = ui_outputImage
            }
        }
    }
}
