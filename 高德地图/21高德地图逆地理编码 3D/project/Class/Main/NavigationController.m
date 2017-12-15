//
//  WOCONavigationController.m
//  demo
//
//  Created by zhouyu on 2016/12/20.
//  Copyright © 2016年 demo. All rights reserved.
//

#import "NavigationController.h"
#import <objc/runtime.h>

@interface NavigationController ()

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
    // 3.设置按钮颜色
    [navBar setTintColor:[UIColor blackColor]];
    
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
