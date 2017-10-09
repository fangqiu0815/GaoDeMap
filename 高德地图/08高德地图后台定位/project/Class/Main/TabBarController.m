//
//  WOCOTabBarController.m
//  demo
//
//  Created by zhouyu on 2016/12/20.
//  Copyright © 2016年 demo. All rights reserved.
//

#import "TabBarController.h"
#import "NavigationController.h"

#define NorImgName   @"NorImgName"        // 普通图片名称
#define SelImgName   @"SelImgName"        // 选中图片名称
#define TabbarTitle  @"TabbarTitle"       // 标题
#define RootVcName   @"RootVcName"        // 控制器的名称字符串

@interface TabBarController ()
@property (nonatomic, strong) NSArray *childVcsArr;
@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildControllers];
    
    self.selectedIndex = 0;
}

- (void)setupChildControllers {
    
    // 1.创建临时数组
    NSMutableArray *tempArrM = [NSMutableArray array];
    // 2.遍历集合数据
    [self.childVcsArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *vcName = obj[RootVcName];
        Class vcClass = NSClassFromString(vcName);
        UIViewController *vc = [[vcClass alloc] init];
        
        vc.view.backgroundColor = [UIColor whiteColor];
        
        vc.tabBarController.tabBarItem.title = obj[TabbarTitle];
        // 设置标题 及普通状态时的文字颜色
        vc.navigationItem.title = obj[TabbarTitle];
        vc.title = obj[TabbarTitle];
        self.tabBar.tintColor = BackGroundColor(0, 0, 0);
        
        // 设置普通、选中图片
        vc.tabBarItem.image = [[UIImage imageNamed:obj[NorImgName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:obj[SelImgName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NavigationController *nav = [[NavigationController alloc] initWithRootViewController:vc];
        [tempArrM addObject:nav];
    }];
    self.viewControllers = tempArrM;
}

#pragma mark - 懒加载
- (NSArray *)childVcsArr {
    if (!_childVcsArr) {
        _childVcsArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarVcs.plist" ofType:nil]];
    }
    return _childVcsArr;
}

@end
