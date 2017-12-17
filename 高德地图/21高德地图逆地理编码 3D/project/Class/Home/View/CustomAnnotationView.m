//
//  CustomAnnotationView.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "CustomAnnotationView.h"

#define kCalloutWidth       300.0
#define kCalloutHeight      80.0

@interface CustomAnnotationView ()

//@property (nonatomic, strong, readwrite) CustomCalloutView *calloutView;

@end

@implementation CustomAnnotationView

//（4） 重写选中方法setSelected。选中时新建并添加calloutView，传入数据；非选中时删除calloutView。
//注意：提前导入building.png图片。

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (self.selected == selected){
        return;
    }
    
    if (selected){
        if (self.calloutView == nil){
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        self.calloutView.image = [UIImage imageNamed:@"mine"];
        self.calloutView.title = self.annotation.title;
        self.calloutView.subtitle = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
    } else{
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

@end
