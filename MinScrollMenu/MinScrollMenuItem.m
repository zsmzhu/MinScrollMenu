//
//  MinScrollMenuItem.m
//  SimpleDemo
//
//  Created by songmin.zhu on 16/4/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "MinScrollMenuItem.h"

@interface MinScrollMenuItem ()
@property (nonatomic, strong) CALayer *selectedMaskLayer;
@property (nonatomic, assign) MinScrollMenuItemType type;
@end

@implementation MinScrollMenuItem

- (instancetype)initWithType:(MinScrollMenuItemType)type reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 60.0, 60.0)];
    if (self) {
        self.type = type;
        self.reuseIdentifer = reuseIdentifier;
        [self basePropertySetup];
    }
    
    return self;
}

- (void)basePropertySetup {
    self.userInteractionEnabled = YES;
    self.contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
    self.selectedMaskLayer.hidden = YES;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectedMaskLayer.hidden = !isSelected;
}

- (void)setType:(MinScrollMenuItemType)type {
    if (_type != type) {
        _type = type;
        
        switch (_type) {
            case BaseType:
                [_textLabel removeFromSuperview];
                _textLabel = nil;
                [_imageView removeFromSuperview];
                _imageView = nil;
                break;
            case TextType:
                [self addSubview:self.textLabel];
                break;
            case ImageType:
                [self addSubview:self.imageView];
                break;
            default:
                break;
        }
    }
}

- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
    }
    return _textLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    self.selectedMaskLayer.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    switch (self.type) {
        case TextType:
            self.textLabel.frame = CGRectMake(1.0, 1.0, frame.size.width-2, frame.size.height-2);
            break;
        case ImageType:
            self.imageView.frame = CGRectMake(1.0, 1.0, frame.size.width-2, frame.size.height-2);
            break;
        default:
            break;
    }
}

- (CALayer *)selectedMaskLayer {
    if (_selectedMaskLayer == nil) {
        _selectedMaskLayer = [CALayer layer];
        _selectedMaskLayer.frame = self.layer.frame;
        _selectedMaskLayer.backgroundColor = [UIColor colorWithRed:217.00/255.00 green:217.00/255.00 blue:217.00/255.00 alpha:1.0].CGColor;
        _selectedMaskLayer.hidden = YES;
        [self.layer insertSublayer:_selectedMaskLayer atIndex:0];
    }
    
    return _selectedMaskLayer;
}


@end
