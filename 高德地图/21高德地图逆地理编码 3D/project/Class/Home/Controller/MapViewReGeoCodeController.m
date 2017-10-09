//
//  MapViewReGeoCodeController.m
//  project
//
//  Created by zhouyu on 2017/8/3.
//  Copyright © 2017年 zhouyu. All rights reserved.
/**
 逆地理编码基本介绍
 
 逆地理编码，又称地址解析服务，是指从已知的经纬度坐标到对应的地址描述（如行政区划、街区、楼层、房间等）的转换。常用于根据定位的坐标来获取该地点的位置详细信息，与定位功能是黄金搭档。
 */

#import "MapViewReGeoCodeController.h"

@interface MapViewReGeoCodeController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewReGeoCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self initToolBar];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    //2017-08-04 16:03:28.798 project[2145:585600] formattedAddress = 北京市昌平区龙翔工业园6号院|B座--北京市--北京市--昌平区--------<40.071381, 116.303137>
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    AMapGeoPoint *coordinate = [AMapGeoPoint locationWithLatitude:40.071381 longitude:116.303137];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension  = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}
/**
 当逆地理编码成功时，会进到 onReGeocodeSearchDone 回调函数中，通过解析 AMapReGeocodeSearchResponse 获取这个点的地址信息（包括：标准化的地址、附近的POI、面区域 AOI、道路 Road等）。
 1）可以在回调中解析 response，获取地址信息。
 2）通过 response.regeocode 可以获取到逆地理编码对象 AMapReGeocode。
 3）通过 AMapReGeocode.formattedAddress 返回标准化的地址，AMapReGeocode.addressComponent 返回地址组成要素，包括：省名称、市名称、区县名称、乡镇街道等。
 4）AMapReGeocode.roads 返回地理位置周边的道路信息。
 5）AMapReGeocode.pois 返回地理位置周边的POI（大型建筑物，方便定位）。
 6）AMapReGeocode.aois 返回地理位置所在的AOI（兴趣区域）。
 */
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil){
        //解析response获取地址描述，具体解析见 Demo
        ZYLog(@"%@--%@--%@--%@",response.regeocode,response.regeocode.formattedAddress,response.regeocode.addressComponent,response.regeocode.roads);
        //2017-08-04 16:19:07.118 project[2172:589564] <AMapReGeocode: 0x154fe90f0>--北京市昌平区回龙观街道北京老韩世家服装有限责任公司--<AMapAddressComponent: 0x154e53570>--[<AMapRoad: 0x158f6e860>,<AMapRoad: 0x158f6e690>,<AMapRoad: 0x158f74580>]
    }
}

//当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

/**
 ///逆地理编码
 @interface AMapReGeocode : AMapSearchObject
 ///格式化地址
 @property (nonatomic, copy)   NSString             *formattedAddress;
 ///地址组成要素
 @property (nonatomic, strong) AMapAddressComponent *addressComponent;
 
 ///道路信息 AMapRoad 数组
 @property (nonatomic, strong) NSArray<AMapRoad *> *roads;
 ///道路路口信息 AMapRoadInter 数组
 @property (nonatomic, strong) NSArray<AMapRoadInter *> *roadinters;
 ///兴趣点信息 AMapPOI 数组
 @property (nonatomic, strong) NSArray<AMapPOI *> *pois;
 ///兴趣区域信息 AMapAOI 数组
 @property (nonatomic, strong) NSArray<AMapAOI *> *aois;
 @end

 */

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
