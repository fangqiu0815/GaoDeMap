//
//  MapViewDefineBlueNodeController.m
//  project
//
//  Created by zhouyu on 2017/8/3.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewDefineBlueNodeController.h"

@interface MapViewDefineBlueNodeController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation MapViewDefineBlueNodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMapView];
    
    //地图的缩放级别的范围是[3-19]
    [_mapView setZoomLevel:16 animated:YES];
    
    [self defineBlueNode];
    
    [self setBlueNode];
    
    [self initToolBar];
}

#pragma mark - 以下功能自iOS 地图 SDK V5.0.0 版本起支持。
//AMap_iOS_2DMap_Demo_V4.6.0
//AMap_iOS_3DMap_Demo_V5.2.1  
//自定义定位小蓝点
- (void)defineBlueNode{
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsAccuracyRing = YES;///精度圈是否显示，默认YES
    r.showsHeadingIndicator = YES;///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
    r.fillColor = [UIColor redColor];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
    r.strokeColor = [UIColor blueColor];///精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
    r.lineWidth = 2;///精度圈 边线宽度，默认0
//    r.enablePulseAnnimation = NO;///内部蓝色圆点是否使用律动效果, 默认YES
//    r.locationDotBgColor = [UIColor greenColor];///定位点背景色，不设置默认白色
//    r.locationDotFillColor = [UIColor grayColor];///定位点蓝色圆点颜色，不设置默认蓝色
//     r.image = [UIImage imageNamed:@"你的图片"]; ///定位图标, 与蓝色原点互斥
    [self.mapView updateUserLocationRepresentation:r];
}

//如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
- (void)setBlueNode{
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
}

- (void)initMapView{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)mapTypeAction:(UISegmentedControl *)segmentedControl{
    self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

#pragma mark - Initialization
- (void)initToolBar{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UISegmentedControl *mapTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:@"标准(Standard)",@"卫星(Satellite)",nil]];
    mapTypeSegmentedControl.selectedSegmentIndex  = self.mapView.mapType;
    [mapTypeSegmentedControl addTarget:self action:@selector(mapTypeAction:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *mayTypeItem = [[UIBarButtonItem alloc] initWithCustomView:mapTypeSegmentedControl];
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, mayTypeItem, flexbleItem, nil];
}


@end
