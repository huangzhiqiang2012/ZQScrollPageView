//
//  ZQScrollSegementView.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 头部滚动选择视图
public class ZQScrollSegementView: UIView {
    
    public typealias titleClickClosure = (_ titleView:ZQTitleView, _ index:NSInteger) -> ()
    
    private var config:ZQScrollPageConfig = ZQScrollPageConfig.default
    
    private var segementConfig:ZQScrollPageSegementConfig = ZQScrollPageConfig.default.segementConfig
    
    private var titleConfig:ZQScrollPageTitleConfig = ZQScrollPageConfig.default.titleConfig
    
    private var clickClosure:titleClickClosure?
    
    private var extraButton:UIButton?
    
    private var titleViewsArr:[ZQTitleView] = [ZQTitleView]()
    
    private var titleWidthsArr:[CGFloat] = [CGFloat]()
    
    private var normalColorRGBA:[CGFloat] = [CGFloat]()
    
    private var selectedColorRGBA:[CGFloat] = [CGFloat]()
    
    private var deltaRGBA:[CGFloat] = [CGFloat]()
    
    private lazy var coverView:UIView = {
        let coverView:UIView = UIView()
        coverView.backgroundColor = segementConfig.coverBackgroundColor
        coverView.layer.cornerRadius = segementConfig.coverCornerRadius
        coverView.layer.masksToBounds = true
        return coverView
    }()
    
    private lazy var lineView:UIView = {
        let lineView:UIView = UIView()
        lineView.backgroundColor = segementConfig.lineColor
        lineView.layer.cornerRadius = segementConfig.lineCornerRadius
        lineView.layer.masksToBounds = true
        return lineView
    }()
    
    private lazy var scrollView:UIScrollView = {
        let scrollView:UIScrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = false
        return scrollView
    }()
    
    private var lastIndex:Int = 0
    
    private var currentIndex:Int = 0
    
    private var selectedTitleView:ZQTitleView?
    
    private var titleViewDefaultTag:Int = 100000
    
    private var xGap:CGFloat = 5.0
    
    private var wGap:CGFloat = 10.0
    
    private var contentSizeXOff:CGFloat = 20.0
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
}

// MARK: public
public extension ZQScrollSegementView {
    convenience init(frame:CGRect, clickClosure:@escaping titleClickClosure) {
        self.init(frame:frame)
        if titleConfig.titlesArr.count == 0 {return}
        self.clickClosure = clickClosure
        initData()
        setupViews()
        updateViews()
    }
    
