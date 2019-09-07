//
//  ZQContentView.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 内容视图
public class ZQContentView: UIView {
    
    deinit {
        unregisteNotification()
        print("--__--|| \(self.classForCoder) dealloc")
    }
    
    private lazy var layout:UICollectionViewFlowLayout = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var collectionView:ZQCollectionView = {
        let collectionView:ZQCollectionView = ZQCollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
        if let config = config {
            collectionView.bounces = config.contentConfig.bounces
            collectionView.isScrollEnabled = config.contentConfig.canScroll
        }
        return collectionView
    }()
    
    private var config:ZQScrollPageConfig?
    
    private var needManageLifeCycle:Bool {
        return config?.contentConfig.needManageLifeCycle ?? true
    }
    
    private weak var parentViewController:UIViewController?
    
    private weak var segementView:ZQScrollSegementView?
    
    private weak var delegate:ZQScrollPageViewDelegate?
    
    var currentIndex:Int = 0
    
    private var oldIndex:Int = -1
    
    private var oldOffSetX:CGFloat = 0.0
    
    private var currentChildVc:(UIViewController & ZQScrollPageViewChildVcDelegate)?
    
    /// 是否加载第一页
    private var isLoadFirstView:Bool = true
    
    /// 当这个属性设置为true的时候 就不用处理 scrollView滚动的计算
    private var forbidTouchToAdjustPosition:Bool = false
    
    /// 是否一次滚动超过一页
    private var scrollOverOnePage:Bool = false
    
    private lazy var childVcsDic:NSMutableDictionary = {
        let childVcsDic:NSMutableDictionary = NSMutableDictionary()
        return childVcsDic
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        layout.itemSize = bounds.size
        collectionView.collectionViewLayout = layout
    }
}

// MARK: private
extension ZQContentView {
    private func initialize() {
        guard let parentViewController = parentViewController else {
            return
        }
        if needManageLifeCycle {
            assert(!parentViewController.shouldAutomaticallyForwardAppearanceMethods, "\n请注意: 如果你希望所有的子控制器的view的系统生命周期方法被正确的调用\n请重写\(parentViewController.self)的'shouldAutomaticallyForwardAppearanceMethods'方法 并且返回NO\n当然如果你不做这个操作, 子控制器的生命周期方法将不会被正确的调用")
        }
        guard let navi = parentViewController.parent, navi.isKind(of: UINavigationController.self), (navi as! UINavigationController).viewControllers.count > 1, (navi as! UINavigationController).interactivePopGestureRecognizer != nil else {
            return
        }
        collectionView.setupShouldBeginPanGestureHandler {[weak self] (collectionView:ZQCollectionView, panGesture:UIPanGestureRecognizer) -> Bool in
            if let self = self {
                let transionX = panGesture.translation(in: panGesture.view).x
                if collectionView.contentOffset.x == 0 && transionX > 0 {
                    (navi as! UINavigationController).interactivePopGestureRecognizer?.isEnabled = true
                } else {
                    (navi as! UINavigationController).interactivePopGestureRecognizer?.isEnabled = false
                }
                if let result = self.delegate?.responds(to: #selector(self.delegate?.scrollPageController(_:contentScrollView:shouldBeginPanGesture:))) {
                    if result {
                        return (self.delegate?.scrollPageController?(parentViewController, contentScrollView: collectionView, shouldBeginPanGesture: panGesture)) ?? true
                    }
                }
            }
            return true
        }
    }
    
    private func setupViews() {
        addSubview(collectionView)
    }
    
