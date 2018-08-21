//
//  ReadMe.h
//  233
//
//  Created by 许毓方 on 2018/8/20.
//  Copyright © 2018 SN. All rights reserved.
//

#ifndef ReadMe_h
#define ReadMe_h



#pragma mark -External Display Support


#pragma mark - Layout-Driven UI: 布局驱动UI

1. Find and track state that affects UI: 追踪状态
2. Dirty layout when state changes with setNeedsLayout(): 状态改变 调用  setNeedsLayout
3. Update UI with state in layoutSubviews(): layoutSubviews 更新UI


#pragma mark Layout

    let coolView = CoolView()
    var feelingCool = true
        setNeedsLayout
    override func layoutSubviews() {
        super.layoutSubviews()
        coolView.isHidden = !feelingCool
    }

#pragma mark Animations

    var cardsInDeck = [CardView]() {
        didSet {
            setNeedsLayout()
        }
    }
    func putCardInDeck(_ card: CardView) {
        cardsInDeck.append(card)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.beginFromCurrentState], // 在播放动画时, 获取视图当前的位置, 包括动画中期
                       animations: {
                           self.layoutIfNeeded()
                       }, completion: nil)
    }

#pragma mark Gestures

    var cardsToOffsets = [CardView : CGPoint]() {
        didSet {
            setNeedsLayout()
        }
    }
    @objc func handleCardPan(_ pan: UIPanGestureRecognizer) {
        if let card = pan.view as? CardView,
            let currentOffset = cardsToOffsets[card] {
                let translation = pan.translation(in: self)
                cardsToOffsets[card] = CGPoint(x: currentOffset.x + translation.x,
                                               y: currentOffset.y + translation.y)
                pan.setTranslation(.zero, in: self)
            } }
    override func layoutSubviews() {
        super.layoutSubviews()
        //...
        for card in cards {
            if let offset = cardsToOffsets[card] {
                card.frame.origin = offset
            } }
    }

#pragma mark - Laser-Fast Launches

点击app图标到响应之间的5个组件:
ABM: Always Be Measuring
    Time Profiler

1. Process Forking: 进程分叉  iOS帮我们实现了(包括且不止于 POSIX知识)
2. !!! Dynamic Linking: 分配内存  链接动态库和框架; 初始化Swift, Objective-c, Fundation; 静态对象初始化; 大概占典型启动时间 40%-50%, 此时代码还没有被执行
    - 删除 多余的函数, 对象和结构 DRY
    - iOS自己的库会被缓存(会处于活动内存 ), 第三方的不会被缓存(动态库会的吧), 仍然需要重新加载对应框架
    - 避免静态初始化器 +initilize +load
更多信息: WWDC 2017 - 413:  App Startup Time—Past, Present, and Future
3. UI Construction: UI构建 Prepare UI(ViewController); State restoration(系统状态恢复); Load preferences(载入首选项); Load model data;
    - application(_:willFinishLaunchingWithOptions:)
       application(_:didFinishLaunchingWithOptions:)
       applicationDidBecomeActive(_:)
    这些方向尽快返回, 这样才会把 App 标记为活跃状态
    - Avoid writing to disk
    - Avoid loading very large data sets
    - Check database hygiene
4. First Frame: 第一帧
    - Core Animation renders your first frame
    - Text drawing
    - Image loading and decompression
加载必要的界面, 哪怕是 hidden 也是需要成本的

5. Extended Launch Actions: 扩展启动操作
    此时的网络不稳定. 不稳定的话可以显示 占位符UI


#pragma mark - Smooth Scrolling 平滑滚动
丢帧:  https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
    - CPU: 计算
        WWDC2016 - 418:  Using Time Profiler in Instruments
        tableview collectionview  Prefetching功能   WWDC2016 - 219: What’s New in UICollectionView in iOS 10
        腾出主线程以更新UI和处理用户输入: 移出主线程类型: 网络; 文件访问系统; 图片绘制; 文本大小调整
    - GPU
        WWDC2014 - 419: Advanced Graphics and Animations for iOS Apps
        适当使用一些视觉效果: Visual effects; Masking;
        WWDC2015 - 412: Profiling in Depth

#pragma mark - Continuing with Continuity 保持连贯性

Handoff: 相同iCould账户设备之间传输文件
        WWDC2014 - 219 : Adopting Handoff on iOS and OS X

#pragma mark - Debugging like a Pro  专业调试
        不能提交到app, 会被拒  (DebugFunc.h .m)
The Detective Mindset: 侦探的心态
    验证你的假设，寻找线索，测试你的预感

Misplaced Views and View Controllers State issues
    - Debug View Hierarchy;
    -[UIView recursiveDescription]; -[UIView _parentDescription]; +[UIViewController _printHierarchy]

    WWDC2012 - 415: Debugging with LLDB
    WWDC2014 - 410: Advanced Swift Debugging in LLDB

    expr myStruct.doSomething()
    - expr dump(object)    <= Swift
    - po [self.view1 _ivarDescription]
    断点调试
Memory issues
    WWDC2017 - 404: Debugging with Xcode 9
    - Debug Memory Graph
#endif /* ReadMe_h */
