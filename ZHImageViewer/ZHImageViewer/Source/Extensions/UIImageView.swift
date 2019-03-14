//
//  UIImageView.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/13.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func addTarget(target : Any? , action: Selector?)  {
        
        let tap = UITapGestureRecognizer.init(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        
    }
}
