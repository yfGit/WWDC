//
//  ToDoList.h
//  225
//
//  Created by 许毓方 on 2018/9/2.
//  Copyright © 2018 SN. All rights reserved.
//

#ifndef ToDoList_h
#define ToDoList_h


/*
 
 Issues:
 
    1. 瀑布流不同 section 之间交换时, Crash场景
        - section0 最后一列的 item 交换到 section1
        - section1 第一列的   item 交换到 section0
    以上两种情况 - prepareLayout 时 - numberOfItemsInSection: 获取的的 数量 不对, 哪怕调成对的, 会找不到对应的 layoutAttributes
 
    2. 禁止 section 之间交换
        - 如果是想 0-1 拖到 1-1, 之后回到 0-1, 但是中间的item数量超过一个屏幕了会卡  (XXXWaterfallLayout.m L:337)
 
    3. 瀑布流 - layoutAttributesForElementsInRect: 方法的优化
        - 补全 二分查找 (发现和一般查找有出入, 如一些 rect{x,x, 1, 1}) 普通搜索到, 而它不能)
        - 二分查找配合判断MaxY 的瀑布流场景逻辑错误
 
 
 
 
 Discussion:
 
 
 */

#endif /* ToDoList_h */
