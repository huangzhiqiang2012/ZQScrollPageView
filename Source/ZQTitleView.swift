//
//  ZQTitleView.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 头部标题视图
public class ZQTitleView: UIView {
    
    private var config:ZQScrollPageTitleConfig?
    
    private var index:NSInteger = 0
    
    private var titleWidth:CGFloat = 0.0
    
    private var titleHeight:CGFloat = 0.0
    
    private var imageWidth:CGFloat = 0.0
    
    private var imageHeight:CGFloat = 0.0
    
    private lazy var contentView:UIView = {
        let contentView:UIView = UIView()
        return contentView
    }()
    
    private lazy var imageView:UIImageView = {
        let imageView:UIImageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var label:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        if let config = config {
            label.font = config.normalFont
            label.textColor = config.normalColor
        }
        return label
    }()
    
    public var currentTransformScale:CGFloat = 0.0 {
        didSet {
            self.transform = CGAffineTransform(scaleX: currentTransformScale, y: currentTransformScale)
        }
    }
    
    public var textColor:UIColor? {
        didSet {
            label.textColor = textColor
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if let config = config {
                if !config.showImage {
                    contentView.frame = bounds
                    label.frame = bounds
                    return
                }
                let totalWidth:CGFloat = getTotalWidth()
                contentView.frame = CGRect(x: (bounds.size.width - totalWidth) / 2, y: 0, width: totalWidth, height: bounds.size.height)
                switch config.imagePosition {
                case .left:
                    imageView.frame = CGRect(x: 0, y: (bounds.size.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
                    label.frame = CGRect(x: imageWidth, y: 0, width: titleWidth, height: bounds.size.height)
                    
                case .right:
                    label.frame = CGRect(x: 0, y: 0, width: titleWidth, height: bounds.size.height)
                    imageView.frame = CGRect(x: titleWidth, y: (bounds.size.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
                    
                case .top:
                    contentView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: imageHeight + titleHeight)
                    imageView.frame = CGRect(x: (bounds.size.width - totalWidth) / 2, y: 0, width: imageWidth, height: imageHeight)
                    label.frame = CGRect(x: 0, y: imageHeight, width: totalWidth, height: titleHeight)
                    
                case .center:
                    imageView.frame = contentView.frame
                    label.removeFromSuperview()
                }
            }
        }
    }
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
}

// MARK: public
public extension ZQTitleView {
    convenience init(config:ZQScrollPageTitleConfig, title:String, index:NSInteger) {
        self.init()
        self.config = config
        self.index = index
        self.currentTransformScale = 1.0
        isUserInteractionEnabled = true
        backgroundColor = .clear
        label.text = title
        let size:CGSize = NSString(string: title).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: 0.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : config.selectedFont], context: nil).size
        titleWidth = size.width
        titleHeight = size.height
        setupViews()
    }
    
    func getTotalWidth() -> CGFloat {
        var width:CGFloat = 0.0
        if let config = config {
            switch config.imagePosition {
            case .left, .right:
                width = imageWidth + titleWidth
                
            case .center:
                width = imageWidth
                
            case .top:
                width = max(imageWidth, titleWidth)
            }
        }
        return width
    }
    
    func didSelected() {
        if let config = config {
            if config.scaleTitle {
                currentTransformScale = config.scaleMax
            }
            label.textColor = config.selectedColor
            label.font = config.selectedFont
        }
    }
    
    func didDeSelected() {
        if let config = config {
            currentTransformScale = 1.0
            label.textColor = config.normalColor
            label.font = config.normalFont
        }
    }
}

// MARK: private
extension ZQTitleView {
    private func setupViews() {
        addSubview(contentView)
        if let config = config {
            if config.showImage {
                assert(config.normalImagesArr.count == config.selectedImagesArr.count, "count of normalImages should equal to count of selectedImages")
                contentView.addSubview(imageView)
                if index < config.normalImagesArr.count {
                    let normalImage:UIImage = config.normalImagesArr[index]
                    let selectedImage:UIImage = config.selectedImagesArr[index]
                    imageView.image = normalImage
                    imageView.highlightedImage = selectedImage
                    imageWidth = max(normalImage.size.width, selectedImage.size.width)
                    imageHeight = max(normalImage.size.height, selectedImage.size.height)
                }
            }
            else {
                imageWidth = 0.0
            }
        }
        contentView.addSubview(label)
    }
}
