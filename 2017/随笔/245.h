
 
 
245: Building Apps with Dynamic Type

// 让用户在设置里去全局设置大小 vs app自带设置大小(系统提供反向设置最好, app设置同步到系统设置, 但是这就得区分app, 不过方便了app自定义布局)
// 后者可能更会是设计问题, 不会只有你的app需要调整大小(小说等阅读类除外), 毕竟对于感知, 触觉, 听觉, 视觉问题应该应用到每个app

Sample Code: // https://developer.apple.com/sample-code/wwdc/2017/Building-Apps-with-Dynamic-Type.zip
扩展阅读: 文字排版 // https://xiangwangfeng.com/2014/03/06/iOS%E6%96%87%E5%AD%97%E6%8E%92%E7%89%88(CoreText)%E9%82%A3%E4%BA%9B%E4%BA%8B/

Related Sessions 
    Design For Everyone WWDC 2017    Dynamic Type 设计理念
    What’s New in Accessibility WWDC 2017
    Media and Gaming Accessibility WWDC 2017
    Auto Layout Techniques in Interface Builder WWDC 2017

// 调试 Dynamic Type
选择 xCode -> 点击右上角 xCode -> Open Developer Tool -> Accessibility inspector

iOS11 长按tabbar 放大显示

使用iOS内置的文本样式: title1, Title2, Title3, Headline, Body, Callout, subhead, footnote, caption1, caption2
iOS11前 只有 Body 样式适配五种辅助功能(更大的字体)中的大小, iOS11 之后所有

更好的显示设计: Design For Everyone WWDC 2017

IB: Font - Font - Text styles
IB: 文本输入类, UILabel, UITextField, UITextView 都会有一个属性
    Dynamic Type: Automatically Adjusts Font

Code: label.Font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      label.adjustsFontForContentSizeCategory = YES;
     
Font + Automatically Adjusts Font : 当系统调整缩放后, 返回APP, 字体自动缩放
Font : 不会自动缩放 (UIButton 没有 Automatically Adjusts Font)


iOS11 支持 自定义字体
label.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:customFont]; (默认是 Body样式))
label.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleTitle1] scaledFontForFont:customFont]; // 按 title1 方式缩放
label.adjustsFontForContentSizeCategory = YES;

html5
body {
    font : -apple-system-body; // available Apple devices only
}


// 显示

/// 不够显示
IB: lines : 0
Code: numberOfLine = 0;

/// 两行重叠 (缩放后行间距还是一样)
[secondLabel.firstBaselineAnchor constraintEqualToSystemSpacingBelowAnchor:firstLabel.lastBaselineAnchor multiplier:1];
a.font = [[UIFontMetrics defaultMetrics] scaledValueForValue:40]; // 用于不是Auto Layout; frame.origin.y += 40;

relatvie: Auto Layout Techniques in Interface Builder WWDC 2017

/// 屏幕宽度不够 多个 label 显示, 建议可以更新界面, 两行 如 help界面(siri), 获取用户设置的字体大小
UILabel : UIView <UITraitEnvironment>
UIApplication.sharedApplication.preferredContentSizeCategory;
label.traitCollection.preferredContentSizeCategory

    // 两种界面  ㄟ( ▔, ▔ )ㄏ UIViewController <UITraitEnvironment>
    if( self.traitCollection.preferredContentSizeCategory.isAccessibilityElement ){
        // Vertically stack
    } else {
        // Lay out side by side
    }


// tableview 标准模式都支持
开启 Self-Sizing
设置
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 100;
    Header Footer也一样

// Custom Cells
contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor)
primaryLabel.firstBaselineAnchor.constraintEqualToSystemSpacingBelow(contentView.topAnchor, multiplier: 1.0)
contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor)
contentView.bottomAnchor.constraintEqualToSystemSpacingBelow(secondaryLabel.lastBaselineAnchor, multiplier: 1.0)

manual layout
Override sizeThatFits to return correct height
Use contentView.bounds.size.width to determine available width

// Image  有时候图片比文字更好传递信息(如电话记录的拔出的图标)

1. PDF 或提供各个缩放的图片
2. Assets: Preserve Vector Data;
           Scales: Single Scale (Assets.xcassets 中图片的属性)
    https://useyourloaf.com/blog/xcode-9-vector-images/
    xCode 9之前PDF会被分成@1, @2, @3.png, 在更大屏幕上还是会模糊

3. IB: Accessibility: Adjusts Image Size (UIImagView的属性)
   或code: imgView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;

// tabbar 上点击放大, 辅助功能里的放大到第7格
    IB: bar Item: 属性: Accessibility 提示放大图片
    或 code: barItem.largeContentSizeImage = largeImage;


