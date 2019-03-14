//
//  ZHContentView.swift
//  ZHImageViewer
//
//  Created by wzh on 2019/3/12.
//  Copyright © 2019 ZH. All rights reserved.
//

import UIKit

public protocol ZHContentViewDelegate : NSObjectProtocol {
    
    func didClickImageView(_ imageView : UIImageView)
}

private let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
private let screenWidth = UIScreen.main.bounds.size.width
private let screenHeight = UIScreen.main.bounds.size.height
private let spacing : CGFloat = 10
private let reuseIdentifier = "Cell"


class ZHContentView: UIView {
    public var fromView : UIView?
    public var currentView : UIView?
    
    weak var delegate : ZHContentViewDelegate?
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: screenWidth, height: 30))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        return label
    }()
    
    public lazy var mainView: UICollectionView = { [unowned self] in
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize.init(width: screenWidth, height: screenHeight)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: spacing)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth + spacing, height: screenHeight), collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.isHidden = true
        collectionView.register(ZHImageCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    var dataArray : Array<Any>? {
        
        didSet{
            self.mainView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("deinit \(self)")
    }
}

extension ZHContentView {
    
    // MARK: - 初始化方法
   private func setupSubViews() {
        self.addSubview(self.mainView)
        self.addSubview(self.titleLabel)
    }
    
}

extension ZHContentView : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if cell.isKind(of: ZHImageCell.classForCoder()) {
            let imageCell = cell as! ZHImageCell
            imageCell.delegate = self
            imageCell.image = UIImage.init(named: (self.dataArray?[indexPath.item])! as! String)
        }
       
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width) + 1
        self.titleLabel.text = "\(index)/\(self.dataArray?.count ?? 0)"
    }
}

extension ZHContentView : ZHImageCellDelegate {
    func didClickImageView(imageView: UIImageView) {
        self.currentView = imageView
        if self.delegate != nil {
            self.delegate?.didClickImageView(imageView)
        }
    }
    func imageViewWillBeginDragging(imageView: UIImageView) {
        self.titleLabel.isHidden = true
        self.mainView.isScrollEnabled = false
    }
    
    func imageViewDragging(scale: CGFloat, imageView: UIImageView) {
        self.currentView = imageView
        self.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: scale)
        if let statusBar = UIApplication.shared.value(forKey: "_statusBar") as? UIView {
            statusBar.alpha = scale
        }

    }
    
    func imageViewEndDragging(scale: CGFloat, imageView: UIImageView) {
        if scale < 0.7 {
            self.currentView = imageView
            if self.delegate != nil {
                self.delegate?.didClickImageView(imageView)
            }
        }else{
            self.backgroundColor = UIColor.black
            self.mainView.isScrollEnabled = true
            self.titleLabel.isHidden = false
        }

    }
    

}
