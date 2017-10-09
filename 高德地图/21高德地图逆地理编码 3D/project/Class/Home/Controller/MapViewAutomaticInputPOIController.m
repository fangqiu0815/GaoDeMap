//
//  MapViewAutomaticInputPOIController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewAutomaticInputPOIController.h"

@interface MapViewAutomaticInputPOIController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewAutomaticInputPOIController

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
     输入提示查询介绍
     
     输入提示是指根据用户输入的关键词，给出相应的提示信息，将最有可能的搜索词呈现给用户，以减少用户输入信息，提升用户体验。如：输入“方恒”，提示“方恒国际中心A座”，“方恒购物中心”等。
     输入提示返回的提示语对象 AMapTip 有多种属性，可根据该对象的返回信息，配合其他搜索服务使用，完善您应用的功能。如：
     1）uid为空，location为空，该提示语为品牌词，可根据该品牌词进行POI关键词搜索。
     2）uid不为空，location为空，为公交线路，根据uid进行公交线路查询。
     3）uid不为空，location也不为空，是一个真实存在的POI，可直接显示在地图上。
     */
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
//    tips.keywords = key;//实际开发时动态获取input输入框内的值进行处理
    tips.keywords = @"向导";
    tips.city     = @"北京";
    tips.cityLimit = YES; //是否限制城市
    
    [self.search AMapInputTipsSearch:tips];
}

/**
 第 7 步，在回调中处理数据
 当检索成功时，会进到 onInputTipsSearchDone 回调函数中，通过解析 AMapInputTipsSearchResponse 对象获取输入提示词进行展示。
 说明：
 1）可以在回调中解析 response，获取提示词。
 2）通过 response.tips 可以获取到 AMapTip 列表，Poi详细信息可参考 AMapTip 类（包含：adcode、district、name等信息）。
 */
/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    ZYLog(@"%@",response);//AMapInputTipsSearchResponse
    /**
     ///搜索提示返回
     @interface AMapInputTipsSearchResponse : AMapSearchObject
     ///返回数目
     @property (nonatomic, assign) NSInteger  count;
     ///提示列表 AMapTip 数组， AMapTip 有多种属性，可根据该对象的返回信息，配合其他搜索服务使用，完善您应用的功能。如：\n 1）uid为空，location为空，该提示语为品牌词，可根据该品牌词进行POI关键词搜索。\n 2）uid不为空，location为空，为公交线路，根据uid进行公交线路查询。\n 3）uid不为空，location也不为空，是一个真实存在的POI，可直接显示在地图上。
     @property (nonatomic, strong) NSArray<AMapTip *> *tips;
     @end
     
     #pragma mark - 输入提示
     
     ///输入提示
     @interface AMapTip : AMapSearchObject
     ///poi的id
     @property (nonatomic, copy) NSString *uid;
     ///名称
     @property (nonatomic, copy) NSString *name;
     ///区域编码
     @property (nonatomic, copy) NSString *adcode;
     ///所属区域
     @property (nonatomic, copy) NSString *district;
     ///地址
     @property (nonatomic, copy) NSString *address;
     ///位置
     @property (nonatomic, copy) AMapGeoPoint *location;
     ///类型码, since 4.5.0. 对应描述可下载参考官网文档 http://a.amap.com/lbs/static/zip/AMap_API_Table.zip。
     @property (nonatomic, copy) NSString *typecode;
     @end
     */
    if (response.tips.count == 0){
        return;
    }
    for (AMapPOI *object in response.tips) {
        ZYLog(@"uid = %@--%@--%@--%@--%@--%@",object.uid,object.name,object.adcode,object.district,object.address,object.location);
    }
    //解析response获取提示词，具体解析见 Demo
    
    /**
     2017-08-04 15:51:06.508 project[2133:583254] <AMapInputTipsSearchResponse: 0x14eef2690>
     2017-08-04 15:51:06.508 project[2133:583254] uid = B000A80KTX--向导学校--110108--北京市海淀区--复兴路12号3层--<39.907012, 116.324428>
     2017-08-04 15:51:06.509 project[2133:583254] uid = B000A85H2T--向导教学中心--110108--北京市海淀区--会城门路与羊坊店东路交叉口西南50米--<39.904939, 116.324451>
     2017-08-04 15:51:06.509 project[2133:583254] uid = B0FFF2G14N--向导华人行房地产经纪公司--110105--北京市朝阳区--东三环中路9号富尔大厦8层0802室--<39.915053, 116.460824>
     2017-08-04 15:51:06.509 project[2133:583254] uid = B0FFH9RYE5--向导科技--110108--北京市海淀区--高粱桥斜街台体写字楼A区4层4012号--<39.947925, 116.342342>
     2017-08-04 15:51:06.509 project[2133:583254] uid = B0FFH9RIIK--向导科技(知春路分店)--110108--北京市海淀区--知春路中海实业大厦B座201室--<39.976032, 116.335639>
     2017-08-04 15:51:06.510 project[2133:583254] uid = B0FFG8HTKU--向导科技--110108--北京市海淀区--上地金泰富地大厦1楼--<40.042919, 116.315665>
     2017-08-04 15:51:06.514 project[2133:583254] uid = B0FFGW5GNT--向导科技有限公司--110114--北京市昌平区--回龙观龙翔工业园6号院B座1门4层--<40.071671, 116.303067>
     */
}

//当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
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
