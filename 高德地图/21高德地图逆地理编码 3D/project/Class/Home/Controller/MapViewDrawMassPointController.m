//
//  MapViewDrawMassPointController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewDrawMassPointController.h"

@interface MapViewDrawMassPointController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation MapViewDrawMassPointController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
 
//    应用于移动端的海量点图层用于批量展现具有相似属性的坐标点数据。海量点图层支持处理的点数量级跨度较大，从几十个点至十万个点（建议不超过100000个点数据）都可以应用海量点图层进行处理。
    
//    该功能自 iOS 地图 SDK 5.1.0 版本起开始支持。
    
//    创建海量点图层
    
    ///根据file读取出经纬度数组
    NSString *file = [[NSBundle mainBundle] pathForResource:@"10w" ofType:@"txt"];
    NSString *locationString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *locations = [locationString componentsSeparatedByString:@"\n"];
    
    ///创建MultiPointItems数组，并更新数据
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i = 0; i < locations.count; ++i){
        @autoreleasepool {
            MAMultiPointItem *item = [[MAMultiPointItem alloc] init];
            NSArray *coordinate = [locations[i] componentsSeparatedByString:@","];
            if (coordinate.count == 2){
                item.coordinate = CLLocationCoordinate2DMake([coordinate[1] floatValue], [coordinate[0] floatValue]);
                [items addObject:item];
            }
        }
    }
    
    ///根据items创建海量点Overlay MultiPointOverlay
    MAMultiPointOverlay *_overlay = [[MAMultiPointOverlay alloc] initWithMultiPointItems:items];
    
    ///把Overlay添加进mapView
    [self.mapView addOverlay:_overlay];
    
    [self initToolBar];
}

//通过 renderer 调整海量点的icon、锚点，示例如下：
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MAMultiPointOverlay class]]){
        MAMultiPointOverlayRenderer * renderer = [[MAMultiPointOverlayRenderer alloc] initWithMultiPointOverlay:overlay];
        ///设置图片
        renderer.icon = [UIImage imageNamed:@"marker_blue"];
        ///设置锚点
        renderer.anchor = CGPointMake(0.5, 1.0);
        renderer.delegate = self;
        return renderer;
    }
    
    return nil;
}

//海量点点击事件
- (void)multiPointOverlayRenderer:(MAMultiPointOverlayRenderer *)renderer didItemTapped:(MAMultiPointItem *)item{
    NSLog(@"item :%@ <%f, %f>", item, item.coordinate.latitude, item.coordinate.longitude);
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
