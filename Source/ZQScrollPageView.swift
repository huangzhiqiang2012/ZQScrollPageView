//
//  ZQScrollPageView.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 代理
@objc public protocol ZQScrollPageViewChildVcDelegate:NSObjectProtocol {
    @objc optional func viewWillAppearForIndex(index:NSInteger)
    
    @objc optional func viewDidAppearForIndex(index:NSInteger)
    
    @objc optional func viewWillDisappearForIndex(index:NSInteger)
    
    @objc optional func viewDidDisappearForIndex(index:NSInteger)
    
    @objc optional func viewDidLoadForIndex(index:NSInteger)
}

@objc public protocol ZQScrollPageViewDelegate:NSObjectProtocol {
    
    @discardableResult
    @objc func childViewController(_ reuseViewController:(UIViewController & ZQScrollPageViewChildVcDelegate)?, forIndex index:NSInteger) -> UIViewController & ZQScrollPageViewChildVcDelegate
    
    @objc optional func scrollPageController(_ scrollPageController:UIViewController, contentScrollView:ZQCollectionView, shouldBeginPanGesture panGesture:UIPanGestureRecognizer) -> Bool
    
    @objc optional func scrollPageController(_ scrollPageController:UIViewController, childViewControllerWillAppear childViewController:UIViewController, forIndex index:NSInteger)
    
    @objc optional func scrollPageController(_ scrollPageController:UIViewController, childViewControllerDidAppear childViewController:UIViewController, forIndex index:NSInteger)
    
    @objc optional func scrollPageController(_ scrollPageController:UIViewController, childViewControllerWillDisappear childViewController:UIViewController, forIndex index:NSInteger)
    
    @objc optional func scrollPageController(_ scrollPageController:UIViewController, childViewControllerDidDisappear childViewController:UIViewController, forIndex index:NSInteger)
    
    @objc optional func frameOfChildControllerForContainer(_ containerView:UIView) -> CGRect
}

// MARK: 滚动分页视图
public class ZQScrollPageView: UIView {
    private var config:ZQScrollPageConfig?
    
    private var segementConfig:ZQScrollPageSegementConfig?
    
    private var contentConfig:ZQScrollPageContentConfig?
    
    private weak var parentViewController:UIViewController?
    
    private weak var delegate:ZQScrollPageViewDelegate?
    
    private lazy var segmentView:ZQScrollSegementView = {
        guard let segementConfig = self.segementConfig, let config = self.config, let contentConfig = self.contentConfig else {
            return ZQScrollSegementView()
        }
        let segmentView:ZQScrollSegementView = ZQScrollSegementView(frame: CGRect(x: 0, y: 0, width: segementConfig.width, height: segementConfig.height), config:config, clickClosure: {[weak self] (titleView, index) in
            if let self = self {
                self.contentView.setContentOffSet(offset: CGPoint(x: self.contentView.bounds.size.width * CGFloat(index), y: 0.0), animated: contentConfig.animatedWhenTitleClicked)
            }
        })
        return segmentView
    }()
    
    private lazy var contentView:ZQContentView = {
        guard let segementConfig = self.segementConfig, let config = self.config else {
            return ZQContentView()
        }
        let contentView:ZQContentView = ZQContentView(frame: CGRect(x: 0, y: segementConfig.height + config.contentConfig.topMargin, width: self.bounds.size.width, height: self.bounds.size.height - segementConfig.height - config.contentConfig.topMargin), config: config, segementView:segmentView, parentViewController: self.parentViewController ?? UIViewController(), delegate: self.delegate)
        return contentView
    }()
    
    var currentIndex:Int {
        return contentView.currentIndex
    }
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
}


// MARK: public
public extension ZQScrollPageView {
    convenience init(frame:CGRect, config:ZQScrollPageConfig, parentViewController:UIViewController, delegate:ZQScrollPageViewDelegate?) {
        self.init(frame:frame)
        self.config = config
        self.segementConfig = config.segementConfig
        self.contentConfig = config.contentConfig
        self.parentViewController = parentViewController
        self.delegate = delegate
        setupViews()
    }
    
    func setSelectedIndex(index:NSInteger, animated:Bool) {
        segmentView.setSelectedIndex(index: index, animated: animated)
    }
    
    func reloadData(titlesArr:[String]) {
        guard let config = config else {
            return
        }
        config.titleConfig.titlesArr = titlesArr
        reloadData(config: config)
    }
    
    func reloadData(config:ZQScrollPageConfig) {
        segmentView.reloadData(config: config)
        contentView.reload()
    }
    
    func updateTopMargin(topMargin:CGFloat) {
        guard let segementConfig = self.segementConfig else {
            return
        }
        let height = self.bounds.size.height - segementConfig.height - topMargin
        contentView.frame = CGRect(x: 0, y: segementConfig.height + topMargin, width: self.bounds.size.width, height: height)
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}

// MARK: private
extension ZQScrollPageView {
    private func setupViews() {
        addSubview(segmentView)
        addSubview(contentView)
    }
}
