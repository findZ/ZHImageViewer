//
//  ZHImageViewer.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/12.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit


private let keyWindow = UIApplication.shared.keyWindow
private let contentViewTag = 99999
private let animateDuration = 0.25

class ZHImageViewer: NSObject {

    private var originalFrame : CGRect?
    
    static let shared = ZHImageViewer()
    
    public func showImageViewer(imageView : UIImageView , dataArray : Array<Any>, currentIndexPath : Int) {
        
        let contentView = ZHContentView.init(frame: (keyWindow?.bounds)!)
        contentView.delegate = self
        contentView.fromView = imageView
        contentView.fromView?.isHidden = true
        keyWindow?.addSubview(contentView)
        self.originalFrame = contentView.convert(imageView.frame, from: imageView.superview)
        contentView.dataArray = dataArray
        contentView.tag = contentViewTag
        let indexPath = IndexPath.init(item: currentIndexPath, section: 0)
        contentView.mainView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: false)
        
        if dataArray.count > 1 {
            contentView.titleLabel.text = "\(currentIndexPath + 1)/\(dataArray.count)"
        }
        
        let tempFrame = imageView.superview?.convert(imageView.frame, to: contentView)
        let tempView = UIImageView.init(frame: tempFrame!)
        tempView.image = imageView.image
        contentView.addSubview(tempView)
        
        let targetSize = UIImage.calculationImageSize(image: imageView.image!)
        let targetRect = CGRect.init(x: 0, y: 0, width: targetSize.width , height: targetSize.height)
        
        UIView.animate(withDuration: animateDuration, animations: {
            tempView.frame = targetRect
            tempView.center = contentView.center
        }) { (finished) in
            tempView.removeFromSuperview()
            contentView.mainView.isHidden = false
        }
        
        if let statusBar = UIApplication.shared.value(forKey: "_statusBar") as? UIView {
            statusBar.alpha = 0.0
        }
        
    }
    
    public func disappearImageViewer(){
        
        let contentView = keyWindow?.viewWithTag(contentViewTag) as! ZHContentView
        
        UIView.animate(withDuration: animateDuration, animations: {
            contentView.currentView?.frame = self.originalFrame ?? CGRect.zero
            contentView.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0)

        }) { (finished) in
            contentView.fromView?.isHidden = false
            contentView.removeFromSuperview()
        }
        if let statusBar = UIApplication.shared.value(forKey: "_statusBar") as? UIView {
            statusBar.alpha = 1.0
        }
    }
    
    deinit {
        print("deinit \(self)")
    }
}

extension ZHImageViewer : ZHContentViewDelegate {
    
    func didClickImageView(_ imageView: UIImageView) {
        self.disappearImageViewer()
    }
    
}