    func adjustUI(withProgress progress:CGFloat, oldIndex:NSInteger, currentIndex:NSInteger) {
        guard (oldIndex >= 0 && oldIndex < titleConfig.titlesArr.count && currentIndex >= 0 && currentIndex < titleConfig.titlesArr.count) else {
            return
        }
        let lastTitleView:ZQTitleView = titleViewsArr[oldIndex]
        let currentTitleView:ZQTitleView = titleViewsArr[currentIndex]
        
        var xDistance:CGFloat = currentTitleView.frame.origin.x - lastTitleView.frame.origin.x
        var wDistance:CGFloat = currentTitleView.bounds.size.width - lastTitleView.bounds.size.width
        
        var frame:CGRect = lineView.frame
        if !titleConfig.scrollTitle {
            frame.origin.x = lastTitleView.frame.origin.x + xDistance * progress
            frame.size.width = lastTitleView.bounds.size.width + wDistance * progress
            lineView.frame = frame
            
            frame = coverView.frame
            frame.origin.x = lastTitleView.frame.origin.x + xDistance * progress - xGap
            frame.size.width = lastTitleView.bounds.size.width + wDistance * progress + wGap
            coverView.frame = frame
        }
        else {
            if segementConfig.adjustCoverOrLineWidth {
                frame = lineView.frame
                let lastLineW:CGFloat = titleWidthsArr[oldIndex] + wGap
                let currentLineW:CGFloat = titleWidthsArr[currentIndex] + wGap
                wDistance = currentLineW - lastLineW
                let lastLineX:CGFloat = lastTitleView.frame.origin.x + (lastTitleView.bounds.size.width - lastLineW) * 0.5
                let currentLineX:CGFloat = currentTitleView.frame.origin.x + (currentTitleView.bounds.size.width - currentLineW) * 0.5
                xDistance = currentLineX - lastLineX
                frame.origin.x = lastLineX + xDistance * progress
                frame.size.width = lastLineW + wDistance * progress
                lineView.frame = frame
                
                frame = coverView.frame
                frame.origin.x = lastLineX + xDistance * progress
                frame.size.width = lastLineW + wDistance * progress
                coverView.frame = frame
            }
            else {
                frame = coverView.frame
                frame.origin.x = lastTitleView.frame.origin.x + xDistance * progress
                frame.size.width = lastTitleView.bounds.size.width + wDistance * progress
                coverView.frame = frame
            }
        }
        
        if titleConfig.gradualChangeColor {
            if selectedColorRGBA.count == 4 && normalColorRGBA.count == 4 && deltaRGBA.count == 4 {
                lastTitleView.textColor = UIColor(red: selectedColorRGBA[0] + deltaRGBA[0] * progress,
                                                  green: selectedColorRGBA[1] + deltaRGBA[1] * progress,
                                                  blue: selectedColorRGBA[2] + deltaRGBA[2] * progress,
                                                  alpha: selectedColorRGBA[3] + deltaRGBA[3] * progress)
                
                currentTitleView.textColor = UIColor(red: normalColorRGBA[0] - deltaRGBA[0] * progress,
                                                     green: normalColorRGBA[1] - deltaRGBA[1] * progress,
                                                     blue: normalColorRGBA[2] - deltaRGBA[2] * progress,
                                                     alpha: normalColorRGBA[3] - deltaRGBA[3] * progress)
            }
        }
        
        if !titleConfig.scaleTitle {
            return
        }
        let deltaScale:CGFloat = titleConfig.scaleMax - 1.0
        lastTitleView.currentTransformScale = titleConfig.scaleMax - deltaScale * progress
        currentTitleView.currentTransformScale = 1.0 + deltaScale * progress
    }
    
    func adjustTitleOffSetToCurrentIndex(index:NSInteger) {
        currentIndex = index
        selectedTitle(false, isTap: false)
    }
    
    func setSelectedIndex(index:NSInteger, animated:Bool) {
        guard (index >= 0 && index < titleConfig.titlesArr.count) else {
            return
        }
        currentIndex = index
        selectedTitle(animated, isTap: false)
    }
    
    func reloadData() {
        if titleConfig.titlesArr.count == 0 {return}
        scrollView.isScrollEnabled = false
        initData()
        scrollView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        setupViews()
        updateViews()
        titleViewsArr.forEach { (view) in
            view.didDeSelected()
        }
        scrollView.isScrollEnabled = true
        setSelectedIndex(index: 0, animated: true)
    }
}

// MARK: private
extension ZQScrollSegementView {
    private func initData() {
        backgroundColor = segementConfig.backgroundColor
        currentIndex = 0
        lastIndex = 0
        titleViewsArr.removeAll()
        titleWidthsArr.removeAll()
        normalColorRGBA = titleConfig.normalColor.cgColor.components ?? [CGFloat]()
        selectedColorRGBA = titleConfig.selectedColor.cgColor.components ?? [CGFloat]()
        deltaRGBA = [CGFloat]()
        if normalColorRGBA.count == selectedColorRGBA.count {
            for i in 0..<normalColorRGBA.count {
                deltaRGBA.append(normalColorRGBA[i] - selectedColorRGBA[i])
            }
        }
    }
    
    private func setupViews() {
        addSubview(scrollView)
        setupTitles()
        setupScrollLineOrCoverOrExtraBtn()
    }
    
    private func setupScrollLineOrCoverOrExtraBtn() {
        if segementConfig.showExtraButton {
            addSubview(segementConfig.extraButton)
            extraButton = segementConfig.extraButton
        }
        scrollView.bounces = segementConfig.bounces
        if segementConfig.showLine {
            scrollView.addSubview(lineView)
        }
        if segementConfig.showCover {
            scrollView.addSubview(coverView)
        }
    }
    
