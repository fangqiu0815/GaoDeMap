//
//  AppDelegate.m
//  project
//
//  Created by zhouyu on 2017/8/3.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "AppDelegate.h"
#import "GuideController.h"
#import "TabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//     2.设置为窗口的跟控制器
        if ([self isNewVersion]) {
            self.window.rootViewController = [[GuideController alloc] init];
        } else {
            self.window.rootViewController = [[TabBarController alloc] init];
        }
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - 判断当前应用是否需要显示新特性界面
- (BOOL)isNewVersion {
    
    // MARK: - 目标：第一次启动这个应用时，显示新特性界面，以后就直接进入主程序！
    // 版本号：两个版本号。Info.plist中有对应的版本号
    // 2.1 获取应用当前的版本号
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    NSString *currentVersion = infoDict[@"CFBundleShortVersionString"];
    
    // 2.2 获取之前存储的版本号
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldVersion = [userDefaults objectForKey:@"app_version"];
    
    // 2.3 比较如果两个相等，不需要显示新特性，直接进入主程序
    if ([currentVersion isEqualToString:oldVersion]) {
        return NO;
    } else {
        // 将最新的版本号存取起来！
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:currentVersion forKey:@"app_version"];
        return YES;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
