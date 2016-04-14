//
//  MinScrollMenu.m
//  SimpleDemo
//
//  Created by songmin.zhu on 16/4/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "MinScrollMenu.h"
#import "MinScrollMenuItem.h"

#define ITEMTAG 10086

@interface MinScrollMenu ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;/*!< 横向滚动的scrollView */
@property (nonatomic, strong) UIView *contentView;/*!< 装载item的view */
@property (nonatomic, assign) NSInteger count;/*!< item个数 */
@property (nonatomic, assign) BOOL isSelected;/*!< item是否被选中 */
@property (nonatomic, strong) NSMutableArray *visibleItems;/*!< 屏幕范围内的item数组 */
@property (nonatomic, strong) NSMutableSet *reuseableItems;/*!< 重用池 */
@property (nonatomic, strong) NSMutableDictionary *infoDict;/*!< 缓存item被选中信息 */
@property (nonatomic, strong) NSMutableDictionary *frameDict;/*!< 缓存item的frame */
@property (nonatomic, assign) CGFloat offset;/*!< 偏移量 */
@end

@implementation MinScrollMenu

#pragma Lazy Loading

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    [self reloadData];
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.userInteractionEnabled = YES;
    }
    return _contentView;
}

#pragma Public Method
/**
 *  刷新数据
 */
- (void)reloadData {
    //1. 获取contentOffset
    CGFloat offsetX = _scrollView.contentOffset.x;
    //2. 获取旧数据count
    NSInteger oldCount = _count;
    //3. 更新数据源
    [self setupData];
    //4. 获取新数据count
    NSInteger resetCount = _count;
    //5. 获取新数据maxX
    NSString *resetFrameString = [_frameDict allKeysForObject:@(resetCount-1)].firstObject;
    CGFloat resetMaxX = CGRectGetMaxX(CGRectFromString(resetFrameString));
    //6. UI更新
    // 旧数据count为0，不处理
    if (oldCount == 0) {
        return;
    }
    // 新数据count为0，移动scrollView到(0.0)
    else if (resetCount == 0) {
        _scrollView.contentOffset = CGPointMake(0, 0);
        return;
    }
    // 新数据count == 旧数据count
    // 新数据count > 旧数据count
    // 新数据count < 旧数据count
    else {
        //scrollView的offset.x >= 新数据的maxX
        // 移动offset.x到新数据maxX
        if (offsetX+ScreenWidth >= resetMaxX) {
            // 设置新的visibleItems
            __weak typeof(self) weakSelf = self;
            resetMaxX = [self addItemsUsingBlock:^{
                // 创建item，加入到visibleItems数组
                CGFloat maxX = 0.0;
                BOOL isOverScreenWidth = NO;
                for (NSInteger i = resetCount-1; i > -1; --i) {
                    CGFloat width = [weakSelf itemWidthWithIndex:i];
                    CGRect rect = CGRectFromString([weakSelf.frameDict allKeysForObject:@(i)].firstObject);
                    
                    // 超过屏幕可显示范围
                    CGFloat overItemWidth = width*3;
                    if (i < 3) {
                        overItemWidth = width + [self itemWidthWithIndex:i-1] + [self itemWidthWithIndex:i-2];
                    }
                    if (i < resetCount-1) {
                        isOverScreenWidth = rect.origin.x <  maxX - ScreenWidth - overItemWidth;
                    }
                    // 超过屏幕可显示范围break
                    if (isOverScreenWidth) {
                        break;
                    }
                    // 获取Cell
                    MinScrollMenuItem *item = [weakSelf editVisibleItemPlaceWithIndex:i originX:rect.origin.x];
                    if (item) {
                        // 加入到visibleItems
                        [weakSelf.visibleItems insertObject:item atIndex:0];
                        if (i == resetCount-1) {
                            maxX = CGRectGetMaxX(item.frame);
                        }
                    }
                }
            }];
            // 移动scrollView
            _scrollView.contentOffset = CGPointMake(resetMaxX, 0);
            return;
        }
        // scrollView的offset.x < 新数据maxX
        else {
            // 根据contentOffset.x设置新数据需要显示的item
            __block NSInteger resetIndex = 0;
            CGPoint point = {offsetX, 0.0};
            [_frameDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* index, BOOL * _Nonnull stop) {
                CGRect rect = CGRectFromString(key);
                if (CGRectContainsPoint(rect, point)) {
                    resetIndex = index.integerValue;
                    *stop = YES;
                }
            }];
            __weak typeof(self) weakSelf = self;
            [self addItemsUsingBlock:^{
                // 创建item，加入到visibleItems数组
                BOOL isOverScreenWidth = NO;
                CGRect onScreenRect = CGRectZero;
                for (NSInteger i = resetIndex; i < _count; ++i) {
                    CGRect rect = CGRectFromString([weakSelf.frameDict allKeysForObject:@(i)].firstObject);
                    CGFloat width = [weakSelf itemWidthWithIndex:i];
                    
                    // 获取item
                    MinScrollMenuItem *item = [weakSelf editVisibleItemPlaceWithIndex:i originX:rect.origin.x];
                    CGFloat maxX = CGRectGetMaxX(onScreenRect) + width;
                    CGFloat overItemWidth = width*3;
                    if (i < _count-3) {
                        overItemWidth = width + [self itemWidthWithIndex:i+1] + [self itemWidthWithIndex:i+2];
                    }
                    isOverScreenWidth = (maxX > ScreenWidth + overItemWidth);
                    onScreenRect = [item convertRect:item.bounds toView:[[UIApplication sharedApplication] keyWindow]];
                    // 超过屏幕可显示范围break
                    if (isOverScreenWidth) {
                        break;
                    }
                    if (item) {
                        [weakSelf.visibleItems addObject:item];
                    }
                }
            }];
            return;
        }
    }
}

