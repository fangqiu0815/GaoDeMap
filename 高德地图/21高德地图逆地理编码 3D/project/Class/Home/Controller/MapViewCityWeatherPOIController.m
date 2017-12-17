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

@interface MapViewCityWeatherPOIController ()<MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapWeatherSearchRequest *request ;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, copy) NSArray *cityArr;
@property (nonatomic, copy) NSArray *cityCodeArr;
@property (nonatomic, copy) NSMutableArray *resultsArrM;
@end

@implementation MapViewCityWeatherPOIController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:self.cityArr];
    [segment addTarget:self action:@selector(citySelect:) forControlEvents:UIControlEventValueChanged];
    self.segment = segment;
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self initToolBar];
    
    [self setSearchAPI];
    
    [self.view addSubview:self.tableView];
}

- (void)citySelect:(UISegmentedControl *)sender{
    NSString *cityCode = self.cityCodeArr[sender.selectedSegmentIndex];
    self.request.city = cityCode;
    [self.search AMapWeatherSearch:self.request];
}

- (void)setSearchAPI{
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    /**
     天气查询的请求参数类为 AMapWeatherSearchRequest，city（城市）为必设参数，type（气象类型）为可选，包含有两种类型：AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气，默认为 AMapWeatherTypeLive。
     */
    
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    self.request = request;
    request.city = @"110000";//默认北京
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
    
    [self.resultsArrM removeAllObjects];
    for (AMapLocalWeatherForecast *object in response.forecasts) {
        ZYLog(@"uid = %@--%@--%@--%@--%@",object.adcode,object.province,object.city,object.reportTime,object.casts);
    }
    AMapLocalWeatherForecast *weatherForecast = response.forecasts[response.forecasts.count - 1];
    NSArray *casts = weatherForecast.casts;
    for (AMapLocalDayWeatherForecast *object in casts) {
        ZYLog(@"uid = %@--%@--%@--%@",object.date,object.week,object.dayWeather,object.nightWeather);
        [self.resultsArrM addObject:object];
    }
    [self.tableView reloadData];
}

//当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultsArrM.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AMapLocalDayWeatherForecast *object = self.resultsArrM[indexPath.row];
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"日期:%@--星期:%@",object.date,object.week];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"白天天气现象: %@--白天温度: %@--白天风力: %@",object.dayWeather,object.dayTemp,object.dayPower];;
    return cell;
}
/*
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

//MARK: 结果展示
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 44 + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width - 20, self.view.bounds.size.height - 44 - [UIApplication sharedApplication].statusBarFrame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (NSArray *)cityArr{
    if (_cityArr == nil) {
        _cityArr = @[@"  北京  ",@"  上海  ",@"  广州  ",@"  杭州  ",@"  信阳  "];
    }
    return _cityArr;
}
- (NSArray *)cityCodeArr{
    if (_cityCodeArr == nil) {
        _cityCodeArr = @[@"110000",@"310000",@"440100",@"330100",@"411500"];
    }
    return _cityCodeArr;
}
- (NSMutableArray *)resultsArrM{
    if (_resultsArrM == nil) {
        _resultsArrM = [[NSMutableArray alloc] init];
    }
    return _resultsArrM;
}

@end
