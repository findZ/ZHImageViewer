//
//  UIImage.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/13.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit

extension UIImage {
    
    open class func calculationImageSize(image : UIImage) -> CGSize {
        
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        let screenWidth : CGFloat = UIScreen.main.bounds.size.width
        var screenHeight : CGFloat = UIScreen.main.bounds.size.height
        
        if screenHeight >= 812.0 {
            screenHeight -= (44 + 34)
        }
        
        let imageWidth : CGFloat = image.size.width
        let imageHeight : CGFloat = image.size.height
        
        
        if imageWidth != 0 && imageHeight != 0  {
            
            let widthSpace  = abs(screenWidth - imageWidth)
            let heightSpace  = abs(screenHeight - imageHeight)
            if (widthSpace >= heightSpace) {
                if (screenWidth > imageWidth) {
                    width = imageWidth * (screenHeight / imageHeight)
                    height = imageHeight * (screenHeight / imageHeight)
                }else {
                    width = imageWidth / (imageWidth / screenWidth)
                    height = imageHeight / (imageWidth / screenWidth)
                }
            }else {
                if (screenHeight > imageHeight) {
                    width = imageWidth * (screenWidth / imageWidth);
                    height = imageHeight * (screenWidth / imageWidth);
                }else {
                    width = imageWidth / (imageWidth / screenWidth);
                    height = imageHeight / (imageHeight / screenHeight);
                }
            }
        }
        
        return CGSize.init(width: width, height: height)
        
    }
}