/**
 *  获取重用的item
 *
 *  @param identifer 重用符
 *
 *  @return 重用的item
 */
- (MinScrollMenuItem *)dequeueItemWithIdentifer:(NSString *)identifer {
    NSSet *tempSet = [_reuseableItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"reuseIdentifer == %@", identifer]];
    MinScrollMenuItem *item = tempSet.anyObject;
    return item;
}

#pragma Private Method
/**
 *  初始化变量
 */
- (void)basePropertySetup {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    _visibleItems = [NSMutableArray array];
    _reuseableItems = [NSMutableSet set];
    _frameDict = [NSMutableDictionary dictionary];
    _infoDict = [NSMutableDictionary dictionary];
    [self setupData];
}

/**
 *  加载数据源
 */
- (void)setupData {
    // 清除数据
    [_visibleItems removeAllObjects];
    [_reuseableItems removeAllObjects];
    [_frameDict removeAllObjects];
    for (UIView *subView in _contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    // 根据代理获取item个数
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfMenuCount:)]) {
        _count = [self.delegate numberOfMenuCount:self];
    }
    
    // 计算cell的Frame
    CGFloat scrollContentWidth = 0.0;
    BOOL isOverScreenWidth = NO;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = 0.0;
    CGFloat height = self.frame.size.height;
    
    for (NSInteger i = 0; i < _count; ++i) {
        //获取item的宽度
        width = [self itemWidthWithIndex:i];
        CGRect itemFrame = CGRectMake(x, y, width, height);
        
        // 超过屏幕可显示范围不加入到visibleItems数组
        CGFloat maxX = CGRectGetMaxX(itemFrame);
        CGFloat overItemWidth = width*3;
        if (i < _count-3) {
            overItemWidth = width + [self itemWidthWithIndex:i+1] + [self itemWidthWithIndex:i+2];
        }
        isOverScreenWidth = maxX > ScreenWidth + overItemWidth;
        if (!isOverScreenWidth) {
            // 获取item，设置Frame, 添加到contentView上
            MinScrollMenuItem *item = [self itemWithIndex:i];
            if (item) {
                item.frame = itemFrame;
                [_contentView addSubview:item];
                
                // 添加点击手势
                UITapGestureRecognizer *tapGst = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
                [item addGestureRecognizer:tapGst];
                
                item.tag = ITEMTAG + i;
                
                // 加入到visibleItems数组
                [_visibleItems addObject:item];
            }
        }
        
        // 缓存数据
        [_frameDict setObject:@(i) forKey:NSStringFromCGRect(itemFrame)];
        [_infoDict setObject:@(NO) forKey:@(i)];
        
        // 计算scrollView的contentSize
        scrollContentWidth = maxX;
        
        x += width;
    }
    
    _scrollView.contentSize = CGSizeMake(scrollContentWidth, height);
    _contentView.frame = CGRectMake(0, 0, scrollContentWidth, height);
}

