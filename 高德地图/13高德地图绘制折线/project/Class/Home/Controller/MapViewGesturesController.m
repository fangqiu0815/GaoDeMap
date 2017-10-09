//
//  MapViewGesturesController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewGesturesController.h"

@interface MapViewGesturesController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation MapViewGesturesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    //指南针控件  原来设置22被navBar挡住
    _mapView.showsCompass= YES; // 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 72); //设置指南针位置
    
    //比例尺控件
    _mapView.showsScale= YES;  //设置成NO表示不显示比例尺；YES表示显示比例尺
    _mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 72);  //设置比例尺位置
    
    //地图logo控件
    _mapView.logoCenter = CGPointMake(10, KUIScreenHeight - 100);
    
//    手势交互
    _mapView.zoomEnabled = YES;    //NO表示禁用缩放手势，YES表示开启
    _mapView.scrollEnabled = YES;    //NO表示禁用滑动手势，YES表示开启
    //[_mapView setCenterCoordinate:center animated:YES];//地图平移时，缩放级别不变，可通过改变地图的中心点来移动地图
    
    //可以旋转3D矢量地图
//    _mapView.rotateEnabled= NO;    //NO表示禁用旋转手势，YES表示开启
//    [_mapView setRotationDegree:60.f animated:YES duration:0.5];//旋转角度的范围是[0.f 360.f]，以逆时针为正向
    //用户可以在地图上放置两个手指，移动它们一起向下或向上去增加或减小倾斜角
//    _mapView.rotateCameraEnabled= NO;    //NO表示禁用倾斜手势，YES表示开启
//    [_mapView setCameraDegree:30.f animated:YES duration:0.5];//倾斜角度范围为[0.f, 45.f]
    
//    指定屏幕中心点的手势操作
//    MAMapStatus *status = [self.mapView getMapStatus];
//    status.screenAnchor = CGPointMake(0.5, 0.76);//地图左上为(0,0)点，右下为(1,1)点。
//    [self.mapView setMapStatus:status animated:NO];
    
    
    [_mapView setZoomLevel:15.5 animated:YES];
    
    [self initToolBar];
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
