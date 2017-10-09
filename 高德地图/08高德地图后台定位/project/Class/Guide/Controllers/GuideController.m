//
//  WOCOGuideController.m
//  WOCO
//
//  Created by Apple on 16/6/18.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "GuideController.h"
#import "GuideCell.h"

@interface GuideController ()

/**
 *  保存所有背景图片的集合
 */
@property (nonatomic, strong) NSArray<UIImage *> *imgsArr;

/**
 *  之前的页码
 */
@property (nonatomic, assign) int oldPage;


@end

@implementation GuideController

#pragma mark - 布局
- (instancetype)init {
    
    // 1.流水布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    return [super initWithCollectionViewLayout:flowLayout];
}


static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[GuideCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    GuideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:self.imgsArr[indexPath.row]];
    
    // 如果是最后一个cell，显示按钮，否则，隐藏
    if (indexPath.item == self.imgsArr.count - 1) {
        cell.experienceBtn.hidden = NO;
    } else {
        cell.experienceBtn.hidden = YES;
    }
    
    return cell;
}

- (void)dealloc {
//    ZYLog(@"新特性 --- oVer");
}

#pragma mark - 懒加载
- (NSArray *)imgsArr {
    if (_imgsArr == nil) {
        _imgsArr = @[
                     [UIImage imageNamed:@"guide1Background"],
                     [UIImage imageNamed:@"guide2Background"],
                     [UIImage imageNamed:@"guide3Background"],
                     [UIImage imageNamed:@"guide4Background"]
                     ];
    }
    return _imgsArr;
}

@end