- (void)setDelegate:(id<MinScrollMenuDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = nil;
        _delegate = delegate;
        [self basePropertySetup];
    }
}

/**
 *  点击item响应方法
 *
 *  @param tapGst 手势实力
 */
- (void)tapItem: (UITapGestureRecognizer *)tapGst {
    [_infoDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL * _Nonnull stop) {
        *stop = obj.boolValue;
        if (*stop) {
            _infoDict[key] = @(NO);
        }
    }];
    for (MinScrollMenuItem *item in _visibleItems) {
        item.isSelected = NO;
        [_infoDict setObject:@(NO) forKey:@(item.tag-ITEMTAG)];
    }
    
    if ([tapGst.view isKindOfClass:[UIView class]]) {
        
        UIView *tempView = tapGst.view;
        MinScrollMenuItem *item = (MinScrollMenuItem *)tempView;
        
        if ([item isKindOfClass:[MinScrollMenuItem class]]) {
            item.isSelected = YES;
            [_infoDict setObject:@(YES) forKey:@(item.tag-ITEMTAG)];
            if (self.delegate && [self.delegate respondsToSelector:@selector(scrollMenu:didSelectedItem:atIndex:)]) {
                [self.delegate scrollMenu:self didSelectedItem:item atIndex:item.tag - ITEMTAG];
            }
        }
    }
}

/**
 *  获取item的宽度
 *
 *  @param index 索引
 *
 *  @return width: 宽度
 */
- (CGFloat)itemWidthWithIndex:(NSInteger)index {
    CGFloat width = 0;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(scrollMenu:widthForItemAtIndex:)]) {
        width = [self.delegate scrollMenu:self widthForItemAtIndex:index];
    }
    return width;
}

/**
 *  获取item
 *
 *  @param index 索引
 *
 *  @return item
 */
- (MinScrollMenuItem *)itemWithIndex:(NSInteger)index {
    MinScrollMenuItem *item = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(scrollMenu:itemAtIndex:)]) {
        item = [self.delegate scrollMenu:self itemAtIndex:index];
    }
    return item;
}

/**
 *  修改一个可视的item的位置
 *
 *  @param index         索引
 *  @param originX       需要修改的x轴坐标
 *
 *  @return 返回需要重新添加的item
 */
- (MinScrollMenuItem *)editVisibleItemPlaceWithIndex:(NSInteger)index originX:(CGFloat)originX {
    MinScrollMenuItem *item = [self itemWithIndex:index];
    item.isSelected = [_infoDict[@(index)] boolValue];
    item.tag = index + ITEMTAG;
    CGFloat x = originX;
    CGFloat y = 0.0;
    CGFloat width = [self itemWidthWithIndex:index];
    CGFloat height = self.frame.size.height;
    item.frame = CGRectMake(x, y, width, height);
    if (![_contentView.subviews containsObject:item]) {
        [_contentView addSubview:item];
    }
    if (item.gestureRecognizers.count == 0) {
        // 添加点击手势
        UITapGestureRecognizer *tapGst = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
        [item addGestureRecognizer:tapGst];
    }
    return item;
}

/**
 *  添加item到visibleItems数组
 *
 *  @param block 在block中添加
 *
 *  @return scrollView偏移量
 */
- (CGFloat)addItemsUsingBlock:(void(^)(void))block {
    // 清除数据
    for (UIView *view in _contentView.subviews) {
        [view removeFromSuperview];
    }
    [_visibleItems removeAllObjects];
    [_reuseableItems removeAllObjects];
    if (block) {
        block();
    }
    if (_visibleItems.count > 0) {
        CGFloat offsetX = CGRectGetMaxX([_visibleItems.lastObject frame]) - ScreenWidth;
        if (offsetX < 0) {
            offsetX = 0;
        }
        return offsetX;
    }
    return 0.0;
};


