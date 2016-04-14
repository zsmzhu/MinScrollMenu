# MinScrollMenu
A custom horizontal scroll menu
![](https://github.com/zsmzhu/MinScrollMenu/raw/master/IntroduceImage/introduce.gif)
## Installation
### CocoaPods
pod ‘MinScrollMenu’
## How to use
### Storyboard or xib setup
1. create a MinScrollMenu on storyboard.
2. drag the IBOutlet of MinScrollMenu to you controller.
3. set the delegate property to the controller,
	like this: `_menu.delegate = self;`
### Manual setup
	_menu = [[MinScrollMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
	_menu.delegate = self;
	[self.view addSubview:_menu];
### Note
1. Require to realization 3 protocol method:
		- (NSInteger)numberOfMenuCount:(MinScrollMenu \*)menu;
		- (CGFloat)scrollMenu:(MinScrollMenu\*)menu widthForItemAtIndex:(NSInteger)index;
		- (MinScrollMenuItem *)scrollMenu:(MinScrollMenu*)menu itemAtIndex:(NSInteger)index;
2. Xib or storyboard create MinScrollMenuItem is not supported
3. If the menu size is not correct. Add this to your code
		self.automaticallyAdjustsScrollViewInsets = NO;

#### Here you go