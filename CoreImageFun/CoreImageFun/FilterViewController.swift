//
//  FilterViewController.swift
//  CoreImageFun
//
//  Created by 从今以后 on 15/12/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

final class FilterViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var amountSlider: UISlider!

    var block: dispatch_block_t?
    let queue = dispatch_queue_create("com.cjyh.queue",
        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, 0))

    let context = CIContext(options: nil)

    let sepiaFilter = CIFilter(name: "CISepiaTone", withInputParameters:
        [ kCIInputImageKey : CIImage(image: UIImage(named: "flower")!)! ])!

    let maskFilter = CIFilter(name: "CISourceAtopCompositing", withInputParameters:
        [ kCIInputBackgroundImageKey : CIImage(image: UIImage(named: "mask")!)! ])!

    let backgroundFilter = CIFilter(name: "CISourceOverCompositing", withInputParameters:
        [ kCIInputBackgroundImageKey : CIImage(image: UIImage(named: "bryce")!)! ])!

    override func viewDidLoad() {
        super.viewDidLoad()
        showFinalImage()
//        logAllFilters()
    }

    @IBAction func amountSliderValueChanged(sender: UISlider) {
        showFinalImage()
    }

    func showFinalImage() {

        sepiaFilter.setValue(amountSlider.value, forKey: kCIInputIntensityKey)
        maskFilter.setValue(sepiaFilter.outputImage!, forKey: kCIInputImageKey)
        backgroundFilter.setValue(maskFilter.outputImage!, forKey: kCIInputImageKey)

        let ci_inputImage  = sepiaFilter.valueForKey(kCIInputImageKey)!
        let ci_outputImage = backgroundFilter.outputImage!

        if let block = block {
            dispatch_block_cancel(block)
        }
        block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            let cg_outputImage = self.context.createCGImage(ci_outputImage, fromRect: ci_inputImage.extent)
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = UIImage(CGImage: cg_outputImage)
            }
        }
        dispatch_async(queue, block!)
    }

    func logAllFilters() {
        CIFilter.filterNamesInCategory(kCICategoryBuiltIn).forEach {
            print($0)
            print(CIFilter(name: $0)!.attributes)
        }
    }
}
