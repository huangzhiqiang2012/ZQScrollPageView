//
//  ZQScrollPageConfig.swift
//  ZQScrollPageView
//
//  Created by Darren on 2019/4/23.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 标题中图片的位置
public enum ZQScrollPageTitleImagePosition : Int {
    case left     = 0    ///< 左边
    case right    = 1    ///< 右边
    case top      = 2    ///< 上边
    case center   = 3    ///< 中心
}

// MARK: 头部配置信息
public class ZQScrollPageSegementConfig: NSObject {
    
    /// 是否显示遮盖, 默认 false
    public var showCover:Bool = false
    
    /// 遮盖背景颜色, 默认 UIColor.lightGray.withAlphaComponent(0.4)
    public var coverBackgroundColor:UIColor = UIColor.lightGray.withAlphaComponent(0.4)
    
    /// 遮盖圆角, 默认 14.0
    public var coverCornerRadius:CGFloat = 14.0
    
    /// 遮盖高度, 默认 28.0
    public var coverHeight:CGFloat = 28.0
    
    /// 背景颜色, 默认 UIColor.white
    public var backgroundColor:UIColor = UIColor.white
    
    /// 宽, 默认屏幕宽
    public var width:CGFloat = UIScreen.main.bounds.size.width
    
    /// 高度, 默认 60.0
    public var height:CGFloat = 60.0
    
    /// 是否显示标题和内容之间的分割线, 默认 true
    public var showSeparatorLine:Bool = true
    
    /// 是否显示滚动条, 默认 true
    public var showLine:Bool = true
    
    /// 滚动条高度, 默认 2.0
    public var lineHeight:CGFloat = 2.0
    
    /// 滚动条宽度, 默认 20.0
    public var lineWidth:CGFloat = 20.0
    
    /// 滚动条颜色, 默认 UIColor.red
    public var lineColor:UIColor = UIColor.red
    
    /// 滚动条圆角, 默认 0.0
    public var lineCornerRadius:CGFloat = 0.0
    
    /// 是否显示附加的按钮, 默认 false
    public var showExtraButton:Bool = false
    
    /// 附加按钮
    public var extraButton:UIButton = UIButton()
    
    /// 是否有弹性 默认 true
    public var bounces:Bool = true
    
    /// 是否遮盖/滚动条自适应标题的宽度 默认 ture 即在滚动的过程中遮盖或者滚动条的宽度随着变化
    public var adjustCoverOrLineWidth:Bool = true
}

// MARK: 标题配置信息
public class ZQScrollPageTitleConfig: NSObject {
    
    /// 标题数组
    public var titlesArr:[String] = [String]()
    
    /// 是否滚动标题 默认 true 设置为 false 的时候所有的标题将不会滚动, 并且宽度会平分 和系统的segment效果相似
    public var scrollTitle:Bool = true
    
    /// 是否缩放标题 默认 false
    public var scaleTitle:Bool = false
    
    /// 标题最大缩放比例 默认 1.3
    public var scaleMax:CGFloat = 1.3
    
    /// 是否颜色渐变 默认 false
    public var gradualChangeColor:Bool = false
    
    /// 是否自动调整标题的宽度, 默认 false 当设置为 true 的时候 如果所有的标题的宽度之和小于segmentView的宽度的时候, 会自动调整title的位置, 达到类似"平分"的效果
    public var autoAdjustTitlesWidth:Bool = false
    
    /// 是否显示图片, 默认 false
    public var showImage:Bool = false
    
    /// 普通状态下图片数组
    public var normalImagesArr:[UIImage] = [UIImage]()
    
    /// 选中状态下图片数组
    public var selectedImagesArr:[UIImage] = [UIImage]()
    
    /// 标题中的图片位置, 默认 左边
    public var imagePosition:ZQScrollPageTitleImagePosition = .left
    
    /// 标题之间的间隙, 默认 15.0
    public var margin:CGFloat = 15.0
    
    /// 普通状态下字体, 默认 UIFont.systemFont(ofSize: 14)
    public var normalFont:UIFont = UIFont.systemFont(ofSize: 14)
    
    /// 选中状态下字体, 默认 UIFont.systemFont(ofSize: 14)
    public var selectedFont:UIFont = UIFont.systemFont(ofSize: 14)
    
    /// 普通状态下字体颜色, 默认 UIColor.black
    /// 注:如果 gradualChangeColor = true, 请用rgba格式设置颜色
    public var normalColor:UIColor = UIColor.black
    
    /// 选中状态下字体颜色, 默认 UIColor.red
    /// 注:如果 gradualChangeColor = true, 请用rgba格式设置颜色
    public var selectedColor:UIColor = UIColor.red
}

// MARK: 内容配置信息
public class ZQScrollPageContentConfig: NSObject {
    
    /// 内容距离顶部菜单的距离 默认 0
    public var topMargin:CGFloat = 0.0
    
    /// 是否能滚动 默认 true
    public var canScroll:Bool = true
    
    /// 是否有弹性 默认 true
    public var bounces:Bool = true
    
    /// 点击标题切换的时候,内容视图是否有动画 默认 true
    public var animatedWhenTitleClicked:Bool = true
    
    /// 是否需要管理生命周期,默认是true
    /// 如果你希望所有的子控制器的view的系统生命周期方法被正确的调用,请重写所在控制器的'shouldAutomaticallyForwardAppearanceMethods'方法 并且返回NO
    /// 当然如果你不做这个操作, 子控制器的生命周期方法将不会被正确的调用 ,如果你仍然想利用子控制器的生命周期方法, 请使用'ZQScrollPageViewChildVcDelegate'提供的代理方法
    public var needManageLifeCycle:Bool = true
}

// MARK: 配置信息
public class ZQScrollPageConfig: NSObject {
    
    /// 头部配置信息
    public var segementConfig:ZQScrollPageSegementConfig = ZQScrollPageSegementConfig()
    
    /// 标题配置信息
    public var titleConfig:ZQScrollPageTitleConfig = ZQScrollPageTitleConfig()
    
    /// 内容配置信息
    public var contentConfig:ZQScrollPageContentConfig = ZQScrollPageContentConfig()
}