    private func setupTitles() {
        for i:Int in 0..<titleConfig.titlesArr.count {
            let titleView:ZQTitleView = ZQTitleView(title: titleConfig.titlesArr[i], index: i)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionForTapTitle(tap:)))
            titleView.addGestureRecognizer(tap)
            scrollView.addSubview(titleView)
            titleViewsArr.append(titleView)
            titleWidthsArr.append(titleView.getTotalWidth())
        }
    }
    
    private func updateViews() {
        updateScrollViewAndExtraButton()
        updateTitleView()
        updateScrollLineAndCover()
        updateContentSize()
    }
    
    private func updateScrollViewAndExtraButton() {
        if let extraButton = extraButton {
            let scrollWidth:CGFloat = bounds.size.width - extraButton.bounds.size.width
            extraButton.frame = CGRect(x: scrollWidth, y: (bounds.size.height - extraButton.bounds.size.height) * 0.5, width: extraButton.bounds.size.width, height: extraButton.bounds.size.height)
            scrollView.frame = CGRect(x: 0, y: 0, width: scrollWidth, height: bounds.size.height)
        }
        else {
            scrollView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        }
    }
    
    private func updateTitleView() {
        var titleX:CGFloat = 0.0
        let titleY:CGFloat = 0.0
        var titleWidth:CGFloat = 0.0
        let titleHeight:CGFloat = bounds.size.height - segementConfig.lineHeight
        let count = titleConfig.titlesArr.count
        
        if !titleConfig.scrollTitle {
            titleWidth = scrollView.bounds.size.width / CGFloat(count)
            for i:Int in 0..<count {
                titleX = CGFloat(i) * titleWidth
                let titleView:ZQTitleView = titleViewsArr[i]
                titleView.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
                titleView.tag = titleViewDefaultTag + i
            }
        }
        else {
            let margin:CGFloat = titleConfig.margin
            var lastLableMaxX:CGFloat = margin
            var addedMargin:CGFloat = 0.0
            if titleConfig.autoAdjustTitlesWidth {
                var allTitlesWidth:CGFloat = margin
                for i:Int in 0..<count {
                    allTitlesWidth = allTitlesWidth + titleWidthsArr[i] + margin
                }
                addedMargin = allTitlesWidth < scrollView.bounds.size.width ? (scrollView.bounds.size.width - allTitlesWidth) / CGFloat(count) : 0
            }
            
            for i:Int in 0..<count {
                let titleView:ZQTitleView = titleViewsArr[i]
                titleWidth = titleWidthsArr[i]
                titleX = lastLableMaxX + addedMargin / 2
                lastLableMaxX += (titleWidth + addedMargin + margin)
                titleView.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
                titleView.tag = titleViewDefaultTag + i
                if i == 0 {
                    titleView.didSelected()
                    selectedTitleView = titleView
                }
                else {
                    titleView.didDeSelected()
                }
            }
        }
    }
    
    private func updateScrollLineAndCover() {
        let firstTitleView:ZQTitleView = titleViewsArr[0]
        var coverX:CGFloat = firstTitleView.frame.origin.x
        var coverW:CGFloat = titleConfig.scaleTitle ? firstTitleView.bounds.size.width * titleConfig.scaleMax : firstTitleView.bounds.size.width
        let coverH:CGFloat = segementConfig.coverHeight
        let coverY:CGFloat = (bounds.size.height - coverH) * 0.5
        if !titleConfig.scrollTitle {
            lineView.frame = CGRect(x: coverX, y: bounds.size.height - segementConfig.lineHeight, width: segementConfig.lineWidth, height: segementConfig.lineHeight)
            coverView.frame = CGRect(x: coverX - xGap, y: coverY, width: coverW + wGap, height: coverH)
        }
        else {
            if segementConfig.adjustCoverOrLineWidth {
                coverW = titleWidthsArr[0] * titleConfig.scaleMax + wGap
                coverX = (firstTitleView.bounds.size.width - coverW) * 0.5 + titleConfig.margin
            }
            lineView.frame = CGRect(x: coverX, y: bounds.size.height - segementConfig.lineHeight, width: segementConfig.lineWidth, height: segementConfig.lineHeight)
            lineView.center.x = firstTitleView.center.x
            coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        }
    }
    
    private func updateContentSize() {
        if titleConfig.scrollTitle {
            if let titleView = titleViewsArr.last {
                scrollView.contentSize = CGSize(width: titleView.frame.maxX + contentSizeXOff, height: 0.0)
            }
        }
    }
    
    private func selectedTitle(_ animated:Bool, isTap:Bool) {
        if (currentIndex == lastIndex && isTap) {
            return
        }
        if lastIndex < 0 || lastIndex >= titleViewsArr.count || currentIndex < 0 || currentIndex >= titleViewsArr.count {
            return
        }
        let lastTitleView:ZQTitleView = titleViewsArr[lastIndex]
        let currentTitleView:ZQTitleView = titleViewsArr[currentIndex]
        let animatedTime:CGFloat = animated ? 0.25 : 0.0
        UIView.animate(withDuration: TimeInterval(animatedTime), animations: { [weak self] in
            if let self = self {
                lastTitleView.didDeSelected()
                currentTitleView.didSelected()
                if self.segementConfig.showLine {
                    var frame:CGRect = self.lineView.frame
                    if self.segementConfig.adjustCoverOrLineWidth {
                        let width:CGFloat = self.titleWidthsArr[self.currentIndex] + self.wGap
                        let x:CGFloat = currentTitleView.frame.origin.x + (currentTitleView.bounds.size.width - width) * 0.5
                        frame.origin.x = x
                        frame.size.width = width
                    }
                    else {
                        frame.size.width = self.segementConfig.lineWidth
                    }
                    self.lineView.frame = frame
                    self.lineView.center.x = currentTitleView.center.x
                }
                
                if self.segementConfig.showCover {
                    var frame:CGRect = self.coverView.frame
                    if !self.titleConfig.scrollTitle {
                        frame.origin.x = currentTitleView.frame.origin.x - self.xGap
                        frame.size.width = currentTitleView.bounds.size.width + self.wGap
                    }
                    else {
                        if self.segementConfig.adjustCoverOrLineWidth {
                            let width:CGFloat = self.titleWidthsArr[self.currentIndex] + self.wGap
                            let x:CGFloat = currentTitleView.frame.origin.x + (currentTitleView.bounds.size.width - width) * 0.5
                            frame.origin.x = x
                            frame.size.width = width
                        } else {
                            frame.origin.x = currentTitleView.frame.origin.x
                            frame.size.width = currentTitleView.bounds.size.width
                        }
                        self.coverView.frame = frame
                    }
                }
            }
        }) {[weak self] (finish) in
            if let self = self {
                self.updateContentOffsetIfNeed()
                self.lastIndex = self.currentIndex
            }
        }
        clickClosure?(currentTitleView, currentIndex)
    }
    
    private func updateContentOffsetIfNeed() {
        if scrollView.contentSize.width == scrollView.bounds.size.width + contentSizeXOff || currentIndex < 0 || currentIndex >= titleViewsArr.count {
            return
        }
        let titleView:ZQTitleView = titleViewsArr[currentIndex]
        var offsetX:CGFloat = max(titleView.center.x - bounds.size.width * 0.5, 0)
        var extraButtonW:CGFloat = 0
        if let extraButton = extraButton {
            extraButtonW = extraButton.bounds.size.width
        }
        let maxOffsetX:CGFloat = max(scrollView.contentSize.width - (bounds.size.width - extraButtonW), 0)
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: true)
    }
}

// MARK: action
extension ZQScrollSegementView {
    @objc private func actionForTapTitle(tap:UITapGestureRecognizer) {
        if let titleView = tap.view {
            let index:Int = titleView.tag - titleViewDefaultTag
            if index != currentIndex {
                lastIndex = currentIndex
                currentIndex = index
                selectedTitle(true, isTap: true)
            }
        }
    }
}