    private func registeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveMemoryWarningNotification(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    private func unregisteNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupChildViewController(cell:UICollectionViewCell, indexPath:IndexPath) {
        let row:Int = indexPath.row
        guard let result = delegate?.responds(to: #selector(delegate?.childViewController(_:forIndex:))), result == true, currentIndex == row else {
            return
        }
        currentChildVc = (childVcsDic.value(forKey: row.description) as? (UIViewController & ZQScrollPageViewChildVcDelegate))
        let isFirstLoaded:Bool = currentChildVc == nil
        if isFirstLoaded {
            currentChildVc = delegate?.childViewController(nil, forIndex: indexPath.row)
            currentChildVc?.ZQ_currentIndex = row
            childVcsDic.setValue(currentChildVc, forKey: row.description)
        }
        else {
            delegate?.childViewController(currentChildVc, forIndex: row)
        }
        if let currentChildVc = currentChildVc {
            if currentChildVc.ZQ_scrollViewController != parentViewController {
                parentViewController?.addChild(currentChildVc)
            }
            currentChildVc.view.frame = cell.contentView.bounds
            cell.contentView.addSubview(currentChildVc.view)
            currentChildVc.didMove(toParent: parentViewController)
            
            /// 第一次加载cell 不会调用endDisplayCell
            if isLoadFirstView {
                willAppear(index: row)
                if isFirstLoaded {
                    currentChildVc.viewDidLoadForIndex?(index: row)
                }
                didAppear(index: row)
                isLoadFirstView = false
            }
            else {
                willAppear(index: row)
                if isFirstLoaded {
                    currentChildVc.viewDidLoadForIndex?(index: row)
                }
                willDisappear(index: oldIndex)
            }
        }
    }
    
    private func willAppear(index:NSInteger) {
        guard let controller = childVcsDic.value(forKey: index.description) else {
            return
        }
        (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).viewWillAppearForIndex?(index: index)
        if needManageLifeCycle {
            (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).beginAppearanceTransition(true, animated: false)
        }
        delegate?.scrollPageController?(parentViewController ?? UIViewController(), childViewControllerWillAppear: controller as! UIViewController, forIndex: index)
    }
    
    private func didAppear(index:Int) {
        guard let controller = childVcsDic.value(forKey: index.description) else {
            return
        }
        (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).viewDidAppearForIndex?(index: index)
        if needManageLifeCycle {
            (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).endAppearanceTransition()
        }
        delegate?.scrollPageController?(parentViewController ?? UIViewController(), childViewControllerDidAppear: controller as! UIViewController, forIndex: index)
    }
    
    private func willDisappear(index:Int) {
        guard let controller = childVcsDic.value(forKey: index.description) else {
            return
        }
        (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).viewWillDisappearForIndex?(index: index)
        if needManageLifeCycle {
            (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).beginAppearanceTransition(false, animated: false)
        }
        delegate?.scrollPageController?(parentViewController ?? UIViewController(), childViewControllerWillDisappear: controller as! UIViewController, forIndex: index)
    }
    
    private func didDisappear(index:Int) {
        guard let controller = childVcsDic.value(forKey: index.description) else {
            return
        }
        (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).viewDidDisappearForIndex?(index: index)
        if needManageLifeCycle {
            (controller as! UIViewController & ZQScrollPageViewChildVcDelegate).endAppearanceTransition()
        }
        delegate?.scrollPageController?(parentViewController ?? UIViewController(), childViewControllerDidDisappear: controller as! UIViewController, forIndex: index)
    }
    
    private func didMoveFromIndex(fromIndex:NSInteger, toIndex:NSInteger, progress:CGFloat) {
        segementView?.adjustUI(withProgress: progress, oldIndex: fromIndex, currentIndex: toIndex)
    }
    
    private func adjustSegmentTitleOffsetToCurrentIndex(index:NSInteger) {
        segementView?.adjustTitleOffSetToCurrentIndex(index: index)
    }
    
    private func removeChildVc(childVc:UIViewController) {
        childVc.willMove(toParent: nil)
        childVc.view.removeFromSuperview()
        childVc.removeFromParent()
    }
}

// MARK: public
public extension ZQContentView {
    convenience init(frame: CGRect, config:ZQScrollPageConfig, segementView:ZQScrollSegementView, parentViewController:UIViewController, delegate:ZQScrollPageViewDelegate?) {
        self.init(frame:frame)
        self.config = config
        self.segementView = segementView
        self.parentViewController = parentViewController
        self.delegate = delegate
        initialize()
        setupViews()
        registeNotification()
    }
    
    func setContentOffSet(offset:CGPoint, animated:Bool) {
        forbidTouchToAdjustPosition = true
        let currentIndex:Int = Int(offset.x / collectionView.bounds.size.width)
        oldIndex = self.currentIndex
        self.currentIndex = currentIndex
        let page:Int = labs(currentIndex - oldIndex)
        scrollOverOnePage = page >= 2
        collectionView.setContentOffset(offset, animated: animated)
    }
    
