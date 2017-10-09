//
//  WOCONavigationController.m
//  demo
//
//  Created by zhouyu on 2016/12/20.
//  Copyright © 2016年 demo. All rights reserved.
//

#import "NavigationController.h"
#import <objc/runtime.h>

@interface NavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>
/** 系统手势代理 */
@property (nonatomic, strong) id popGesture;
@end

@implementation NavigationController

//初始化外观代理对象
+ (void)initialize {
    
    // 1.获取外观代理对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 2.设置标题字体大小,颜色
    [navBar setTitleTextAttributes:@{
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     }];
    //背景图片
    [navBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_backgroundColor"] forBarMetrics:UIBarMetricsDefault];
    // 3.设置按钮颜色
    [navBar setTintColor:[UIColor blackColor]];
    
    
    // 获取到导航条按钮的标识
    UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedIn:self, nil];
    // 修改返回按钮标题的位置
    [item setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -100) forBarMetrics:UIBarMetricsDefault];
}

//修改统一返回样式
- (void)viewDidLoad{
    // 1.先修改系统的手势,系统没有给我们提供属性
    UIScreenEdgePanGestureRecognizer *gest = self.interactivePopGestureRecognizer;
    id target = self.interactivePopGestureRecognizer.delegate;
    //    // 2.自己添加手势 --禁止系统的手势
    self.interactivePopGestureRecognizer.enabled = NO;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    //    pan.enabled = NO;
    [self.view addGestureRecognizer:pan];
    pan.delegate = self;
}
#pragma mark - UIGestureRecognizerDelegate
// 当开始滑动的就会调用 如果返回YES ,可以滑动 返回NO,禁止手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // 当是跟控制器不让移除(禁止), 费根控制器,允许移除控制
    BOOL open = self.viewControllers.count > 1;
    return open;
}
- (void)back{
    [self popViewControllerAnimated:YES];
}



//电池栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

// 跳转时隐藏tabbar
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.view.backgroundColor = [UIColor whiteColor];
    }
    [super pushViewController:viewController animated:animated];
}

@end
