//
//  Photo.swift
//  RWDevCon
//
//  Created by Mic Pringle on 04/03/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class Photo {

    static let allPhotos: [Photo] = {
        var photos = [Photo]()
        if let URL = NSBundle.mainBundle().URLForResource("Photos", withExtension: "plist"),
           let photosFromPlist = NSArray(contentsOfURL: URL)
        {
            for dictionary in photosFromPlist {
                let photo = Photo(dictionary: dictionary as! NSDictionary)
                photos.append(photo)
            }
        }
        return photos
    }()

    var caption: String
    var comment: String
    var image: UIImage

    init(caption: String, comment: String, image: UIImage) {
        self.caption = caption
        self.comment = comment
        self.image   = image
    }

    convenience init(dictionary: NSDictionary) {
        let caption = dictionary["Caption"] as? String
        let comment = dictionary["Comment"] as? String
        let photo = dictionary["Photo"] as? String
        let image = UIImage(named: photo!)?.decompressedImage // 在主线程预解压本身就会耗费资源吧.
        self.init(caption: caption!, comment: comment!, image: image!)
    }

    func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {

        let rect = comment.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)

        return ceil(rect.height) // boundingRectWithSize 返回的尺寸是分数,文档特别提醒要上转为整数.
    }
}