    func reload() {
        collectionView.isScrollEnabled = false
        for (key, childVc) in childVcsDic {
            childVcsDic.removeObject(forKey: key)
            removeChildVc(childVc: (childVc as! UIViewController))
        }
        initialize()
        collectionView.reloadData()
        collectionView.isScrollEnabled = true
        setContentOffSet(offset: CGPoint.zero, animated: false)
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDelegate
extension ZQContentView : UICollectionViewDelegate, UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let config = config else {
            return 0
        }
        return config.titleConfig.titlesArr.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        cell.contentView.subviews.forEach { (view:UIView) in
            view.removeFromSuperview()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setupChildViewController(cell: cell, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let row:Int = indexPath.row
        if !forbidTouchToAdjustPosition {
            
            /// 没有滚动完成
            if currentIndex == row {
                if needManageLifeCycle {
                    if let currentVc = childVcsDic.value(forKey: row.description) {
                        
                        /// 开始出现
                        (currentVc as! UIViewController).beginAppearanceTransition(true, animated: false)
                        
                    }
                    
                    if let oldVc = childVcsDic.value(forKey: row.description) {
                        
                        /// 开始消失
                        (oldVc as! UIViewController).beginAppearanceTransition(false, animated: false)
                        
                    }
                }
                didDisappear(index: row)
                didAppear(index: oldIndex)
            }
                
            else {
                
                /// 滚动完成
                if oldIndex == row {
                    didDisappear(index: oldIndex)
                    didAppear(index: currentIndex)
                }
                else {
                    
                    /// 滚动没有完成又快速的反向打开了另一页
                    if needManageLifeCycle {
                        if let currentVc = childVcsDic.value(forKey: oldIndex.description) {
                            
                            /// 开始出现
                            (currentVc as! UIViewController).beginAppearanceTransition(true, animated: false)
                            
                        }
                        
                        if let oldVc = childVcsDic.value(forKey: row.description) {
                            
                            /// 开始消失
                            (oldVc as! UIViewController).beginAppearanceTransition(false, animated: false)
                            
                        }
                    }
                    didDisappear(index: row)
                    didAppear(index: oldIndex)
                }
            }
        }
        else {
            if scrollOverOnePage {
                
                /// 滚动完成
                if labs(currentIndex - row) == 1 {
                    didDisappear(index: oldIndex)
                    didAppear(index: currentIndex)
                }
            }
            else {
                didDisappear(index: oldIndex)
                didAppear(index: currentIndex)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldOffSetX = scrollView.contentOffset.x
        forbidTouchToAdjustPosition = false
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let navi = parentViewController?.parent {
            if navi.isKind(of: UINavigationController.self) {
                (navi as! UINavigationController).interactivePopGestureRecognizer?.isEnabled = true
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex:NSInteger = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        didMoveFromIndex(fromIndex: currentIndex, toIndex: currentIndex, progress: 1.0)
        adjustSegmentTitleOffsetToCurrentIndex(index: currentIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if forbidTouchToAdjustPosition || scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width {
            return
        }
        let temProgress:CGFloat = scrollView.contentOffset.x / scrollView.bounds.size.width
        let tempIndex:NSInteger = NSInteger(temProgress)
        var progress:CGFloat = temProgress - floor(temProgress)
        let deltaX:CGFloat = scrollView.contentOffset.x - oldOffSetX
        if deltaX > 0 {
            if progress == 0.0 {
                return
            }
            currentIndex = tempIndex + 1
            oldIndex = tempIndex
        }
        else if deltaX < 0 {
            progress = 1.0 - progress
            oldIndex = tempIndex + 1
            currentIndex = tempIndex
        }
        else {
            return
        }
        didMoveFromIndex(fromIndex: oldIndex, toIndex: currentIndex, progress: progress)
    }
}

// MARK: Notification
extension ZQContentView {
    @objc private func onReceiveMemoryWarningNotification(_ noti:Notification) {
        for (key, childVc) in childVcsDic {
            if let currentChildVc = currentChildVc {
                if (childVc as! UIViewController) != currentChildVc {
                    childVcsDic.removeObject(forKey: key)
                    removeChildVc(childVc: (childVc as! UIViewController))
                }
            }
        }
    }
}

// MARK: UIViewController + Extension
public extension UIViewController {
    var ZQ_scrollViewController:UIViewController? {
        get {
            var controller:UIViewController = self
            while true {
                if controller.conforms(to:ZQScrollPageViewDelegate.self) {
                    break
                }
                if let parent = controller.parent {
                    controller = parent
                }
                else {
                    return nil
                }
            }
            return controller
        }
    }
    
    var ZQ_currentIndex:Int {
        set {
            objc_setAssociatedObject(self, "currentIndexKey", newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, "currentIndexKey") as! Int
        }
    }
    
}
