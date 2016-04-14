//
//  MinScrollMenu.h
//  SimpleDemo
//
//  Created by songmin.zhu on 16/4/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@class MinScrollMenuItem, MinScrollMenu;

@protocol MinScrollMenuDelegate <NSObject>

@required
/**
 *  提供item个数，必须实现
 *
 *  @param menu MinScrollMenu实例
 *
 *  @return item个数，NSInteger类型
 */
- (NSInteger)numberOfMenuCount:(MinScrollMenu *)menu;
/**
 *  提供index位置的item宽度，必须实现
 *
 *  @param menu  MinScrollMenu实例
 *  @param index 索引
 *
 *  @return item宽度，CGFloat类型
 */
- (CGFloat)scrollMenu:(MinScrollMenu*)menu widthForItemAtIndex:(NSInteger)index;
/**
 *  提供index位置的item，必须实现
 *
 *  @param menu  MinScrollMenu实例
 *  @param index 索引
 *
 *  @return 返回MinScrollMenuItem实例
 */
- (MinScrollMenuItem *)scrollMenu:(MinScrollMenu*)menu itemAtIndex:(NSInteger)index;

@optional
/**
 *  点击index位置的item响应方法,可选方法
 *
 *  @param menu  MinScrollMenu实例
 *  @param item  MinScrollMenuItem实例
 *  @param index 索引
 */
- (void)scrollMenu:(MinScrollMenu*)menu didSelectedItem: (MinScrollMenuItem *)item atIndex: (NSInteger)index;

@end

@interface MinScrollMenu : UIView
@property (nonatomic, assign) id<MinScrollMenuDelegate> delegate;


/**
 *  刷新数据
 */
- (void)reloadData;
/**
 *  获取重用的item
 *
 *  @param identifer 重用符
 *
 *  @return 重用的item
 */
- (MinScrollMenuItem *)dequeueItemWithIdentifer:(NSString *)identifer;
@end
