//
//  MapViewIDPOIController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewIDPOIController.h"

@interface MapViewIDPOIController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewIDPOIController

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
    
    /**
     ID检索介绍--///POI全局唯一ID
     
     通过关键字检索、周边检索以及多边形检索查询到的POI信息，可通过ID检索来获取POI详细的信息。
     */
    
    AMapPOIIDSearchRequest *request = [[AMapPOIIDSearchRequest alloc] init];
    
    //2017-08-04 15:41:25.741 project[2114:580942] uid = B000A7O1AI--北京市--北京市--朝阳区--望京街9号望京国际商业中心A座4层
    request.uid = @"B000A7O1AI";/////POI全局唯一ID
    request.requireExtension    = YES;
    
    [self.search AMapPOIIDSearch:request];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0){
        return;
    }
    for (AMapPOI *object in response.pois) {
        ZYLog(@"uid = %@--%@--%@--%@--%@",object.uid,object.province,object.city,object.district,object.address);
    }
    //解析response获取POI信息，具体解析见 Demo
}

//当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

/**
 @interface AMapPOI : AMapSearchObject
 ///POI全局唯一ID
 @property (nonatomic, copy)   NSString     *uid;
 ///名称
 @property (nonatomic, copy)   NSString     *name;
 ///兴趣点类型
 @property (nonatomic, copy)   NSString     *type;
 ///类型编码
 @property (nonatomic, copy)   NSString     *typecode;
 ///经纬度
 @property (nonatomic, copy)   AMapGeoPoint *location;
 ///地址
 @property (nonatomic, copy)   NSString     *address;
 ///电话
 @property (nonatomic, copy)   NSString     *tel;
 ///距中心点的距离，单位米。在周边搜索时有效
 @property (nonatomic, assign) NSInteger     distance;
 ///停车场类型，地上、地下、路边
 @property (nonatomic, copy)   NSString     *parkingType;
 ///商铺id
 @property (nonatomic, copy)   NSString     *shopID;
 
 ///邮编
 @property (nonatomic, copy)   NSString     *postcode;
 ///网址
 @property (nonatomic, copy)   NSString     *website;
 ///电子邮件
 @property (nonatomic, copy)   NSString     *email;
 ///省
 @property (nonatomic, copy)   NSString     *province;
 ///省编码
 @property (nonatomic, copy)   NSString     *pcode;
 ///城市名称
 @property (nonatomic, copy)   NSString     *city;
 ///城市编码
 @property (nonatomic, copy)   NSString     *citycode;
 ///区域名称
 @property (nonatomic, copy)   NSString     *district;
 ///区域编码
 @property (nonatomic, copy)   NSString     *adcode;
 ///地理格ID
 @property (nonatomic, copy)   NSString     *gridcode;
 ///入口经纬度
 @property (nonatomic, copy)   AMapGeoPoint *enterLocation;
 ///出口经纬度
 @property (nonatomic, copy)   AMapGeoPoint *exitLocation;
 ///方向
 @property (nonatomic, copy)   NSString     *direction;
 ///是否有室内地图
 @property (nonatomic, assign) BOOL          hasIndoorMap;
 ///所在商圈
 @property (nonatomic, copy)   NSString     *businessArea;
 ///室内信息
 @property (nonatomic, strong) AMapIndoorData *indoorData;
 ///子POI列表
 @property (nonatomic, strong) NSArray<AMapSubPOI *> *subPOIs;
 ///图片列表
 @property (nonatomic, strong) NSArray<AMapImage *> *images;
 
 ///扩展信息只有在ID查询时有效
 @property (nonatomic, strong) AMapPOIExtension *extensionInfo;
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
