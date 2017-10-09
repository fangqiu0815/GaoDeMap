//
//  MapViewGeoCodeController.m
//  project
//
//  Created by zhouyu on 2017/8/3.
//  Copyright © 2017年 zhouyu. All rights reserved.
/**
 地理编码基本介绍
 
 地理编码，又称为地址匹配，是从已知的地址描述到对应的经纬度坐标的转换过程。该功能适用于根据用户输入的地址确认用户具体位置的场景，常用于配送人员根据用户输入的具体地址找地点。
 地址的定义： 首先，地址肯定是一串字符，内含国家、省份、城市、城镇、乡村、街道、门牌号码、屋邨、大厦等建筑物名称。按照由大区域名称到小区域名称组合在一起的字符。一个有效的地址应该是独一无二的。注意：针对大陆、港、澳地区的地理编码转换时可以将国家信息选择性的忽略，但省、市、城镇等级别的地址构成是不能忽略的。
 注意：不要将该功能与POI关键字搜索混用。
 POI关键字搜索，是根据关键词找到现实中存在的地物点（POI）。
 地理编码是依据当前输入，根据标准化的地址结构（省/市/区或县/乡/村或社区/商圈/街道/门牌号/POI）进行各个地址级别的匹配，以确认输入地址对应的地理坐标，只有返回的地理坐标匹配的级别为POI，才会对应一个具体的地物（POI）。
 */

#import "MapViewGeoCodeController.h"

@interface MapViewGeoCodeController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewGeoCodeController

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
    
    //地理编码，请求参数类为 AMapGeocodeSearchRequest，address是必设参数。
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
//    geo.address = @"北京市昌平区回龙观龙翔工业园6号院B座4层";
    geo.address = @"北京市昌平区回龙观龙翔工业园";
    [self.search AMapGeocodeSearch:geo];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    if (response.geocodes.count == 0){
        return;
    }
    for (AMapGeocode *object in response.geocodes) {
        ZYLog(@"formattedAddress = %@--%@--%@--%@--%@--%@--%@--%@",object.formattedAddress,object.province,object.city,object.district,object.township,object.neighborhood,object.building,object.location);
    }
    //解析response获取地理信息，具体解析见 Demo
    //2017-08-04 16:03:28.798 project[2145:585600] formattedAddress = 北京市昌平区龙翔工业园6号院|B座--北京市--北京市--昌平区--------<40.071381, 116.303137>
    //2017-08-04 16:05:30.719 project[2156:586472] formattedAddress = 北京市昌平区龙翔工业园--北京市--北京市--昌平区--------<40.072726, 116.299938>
}

/**
 ///地理编码
 @interface AMapGeocode : AMapSearchObject
 ///格式化地址
 @property (nonatomic, copy) NSString     *formattedAddress;
 ///所在省/直辖市
 @property (nonatomic, copy) NSString     *province;
 ///城市名
 @property (nonatomic, copy) NSString     *city;
 ///城市编码
 @property (nonatomic, copy) NSString     *citycode;
 ///区域名称
 @property (nonatomic, copy) NSString     *district;
 ///区域编码
 @property (nonatomic, copy) NSString     *adcode;
 ///乡镇街道
 @property (nonatomic, copy) NSString     *township;
 ///社区
 @property (nonatomic, copy) NSString     *neighborhood;
 ///楼
 @property (nonatomic, copy) NSString     *building;
 ///坐标点
 @property (nonatomic, copy) AMapGeoPoint *location;
 ///匹配的等级
 @property (nonatomic, copy) NSString     *level;
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
