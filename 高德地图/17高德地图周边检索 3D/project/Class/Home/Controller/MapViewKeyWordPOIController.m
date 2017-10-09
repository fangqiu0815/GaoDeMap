//
//  MapViewGetPOIDataController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewKeyWordPOIController.h"

//定义主搜索对象 AMapSearchAPI ，并继承搜索协议<AMapSearchDelegate>。
@interface MapViewKeyWordPOIController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewKeyWordPOIController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    /**
     关键字检索介绍
     
     根据关键字检索适用于在某个城市搜索某个名称相关的POI，例如：查找北京市的“肯德基”。
     注意：
     1、关键字未设置城市信息（默认为全国搜索）时，如果涉及多个城市数据返回，仅会返回建议城市，请根据APP需求，选取城市进行搜索。
     2、不设置POI的类别，默认返回“餐饮服务”、“商务住宅”、“生活服务”这三种类别的POI，下方提供了POI分类码表，请按照列表内容设置希望检索的POI类型。（建议使用POI类型的代码进行检索）
     */
    
    //构造主搜索对象 AMapSearchAPI，并设置代理。
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
//    进行关键字检索的请求参数类为 AMapPOIKeywordsSearchRequest，其中 keywords 是必设参数。types 为搜索类型。
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    request.keywords            = @"北京大学";
    request.city                = @"北京";
    request.types               = @"高等院校";
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = YES;
    request.requireSubPOIs      = YES;
    
//    调用 AMapSearchAPI 的 AMapPOIKeywordsSearch 并发起关键字检索。
    [self.search AMapPOIKeywordsSearch:request];
    
    
    
    [self initToolBar];
}

/**
 第 7 步，在回调中处理数据
 当检索成功时，会进到 onPOISearchDone 回调函数中，通过解析 AMapPOISearchResponse 对象把检索结果在地图上绘制点展示出来。
 说明：
 1）可以在回调中解析 response，获取 POI 信息。
 2）response.pois 可以获取到 AMapPOI 列表，POI 详细信息可参考 AMapPOI 类。
 3）若当前城市查询不到所需 POI 信息，可以通过 response.suggestion.cities 获取当前 POI 搜索的建议城市。
 4）如果搜索关键字明显为误输入，则可通过 response.suggestion.keywords 属性得到搜索关键词建议。
 */
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0){
        return;
    }
    for (AMapPOI *object in response.pois) {
        ZYLog(@"%@--%@--%@--%@",object.province,object.city,object.district,object.address);
    }
    
    /**
     2017-08-04 15:19:38.058 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号
     2017-08-04 15:19:38.058 project[2085:575620] 北京市--北京市--海淀区--学院路38号
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--海淀区--阜成路33号
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--房山区--良乡高教园区
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--朝阳区--北三环东路15号
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学红三楼
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--朝阳区--定福庄东街1号
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--朝阳区--北四环东路97号
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学
     2017-08-04 15:19:38.059 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学
     2017-08-04 15:19:38.060 project[2085:575620] 北京市--北京市--海淀区--中关村南大街5号
     2017-08-04 15:19:38.060 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号逸夫苑北京大学
     2017-08-04 15:19:38.060 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学
     2017-08-04 15:19:38.061 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学附近
     2017-08-04 15:19:38.061 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学
     2017-08-04 15:19:38.061 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号北京大学内
     2017-08-04 15:19:38.061 project[2085:575620] 北京市--北京市--海淀区--颐和园路5号
     2017-08-04 15:19:38.061 project[2085:575620] 北京市--北京市--海淀区--海淀街道海淀路50号-甲
     2017-08-04 15:19:38.062 project[2085:575620] 北京市--北京市--海淀区--北京大学东门地铁站B东北口东北200米
     */
    
    
    //解析response获取POI信息，具体解析见 Demo  http://lbs.amap.com/api/ios-sdk/guide/map-data/poi
    //下载POI分类码表   http://lbs.amap.com/api/webservice/download
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
