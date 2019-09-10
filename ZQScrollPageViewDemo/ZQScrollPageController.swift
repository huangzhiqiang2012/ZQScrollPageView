//
//  ZQScrollPageController.swift
//  ZQScrollPageViewDemo
//
//  Created by Darren on 2019/4/24.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQScrollPageView

class ZQScrollPageController : UIViewController {
    
    /// 保证子控制器的生命周期被正常调用
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let y = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.size.height
        let segementConfig = ZQScrollPageSegementConfig()
        segementConfig.backgroundColor = UIColor.blue
        segementConfig.showCover = true
        let titleConfig:ZQScrollPageTitleConfig = ZQScrollPageTitleConfig()
        titleConfig.titlesArr = ["新闻", "小说说说", "杂书评", "世界真大哈哈哈", "奇葩说", "新闻", "小说说说", "杂书评", "世界真大哈哈哈", "奇葩说"]
        titleConfig.gradualChangeColor = true
        titleConfig.normalColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        titleConfig.selectedColor = UIColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1)
//        titleConfig.showImage = true
//        titleConfig.imagePosition = .left
//        titleConfig.normalImagesArr = [UIImage(named: "normal"), UIImage(named: "normal"), UIImage(named: "normal"), UIImage(named: "normal"), UIImage(named: "normal")] as! [UIImage]
//        titleConfig.selectedImagesArr = [UIImage(named: "selected"), UIImage(named: "selected"), UIImage(named: "selected"), UIImage(named: "selected"), UIImage(named: "selected")] as! [UIImage]
        titleConfig.margin = 20
        let config = ZQScrollPageConfig.default
        config.segementConfig = segementConfig
        config.titleConfig = titleConfig
        let scrollPageView:ZQScrollPageView = ZQScrollPageView(frame: CGRect(x: 0, y: y, width: view.bounds.size.width, height: view.bounds.size.height - y), parentViewController: self, delegate: self)
        view.addSubview(scrollPageView)
        scrollPageView.setSelectedIndex(index: 3, animated: true)
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            scrollPageView.reloadData(titlesArr:  ["新闻1", "小说说说1", "杂书评1", "世界真大哈哈哈1", "奇葩说1", "新闻1", "小说说说1", "杂书评1", "世界真大哈哈哈1", "奇葩说1"])
//        }
    }
}

extension ZQScrollPageController : ZQScrollPageViewDelegate {
    func childViewController(_ reuseViewController: (UIViewController & ZQScrollPageViewChildVcDelegate)?, forIndex index: NSInteger) -> UIViewController & ZQScrollPageViewChildVcDelegate {
        return ZQScrollPageInfoController()
    }
}

class ZQScrollPageInfoController : UIViewController {
    
    fileprivate lazy var label:UILabel = {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        label.textColor = UIColor.red
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(label)
    }
}

extension ZQScrollPageInfoController : ZQScrollPageViewChildVcDelegate {
    func viewWillAppearForIndex(index: NSInteger) {
        label.text = "第\(index + 1)页"
        print("--__--|| \(#function) index__\(index)")
    }
    
    func viewDidAppearForIndex(index: NSInteger) {
        print("--__--|| \(#function) index__\(index)")
    }
    
    func viewWillDisappearForIndex(index: NSInteger) {
        print("--__--|| \(#function) index__\(index)")
    }
    
    func viewDidDisappearForIndex(index: NSInteger) {
        print("--__--|| \(#function) index__\(index)")
    }
}
