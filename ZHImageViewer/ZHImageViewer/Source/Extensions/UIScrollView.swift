//
//  UIScrollView.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/13.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func centerOfScrollViewContent(scrollView : UIScrollView) -> CGPoint {
        
        let width : CGFloat = scrollView.bounds.size.width
        let height: CGFloat = scrollView.bounds.size.height
        
        let contentWidth : CGFloat = scrollView.contentSize.width
        let contentHeight: CGFloat = scrollView.contentSize.height

        let offsetX = width > contentWidth ?  (width - contentWidth) * 0.5 : 0.0
        let offsetY = height > contentHeight ?  (height - contentHeight) * 0.5 : 0.0
        
        return CGPoint.init(x: contentWidth * 0.5 + offsetX, y: contentHeight * 0.5 + offsetY);
    }
}
