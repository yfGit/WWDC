# SessionList

## Demo

App Store and Distribution

* 236: AVSpeechSynthesizer: Making iOS Talk

Developer Tools

Featured

Frameworks

* 233: Adding Delight to your iOS App  
  * External Display Support: 外接显示器, 改变iPhone的默认行为, 提高用户体验  
  * Layout-Driven UI: 布局驱动UI  
  * Laser-Fast Launches  
  * Smooth Scrolling  
  * Debugging like a Pro

* 225: A Tour of UICollectionView  
  * FlowLayout  
  * MosaicLayout  
  * 优化layout查找: 二分查找 **瀑布流移动动画时 maxY方式 判断会有问题**
  * 处理批量动画
  * 瀑布流和移动动画 (非session)

Graphics and Games

Media

* 503 WWDC 2016: Advances in AVFoundation Playback
  * 属性监听, 基本播放
  * 循环播放
  * HLS 提速

* 520: Measuring and Optimizing HLS Performance
  
## Without Demo

App Store and Distribution

* 302: What's New in Managing Apple Devices  
  * Classroom; Apple Business Manager
  * Verify your server supports ATS using: nscurl --ats-diagnostics URL

* 304: What's New in Search Ads
  * Search Ads Basic: 安装次数付费
  * Search Ads Advanced: 点击观看的次数付费 Createive set: 关键字匹配不同的预览资源

* 705: Engineering Subscriptions
  * 订购订单安全;
  * 订购状态轮询;
  * 订购自愿流失,非自愿流失;

* 721: Implementing AutoFill Credential Provider Extensions 定制密码自动填充

Developer Tools

* 227 Optimizing App Assets  
  * Compression:  减少10%-20%容量; 自动图像打包
  * Design and Production: slicing 矢量图
  * Cataloging: 支持 namespaces
  * Deployment: 性能矩阵 Metal/内存; NSDataAsset; Sprite atlases  

* 404 New Localization Workflows in Xcode 10  
  * 本地化工作流程, 本地目录化, xliff, fr.scloc; siri

* 407 Practical Approaches to Great App Performance    +++++++++++++++建议观看  
  * 性能优化理论
    * 性能问题类型
    * 性能测试
    * Time Profiler: Xcode tag案例; [2016-418: Using Time Profiler in Instruments](https://developer.apple.com/videos/play/wwdc2016/418/)
    * 通用的解决方案
  * Photos性能优化

* 418 Source Control Workflows in Xcode  

* 414 Understanding Crashes and Crash Logs ++++++++++++++++++++++
  * Fundamentals: 概念
  * Accessing crash logs: 符号化工具(Organizer  appstore testFlight bitcode)
  * Analyzing Crash Logs: 分析 .crash 文件 [TN2151崩溃报告](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)
    * 案例, 启动超时
    * 案例, 内存错误
  * Multithreading Issues: 多线程问题有时难以复现: Edit Scheme => Run/Diagnostics => Thread Sanitizer + Pause on issues

Featured

Frameworks

* 204: Automatic Strong Passwords and Security Code AutoFill

* 234: What’s New in Safari and WebKit  
  * WKWebView Crash也不会影响你的App
  * hash对比防止使用被更改的js, css等文件
  * Beacon API: 通常unload 事件发送异步请求(追踪用户信息...)会被忽略掉, 所以会用同步请求, 就这造成了例如点击延迟; 现在只要Safari还在运行, 就可以异步发送
  * img 标签可以用mp4, 内存占用也小很多相对于GIF
  * 首页图片异步解码
  * Safari Apple Pay API
  * &lt;img&gt; 新增 AR View

* 235 UIKit: Apps for Every Size and Shape  +++
  * [SafeArea适配](https://juejin.im/post/5b1a9e32518825137e13ac3e)
  * [iPhoneX尺寸](https://medium.com/uxabc/iphone-x-ui-design-specs-696fd4f262b6)

* 802: Intentional Design 意图设计

* 803: Designing Fluid Interfaces 流畅界面设计  +++ 建议观看

* 806: Designing Notifications

Graphics and Games

Media

* 219 Image and Graphics Best Practices   +++++++++++++++++++++++++++建议观看
  * 缓冲区知识
  * downsamp
  * CPU GPU 技巧
  * [分析](https://techblog.toutiao.com/2018/06/19/untitled-42/)
