//
//  DetectorViewController.swift
//  CoreImageFun
//
//  Created by 从今以后 on 15/12/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

final class DetectorViewController: UIViewController {

    @IBOutlet var imageViews: [UIImageView]!

    let context = CIContext(options: nil)
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil,
        options: [ CIDetectorAccuracy : CIDetectorAccuracyHigh ])

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        imageViews.forEach { imageView in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let features = self.detector.featuresInImage(CIImage(image: imageView.image!)!)
                    as! [CIFaceFeature]
                self.filterFace(features, imageView: imageView)
                print(features)
                // 学友脸识别不出来。。。
            }
        }
    }

    func createBoxAtPosition(position: CGPoint) -> CIImage {
        let colorFilter = CIFilter(name: "CIConstantColorGenerator",
            withInputParameters: [ kCIInputColorKey : CIColor(color: UIColor.blackColor()) ])!
        let inputRectangle = CIVector(CGRect: CGRect(x: position.x - 5, y: position.y - 5,
            width: 10, height: 10))
        return CIFilter(name: "CICrop", withInputParameters:
            [   kCIInputImageKey : colorFilter.outputImage!,
                "inputRectangle" : inputRectangle   ])!.outputImage!
    }

    func filterFace(features: [CIFaceFeature], imageView: UIImageView) {

        var filter: CIFilter!
        let inputImage = CIImage(image: imageView.image!)!
        var outputImage = inputImage

        let processImage = { (position: CGPoint, inputImage: CIImage) -> () in
            filter = CIFilter(name: "CISourceOverCompositing", withInputParameters:
                [   kCIInputImageKey : self.createBoxAtPosition(position),
                    kCIInputBackgroundImageKey : inputImage   ])
            outputImage = filter.outputImage!
        }

        features.forEach {
            if $0.hasLeftEyePosition {
                processImage($0.leftEyePosition, outputImage)
            }

            if $0.hasRightEyePosition {
                processImage($0.rightEyePosition, outputImage)
            }

            if $0.hasMouthPosition {
                processImage($0.mouthPosition, outputImage)
            }
        }

        let cg_outputImage = context.createCGImage(outputImage, fromRect: inputImage.extent)
        let ui_outputImage = UIImage(CGImage: cg_outputImage, scale: 2.0, orientation: .Up)
        dispatch_async(dispatch_get_main_queue()) {
            imageView.image = ui_outputImage
        }
    }
}
