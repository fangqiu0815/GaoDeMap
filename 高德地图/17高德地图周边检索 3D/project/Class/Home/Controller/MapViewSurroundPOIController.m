//
//  MapViewSurroundPOIController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewSurroundPOIController.h"

@interface MapViewSurroundPOIController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapViewSurroundPOIController

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
     周边检索介绍
     
     适用于搜索某个位置附近的POI，可设置POI的类别，具体查询所在位置的餐饮类、住宅类POI，例如：查找天安门附近的厕所等等场景。
     说明：
     1、支持指定查询POI的类别。高德地图的POI类别共20个大类，分别为：汽车服务、汽车销售、汽车维修、摩托车服务、餐饮服务、购物服务、生活服务、体育休闲服务、医疗保健服务、住宿服务、风景名胜、商务住宅、政府机构及社会团体、科教文化服务、交通设施服务、金融保险服务、公司企业、道路附属设施、地名地址信息、公共设施，同时，每个大类别都还有二级以及三级的细小划分，具体的POI类别请参考：POI分类编码表。
     2、不设置POI的类别，默认返回“餐饮服务”、“商务住宅”、“生活服务”这三种类别的POI。
     */
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
//    请求参数类为 AMapPOIAroundSearchRequest，location是必设参数
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    request.keywords            = @"电影院";
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    
    [self.search AMapPOIAroundSearch:request];
    
    
    [self initToolBar];
}

/**
 第 7 步，在回调中处理数据
 当检索成功时，会进到 onPOISearchDone 回调函数中，通过解析 AMapPOISearchResponse 对象把检索结果在地图上绘制点展示出来。
 说明：
 1）可以在回调中解析 response，获取 POI 信息。
 2）response.pois 可以获取到 AMapPOI 列表，POI 详细信息可参考 AMapPOI 类。
 3）若当前城市查询不到所需 POI 信息，可以通过 response.suggestion.cities 获取当前 POI 搜索的建议城市。
 4）如果搜索关键字明显为误输入，则可通过 response.suggestion.keywords法得到搜索关键词建议。
 */
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0)
    {
        return;
    }
    for (AMapPOI *object in response.pois) {
        ZYLog(@"%@--%@--%@--%@",object.province,object.city,object.district,object.address);
    }
    //解析response获取POI信息，具体解析见 Demo
    
    /**
     2017-08-04 15:35:03.940 project[2105:579069] 北京市--北京市--朝阳区--望京街9号望京国际商业中心A座4层
     2017-08-04 15:35:03.941 project[2105:579069] 北京市--北京市--朝阳区--阜通西大街11号合生·麒麟新天地2F层
     2017-08-04 15:35:03.941 project[2105:579069] 北京市--北京市--朝阳区--望京东园一区120号新荟城购物中心5层
     2017-08-04 15:35:03.942 project[2105:579069] 北京市--北京市--朝阳区--启阳路附近
     2017-08-04 15:35:03.942 project[2105:579069] 北京市--北京市--朝阳区--酒仙桥万红路甲31号院内
     2017-08-04 15:35:03.943 project[2105:579069] 北京市--北京市--朝阳区--望京开发街道望京东路4号院美团网
     2017-08-04 15:35:03.943 project[2105:579069] 北京市--北京市--朝阳区--梦秀欢乐广场6层
     2017-08-04 15:35:03.944 project[2105:579069] 北京市--北京市--朝阳区--酒仙桥路18号颐堤港L4层
     2017-08-04 15:35:03.944 project[2105:579069] 北京市--北京市--朝阳区--酒仙桥路18号颐堤港4层
     2017-08-04 15:35:03.945 project[2105:579069] 北京市--北京市--朝阳区--广顺北大街16号望京华彩商业中心B1层、B4层
     2017-08-04 15:35:03.945 project[2105:579069] 北京市--北京市--朝阳区--东四环北路6号阳光上东中环商业广场2层
     2017-08-04 15:35:03.945 project[2105:579069] 北京市--北京市--朝阳区--京顺路111号比如世界购物中心
     */
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
