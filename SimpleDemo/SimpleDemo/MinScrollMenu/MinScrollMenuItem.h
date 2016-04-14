//
//  MinScrollMenuItem.h
//  SimpleDemo
//
//  Created by songmin.zhu on 16/4/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, MinScrollMenuItemType) {
    BaseType,
    TextType,
    ImageType
};
@interface MinScrollMenuItem : UIView
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *reuseIdentifer;
@property (nonatomic, assign) BOOL isSelected;

/**
 *  初始化可重用的item
 *
 *  @param type            BaseType、TextType、ImageType
 *  @param reuseIdentifier 重用标识符
 *
 *  @return MinScrollMenuItem实例
 */
- (instancetype)initWithType:(MinScrollMenuItemType)type reuseIdentifier:(NSString *)reuseIdentifier;
@end
