//
//  ZQCollectionView.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 内容滚动视图
public class ZQCollectionView: UICollectionView {
    
    public typealias ZJCollectionViewShouldBeginPanGestureHandler = ((_ collectionView:ZQCollectionView, _ panGesture:UIPanGestureRecognizer) -> Bool)
    
    private var handler:ZJCollectionViewShouldBeginPanGestureHandler?
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if handler != nil && gestureRecognizer == panGestureRecognizer {
            return handler!(self, gestureRecognizer as! UIPanGestureRecognizer)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

// MARK: public
public extension ZQCollectionView {
    func setupShouldBeginPanGestureHandler(handler:@escaping ZJCollectionViewShouldBeginPanGestureHandler) {
        self.handler = handler
    }
}
