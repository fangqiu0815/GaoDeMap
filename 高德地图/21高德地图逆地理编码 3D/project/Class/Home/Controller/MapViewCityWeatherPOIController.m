//
//  MapViewCityWeatherPOIController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
/**
 通过天气查询，可获取城市的实时天气和今天以及未来3天的天气预报，可结合定位和逆地理编码功能使用，查询定位点所在城市的天气情况。注意：仅支持中国大陆、香港、澳门数据返回。
 天气查询是一个可用来改善app体验的功能，如：在跑步类app中加入天气的提醒；出行前了解天气情况以便安排行程。
 */

#import "MapViewCityWeatherPOIController.h"

@interface MapViewCityWeatherPOIController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewCityWeatherPOIController

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
     天气查询的请求参数类为 AMapWeatherSearchRequest，city（城市）为必设参数，type（气象类型）为可选，包含有两种类型：AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气，默认为 AMapWeatherTypeLive。
     */
    
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = @"110000";
//    request.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecast为预报天气
    request.type = AMapWeatherTypeForecast; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecast为预报天气
    [self.search AMapWeatherSearch:request];
    
}

/**
 当查询成功时，会进到 onWeatherSearchDone 回调函数，通过回调函数，可获取查询城市实时的以及未来3天的天气情况。
 说明:
 1）通过 response.lives 获取城市对应实时天气数据信息，实时天气详细信息参考 AMapLocalWeatherLive 类。
 2）通过 response.forecasts 获取城市对应预报天气数据信息，预报天气详细信息参考 AMapLocalWeatherForecast 类。
 3）可查询未来3天的预报天气，通过 AMapLocalWeatherForecast.casts 获取预报天气列表。
 
 ///天气查询返回
 @interface AMapWeatherSearchResponse : AMapSearchObject
 ///实时天气数据信息 AMapLocalWeatherLive 数组，仅在请求实时天气时有返回。
 @property (nonatomic, strong) NSArray<AMapLocalWeatherLive *> *lives;
 ///预报天气数据信息 AMapLocalWeatherForecast 数组，仅在请求预报天气时有返回
 @property (nonatomic, strong) NSArray<AMapLocalWeatherForecast *> *forecasts;
 
 @end
 
 ///天气预报类，支持当前时间在内的3天的天气进行预报
 @interface AMapLocalWeatherForecast : AMapSearchObject
 ///区域编码
 @property (nonatomic, copy)   NSString *adcode;
 ///省份名
 @property (nonatomic, copy)   NSString *province;
 ///城市名
 @property (nonatomic, copy)   NSString *city;
 ///数据发布时间
 @property (nonatomic, copy)   NSString *reportTime;
 ///天气预报AMapLocalDayWeatherForecast数组
 @property (nonatomic, strong) NSArray<AMapLocalDayWeatherForecast *> *casts;
 @end
 */
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response{
//    if (response.lives.count == 0){
//        return;
//    }
//    for (AMapLocalWeatherLive *object in response.lives) {
//        ZYLog(@"uid = %@--%@--%@--%@--%@--%@--%@--%@",object.province,object.city,object.weather,object.temperature,object.windDirection,object.humidity,object.reportTime,object.windPower);
//    }
    //2017-08-04 16:27:06.903 project[2181:590716] uid = 北京--北京市--晴--37--东北--31--2017-08-04 16:00:00--6
    //解析response获取天气信息，具体解析见 Demo
    
    if (response.forecasts.count == 0){
        return;
    }
    for (AMapLocalWeatherForecast *object in response.forecasts) {
        ZYLog(@"uid = %@--%@--%@--%@--%@",object.adcode,object.province,object.city,object.reportTime,object.casts);
    }
    AMapLocalWeatherForecast *weatherForecast = response.forecasts[response.forecasts.count - 1];
    NSArray *casts = weatherForecast.casts;
    for (AMapLocalDayWeatherForecast *object in casts) {
        ZYLog(@"uid = %@--%@--%@--%@",object.date,object.week,object.dayWeather,object.nightWeather);
    }
    
    /**
     2017-08-04 16:35:53.326 project[2191:592071] uid = 110000--北京--北京市--2017-08-04 11:00:00--[
                                                                                                <AMapLocalDayWeatherForecast: 0x1390a4ef0>,
                                                                                                <AMapLocalDayWeatherForecast: 0x13704e590>,
                                                                                                <AMapLocalDayWeatherForecast: 0x13704ced0>,
                                                                                                <AMapLocalDayWeatherForecast: 0x1390b8520>
                                                                                            ]
     2017-08-04 16:35:53.326 project[2191:592071] uid = 2017-08-04--5--晴--多云
     2017-08-04 16:35:53.326 project[2191:592071] uid = 2017-08-05--6--雷阵雨--雷阵雨
     2017-08-04 16:35:53.326 project[2191:592071] uid = 2017-08-06--7--晴--晴
     2017-08-04 16:35:53.327 project[2191:592071] uid = 2017-08-07--1--晴--晴
     */

}

/**
 ///某一天的天气预报信息
 @interface AMapLocalDayWeatherForecast : AMapSearchObject
 ///日期
 @property (nonatomic, copy) NSString *date;
 ///星期
 @property (nonatomic, copy) NSString *week;
 ///白天天气现象
 @property (nonatomic, copy) NSString *dayWeather;
 ///晚上天气现象
 @property (nonatomic, copy) NSString *nightWeather;
 ///白天温度
 @property (nonatomic, copy) NSString *dayTemp;
 ///晚上温度
 @property (nonatomic, copy) NSString *nightTemp;
 ///白天风向
 @property (nonatomic, copy) NSString *dayWind;
 ///晚上风向
 @property (nonatomic, copy) NSString *nightWind;
 ///白天风力
 @property (nonatomic, copy) NSString *dayPower;
 ///晚上风力
 @property (nonatomic, copy) NSString *nightPower;
 @end
 */


/**
 ///实况天气，仅支持中国大陆、香港、澳门的数据返回
 @interface AMapLocalWeatherLive : AMapSearchObject
 ///区域编码
 @property (nonatomic, copy) NSString *adcode;
 ///省份名
 @property (nonatomic, copy) NSString *province;
 ///城市名
 @property (nonatomic, copy) NSString *city;
 ///天气现象
 @property (nonatomic, copy) NSString *weather;
 ///实时温度
 @property (nonatomic, copy) NSString *temperature;
 ///风向
 @property (nonatomic, copy) NSString *windDirection;
 ///风力，单位：级
 @property (nonatomic, copy) NSString *windPower;
 ///空气湿度
 @property (nonatomic, copy) NSString *humidity;
 ///数据发布时间
 @property (nonatomic, copy) NSString *reportTime;
 @end
 */

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