/**
 *  添加复用item到复用池
 *
 *  @param reuseItem 需要复用的item
 */
- (void)addReuseItem:(MinScrollMenuItem *)reuseItem {
    NSSet *tempSet = [_reuseableItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"reuseIdentifer == %@", reuseItem.reuseIdentifer]];
    // 查询复用池中有没有相同复用符的item
    if (![tempSet isSubsetOfSet:_reuseableItems] || tempSet.count == 0) {
        // 没有则添加item到复用池中
        [_reuseableItems addObject:reuseItem];
    }
}

/**
 *  滚动处理
 *
 *  @param scrollView 滚动中的scrollView
 */
- (void)srollHandle:(UIScrollView *)scrollView {
    //1 获取x位移
    CGFloat offsetX = scrollView.contentOffset.x;
    //2 获取topItem和lastItem
    MinScrollMenuItem *topItem = _visibleItems.firstObject;
    MinScrollMenuItem *lastItem = _visibleItems.lastObject;
    //3 滚动方向处理
    // 最左边和最右边的情况
    if (offsetX < 0 || offsetX+ScreenWidth > scrollView.contentSize.width) {
        // 不处理
    }
    // 往右滚动,第一个item已经在屏幕消失
    else if (offsetX > CGRectGetMaxX(topItem.frame) && offsetX > _offset) {
        
        if (lastItem.tag - ITEMTAG == _count-1) {
            // 滚动到最后一个item时返回
            _offset = offsetX;
            return;
        }
        // 将消失的item加入到复用池中
        [self addReuseItem:topItem];
        // 获取下一个item
        NSInteger nextIndex = lastItem.tag - ITEMTAG + 1;
        CGFloat maxX = CGRectGetMaxX(lastItem.frame);
        // 从visibleItems中移除topItem
        [_visibleItems removeObject:topItem];
        // 循环添加item，确保屏幕上有足够多的item显示
        while (nextIndex < _count) {
            CGFloat width = [self itemWidthWithIndex:nextIndex];
            MinScrollMenuItem *nextItem = [self editVisibleItemPlaceWithIndex:nextIndex originX:maxX];
            maxX = CGRectGetMaxX(nextItem.frame);
            if (nextItem) {
                // nextItem加到_visibleItems数组的最后
                [_visibleItems addObject:nextItem];
                // 复用池移除已经显示的nextItem
                if ([_reuseableItems containsObject:nextItem]) {
                    [_reuseableItems removeObject:nextItem];
                }
            }
            nextIndex++;
            if (maxX > offsetX + ScreenWidth + width) {
                break;
            }
        }
        
    }
    // 往左滚动，最后一个item已经在屏幕消失
    else if (offsetX < _offset && offsetX+ScreenWidth <= lastItem.frame.origin.x) {
        
        if (topItem.tag-ITEMTAG == 0) {
            // 滚动到第一个item时返回
            _offset = offsetX;
            return;
        }
        // 将消失的item加入到复用池中
        [self addReuseItem:lastItem];
        // 获取上一个item
        NSInteger previousIndex = topItem.tag - ITEMTAG - 1;
        CGFloat originX = topItem.frame.origin.x;
        // 从visibleItems中移除lastItem
        [_visibleItems removeObject:lastItem];
        // 循环添加item，确保屏幕上有足够多的item显示
        while (previousIndex > -1) {
            CGFloat width = [self itemWidthWithIndex:previousIndex];
            MinScrollMenuItem *previousItem = [self editVisibleItemPlaceWithIndex:previousIndex originX:originX - width];
            originX = previousItem.frame.origin.x;
            if (previousItem) {
                // previousItem加到_visibleItems数组
                [_visibleItems insertObject:previousItem atIndex:0];
                // 复用池移除已经显示的previousItem
                if ([_reuseableItems containsObject:previousItem]) {
                    [_reuseableItems removeObject:previousItem];
                }
            }
            previousIndex--;
            if (originX < offsetX - width) {
                break;
            }
            
        }
    }
    _offset = offsetX;
    return;
}

#pragma ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self srollHandle:scrollView];
}

@end
