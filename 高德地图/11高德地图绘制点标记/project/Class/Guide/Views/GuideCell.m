//
//  WOCOGuideCell.h
//  WOCO
//
//  Created by Apple on 16/6/18.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "GuideCell.h"
#import "TabBarController.h"
#import "Masonry.h"

@interface GuideCell ()

@end

@implementation GuideCell

#pragma mark - 添加按钮
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // MARK: - 立即体验按钮
        UIButton *experienceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        experienceBtn.hidden = YES;
        [experienceBtn setImage:[UIImage imageNamed:@"guideStart"] forState:UIControlStateNormal];
        [experienceBtn sizeToFit];
        [self.contentView addSubview:experienceBtn];
        self.experienceBtn = experienceBtn;
        [experienceBtn addTarget:self action:@selector(experienceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.experienceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-60);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
}

#pragma mark - 进入主程序
- (void)experienceBtnClick {
    // 通过切换应用程序的主窗口的根控制器，进入主程序！
    [UIApplication sharedApplication].keyWindow.rootViewController = [[TabBarController alloc] init];
}


@end
