//
//  ViewController.m
//  SimpleDemo
//
//  Created by songmin.zhu on 16/4/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "ViewController.h"
#import "MinScrollMenu.h"
#import "MinScrollMenuItem.h"

@interface ViewController ()<MinScrollMenuDelegate>
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) MinScrollMenu *menu;
@property (weak, nonatomic) IBOutlet MinScrollMenu *ibMenu;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _count = 20;
    _ibMenu.delegate = self;
    
    _menu = [[MinScrollMenu alloc] initWithFrame:CGRectZero];
    _menu.delegate = self;
    
    [self.view addSubview:_menu];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _menu.frame = CGRectMake(0.0, CGRectGetMaxY(_ibMenu.frame)+10, ScreenWidth, 100.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)reload:(UIBarButtonItem *)sender {
    _count = arc4random() % 100;
    [_ibMenu reloadData];
    _count = arc4random() % 1000;
    [_menu reloadData];
}

#pragma MinScrollMenuDelegate Method

- (NSInteger)numberOfMenuCount:(MinScrollMenu *)menu {
    return _count;
}

- (CGFloat)scrollMenu:(MinScrollMenu *)menu widthForItemAtIndex:(NSInteger)index {
    if (index % 2 == 0) {
        return 50;
    }
    return 80;
}

- (MinScrollMenuItem *)scrollMenu:(MinScrollMenu *)menu itemAtIndex:(NSInteger)index {
    if (index %2 == 0) {
        MinScrollMenuItem *item = [menu dequeueItemWithIdentifer:@"textItem"];
        if (item == nil) {
            item = [[MinScrollMenuItem alloc] initWithType:TextType reuseIdentifier:@"textItem"];
            item.textLabel.textAlignment = NSTextAlignmentCenter;
            item.backgroundColor = [UIColor cyanColor];
            item.textLabel.layer.borderWidth = 1;
            item.textLabel.layer.borderColor = [UIColor blackColor].CGColor;
        }
        item.textLabel.text = [NSString stringWithFormat:@"%ld", index];
        
        return item;
    } else {
        MinScrollMenuItem *item = [menu dequeueItemWithIdentifer:@"imageItem"];
        if (item == nil) {
            item = [[MinScrollMenuItem alloc] initWithType:ImageType reuseIdentifier:@"imageItem"];
            item.imageView.image = [UIImage imageNamed:@"lotus"];
        }
        return item;
    }
}

- (void)scrollMenu:(MinScrollMenu *)menu didSelectedItem:(MinScrollMenuItem *)item atIndex:(NSInteger)index {
    NSLog(@"tap index: %ld", index);
}

@end
