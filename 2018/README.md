# SessionList

    ![WWDC App](https://github.com/insidegui/WWDC)  
    https://developer.apple.com/videos/play/wwdc2018/sessionId

## ToDoList

  225

## 有代码

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

## 无代码

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

* 803: Designing Fluid Interfaces 流畅界面设计  +++建议观看

* 806: Designing Notifications

Graphics and Games

Media
