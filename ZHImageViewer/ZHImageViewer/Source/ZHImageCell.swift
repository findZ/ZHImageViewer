//
//  ZHImageCell.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/13.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit

private let screenWidth = UIScreen.main.bounds.size.width
private let screenHeight = UIScreen.main.bounds.size.height


protocol ZHImageCellDelegate : NSObjectProtocol {
    
    func didClickImageView(imageView : UIImageView)
    func imageViewWillBeginDragging(imageView : UIImageView)
    func imageViewDragging(scale : CGFloat, imageView : UIImageView)
    func imageViewEndDragging(scale : CGFloat, imageView : UIImageView)

}

class ZHImageCell: UICollectionViewCell {
    
    weak var delegate : ZHImageCellDelegate?
    private var scale : CGFloat?
    private var doingPan : Bool = false
    private var doingZoom : Bool = false

    
    var image : UIImage? {
        
        didSet{
            self.scrollView.setZoomScale(1.0, animated: true)
            guard self.image != nil else {
                return
            }
            let size = UIImage.calculationImageSize(image: self.image!)
            self.imageView.image = self.image;
            self.imageView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
            self.imageView.center = self.scrollView.center
            self.moveView.image = self.image
            self.moveView.frame = self.imageView.frame
        }
    }
    
    lazy var imageView: UIImageView = { [unowned self] in
        let imgV = UIImageView.init(frame: self.bounds)
        imgV.contentMode = UIView.ContentMode.scaleAspectFit
        return imgV
    }()
    private lazy var moveView: UIImageView = {
        let imgV = UIImageView.init()
        imgV.contentMode = UIView.ContentMode.scaleAspectFit
        imgV.isHidden = true
        return imgV
    }()
    
    private lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollV = UIScrollView.init(frame: self.bounds)
        scrollV.delegate = self
        scrollV.minimumZoomScale = 1.0;
        scrollV.maximumZoomScale = 3.0;
        scrollV.alwaysBounceVertical = true;
        scrollV.alwaysBounceHorizontal = true;
        scrollV.showsVerticalScrollIndicator = false;
        scrollV.showsHorizontalScrollIndicator = false;
        scrollV.contentSize = CGSize.init(width: 0, height: self.bounds.size.height)
        if #available(iOS 11.0, *) {
            scrollV.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        scrollV.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        return scrollV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension ZHImageCell {
    
   private func setupSubViews(){
    self.addSubview(self.scrollView)
    self.scrollView.addSubview(self.imageView)
    self.addSubview(self.moveView)
    
    let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapClick(_:)))
    doubleTap.numberOfTapsRequired = 2
    self.scrollView.addGestureRecognizer(doubleTap)
    
    let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapClick(_:)))
    self.scrollView.addGestureRecognizer(singleTap)
    
    singleTap.require(toFail: doubleTap)
    
    }
}

extension ZHImageCell : UIScrollViewDelegate {
    
    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageView.center = scrollView.centerOfScrollViewContent(scrollView: scrollView)
        self.doingZoom = false
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.doingZoom = true
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if (self.doingZoom == false && self.scrollView.zoomScale == 1.0 ) {
            if self.delegate != nil {
                self.delegate?.imageViewWillBeginDragging(imageView: self.imageView)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.endPan()
    }
    
}

extension ZHImageCell {
    @objc func singleTapClick(_ gestureRecognizer : UIGestureRecognizer){
        UIView.animate(withDuration: 0.25, animations: {//避免动画冲突
            self.scrollView.zoomScale = 1.0
            if self.delegate != nil {
                self.delegate?.didClickImageView(imageView: self.imageView)
            }
        })
    }
    
    @objc func doubleTapClick(_ gestureRecognizer : UIGestureRecognizer){
        
        let touchPoint = gestureRecognizer.location(in: self)
        if self.scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + self.scrollView.contentOffset.x //需要放大的图片的X点
            let sacleY = touchPoint.y + self.scrollView.contentOffset.y //需要放大的图片的Y点
            self.scrollView.zoom(to: CGRect.init(x: scaleX, y: sacleY, width: 10, height: 10), animated: true)
        }else{
            self.scrollView.setZoomScale(1.0, animated: true)
        }
  
    }
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (self.doingZoom == false && self.scrollView.zoomScale == 1.0 ) {
            self.doPan(pan: self.scrollView.panGestureRecognizer)
        }
    }
}

extension ZHImageCell {
    
    func doPan(pan : UIPanGestureRecognizer) {
        if (pan.state == UIGestureRecognizer.State.ended || pan.state ==  UIGestureRecognizer.State.possible)
        {
            self.doingPan = false
            return
        }
        if (pan.numberOfTouches != 1 || self.doingZoom)//两个手指在拖，此时应该是在缩放，不执行继续执行
        {
            self.doingPan = true
            return
        }
        
        self.doingPan = true
        self.imageView.isHidden = true
        self.moveView.isHidden = false
        
        let state = pan.state
        if (state == UIGestureRecognizer.State.began || state == UIGestureRecognizer.State.changed) {
            
            let translation = pan.translation(in: self.scrollView)
            let center = self.moveView.center
            let x = center.x + translation.x
            let y = center.y + translation.y
            
            self.moveView.center = CGPoint.init(x: x, y: y)
            
            pan.setTranslation(CGPoint.zero, in: self.scrollView)
            
            var scale = y/(screenHeight/2)
            print(scale)
            
            if scale > 1.0 {
                scale = 1 - (scale - 1.0)
            }
            if (scale < 0.5) {
                scale = 0.5
            }
            
            self.scale = scale
            self.moveView.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            if self.delegate != nil {
                self.delegate?.imageViewDragging(scale: self.scale ?? 0.0, imageView: self.moveView)
            }
        }
        
    }
    
    func endPan() {
        
        if self.moveView.isHidden == false {
            self.scrollView.bounces = false //解决拖拽结束瞬间抖动
            UIView.animate(withDuration: 0.25, animations: {
                self.moveView.center = self.scrollView.center
                self.moveView.transform = CGAffineTransform.identity
            }) { (finished) in
                self.imageView.isHidden = false
                self.moveView.isHidden = true;
                self.scrollView.bounces = true //解决拖拽结束瞬间抖动
            }
            if self.delegate != nil {
                self.delegate?.imageViewEndDragging(scale: self.scale ?? 0.0, imageView: self.moveView)
            }
        }
        
    }
}
