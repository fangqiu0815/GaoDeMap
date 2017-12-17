//
//  MapViewGetPOIDataController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewKeyWordPOIController.h"
//自定义标记点
#import "CustomAnnotationView.h"

//定义主搜索对象 AMapSearchAPI ，并继承搜索协议<AMapSearchDelegate>。
@interface MapViewKeyWordPOIController ()<MAMapViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
//关键字检索
@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *request;
//获取当前城市
@property (nonatomic, strong) AMapLocationManager *locationManager;

/**
 *  后台定位是否返回逆地理信息，默认NO。
 */
@property (nonatomic, assign) BOOL locatingWithReGeocode;
@property (nonatomic, copy) NSString *currentCity;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
// 数据源数组
@property (nonatomic, strong) NSMutableArray<AMapPOI *> *datas;
// 搜索结果数组
@property (nonatomic, strong) NSMutableArray<AMapPOI *> *results;
//搜索分类
@property (nonatomic, strong) NSArray *categoryArr;
//记录选择展示的地理位置信息
@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
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
    
    //获取当前定位信息
    [self getCurrentCity];
    
    //设置POI检索对象
    [self setPOISearch];
    
    //初始化底部工具条
    [self initToolBar];
    
    //设置搜索控制器
    [self searchController];
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
/*MARK:  POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0){
        return;
    }
    [self.results removeAllObjects];
    for (AMapPOI *object in response.pois) {
        ZYLog(@"%@,%@",object.name,object.type);
//        ZYLog(@"%@--%@--%@--%@",object.province,object.city,object.district,object.address);
//        NSString *poiStr = [NSString stringWithFormat:@"%@--%@--%@--%@",object.province,object.city,object.district,object.address];
        [self.results addObject:object];
    }
    [self.tableView reloadData];
    //解析response获取POI信息，具体解析见 Demo  http://lbs.amap.com/api/ios-sdk/guide/map-data/poi
    //下载POI分类码表   http://lbs.amap.com/api/webservice/download
}

//MARK: 当检索失败时，会进入 didFailWithError 回调函数，通过该回调函数获取产生的失败的原因。
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

//MARK: 设置实时检索对象
- (void)setPOISearch{
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
    self.request = request;
    
    //设置搜索行业分类
//    request.types  = self.categoryArr[self.searchController.searchBar.selectedScopeButtonIndex];
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = YES;
    request.requireSubPOIs      = YES;
    
    //    调用 AMapSearchAPI 的 AMapPOIKeywordsSearch 并发起关键字检索。
//    [self.search AMapPOIKeywordsSearch:request];
}

// MARK: 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;{
    NSLog(@"textDidChange---%@",searchBar.text);
    if (searchBar.text.length <= 0) {
        [self.results removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    self.request.keywords = searchBar.text;
    // 调用 AMapSearchAPI 的 AMapPOIKeywordsSearch 并发起关键字检索。
    [self.search AMapPOIKeywordsSearch:self.request];
}

//MARK: 获取当前定位城市
- (void)getCurrentCity{
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;//遵守代理,实现协议
    
    //MARK - 高精度：kCLLocationAccuracyBest，可以获取精度很高的一次定位，偏差在十米左右
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //   定位超时时间，最低2s，此处设置为10s
    self.locationManager.locationTimeout = 5;
    //   逆地理请求超时时间，最低2s，此处设置为10s
    self.locationManager.reGeocodeTimeout = 5;
    
    
    //请求定位并拿到结果
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *reGeocode, NSError *error) {
        //location 地理编码经纬度
        if (error){
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed){
                return;
            }
        }
        //逆地理编码
        if (reGeocode){
            NSLog(@"reGeocode:%@", reGeocode);
//            NSString *locationStr = [NSString stringWithFormat:@"location:{纬度lat:%f; 经度lon:%f; 精度accuracy:%f}",location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
            self.currentCity = reGeocode.city;
            self.request.city = reGeocode.city;
        }
    }];
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

#pragma mark - UISearchResultsUpdating - 搜索的时候
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.text.length <= 0) {
        [self.results removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    self.request.keywords = searchController.searchBar.text;
    // 调用 AMapSearchAPI 的 AMapPOIKeywordsSearch 并发起关键字检索。
    [self.search AMapPOIKeywordsSearch:self.request];
}
#pragma mark - tableViewDelegate搜索结果的展示
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 这里通过searchController的active属性来区分展示数据源是哪个
    //    if (self.searchController.active) {
    return self.results.count ;
    //    }
    //    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    // 这里通过searchController的active属性来区分展示数据源是哪个
    //    if (self.searchController.active ) {
    AMapPOI *object = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-(经度: %f--纬度: %f)",object.name,object.location.longitude,object.location.latitude];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@--%@--%@--%@",object.province,object.city,object.district,object.address];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.imageView.image = [UIImage imageNamed:@"address_location"];
    //    } else {
    //        cell.textLabel.text = [self.datas objectAtIndex:indexPath.row];
    //    }
    return cell;
}

//MARK: 根据搜索出来的结果进行逆地理编码--绘制标志点
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AMapPOI *object = self.results[indexPath.row];//AMapPOI.location属性保存经纬度信息
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(object.location.latitude, object.location.longitude);
    pointAnnotation.title = object.name;
    pointAnnotation.subtitle = [NSString stringWithFormat:@"%@-%@-%@",object.city,object.district,object.address];
    [_mapView addAnnotation:pointAnnotation];
    //保存下来选择的记录,下一次检索展示时删除
    self.pointAnnotation = pointAnnotation;
    
    [self.searchController.searchBar endEditing:YES];
    [self.searchController setActive:NO];
    
    //    if (self.searchController.active) {
//    NSLog(@"选择了搜索结果中的%@", [self.results objectAtIndex:indexPath.row]);
    //    } else {
    //        NSLog(@"选择了列表中的%@", [self.datas objectAtIndex:indexPath.row]);
    //    }
}

//MRRK: 添加自定义样式点标记--选择的地址在地图上显示
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]){
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"mobike"];
        annotationView.frame = CGRectMake(0, 0, 50, 50);
        
        // 设置为NO，用以调用自定义的calloutView
        annotationView.canShowCallout = NO;
        
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

#pragma mark - UISearchControllerDelegate代理
//MARK:  1. 展示搜索控制器--添加所搜结果的tableView
- (void)presentSearchController:(UISearchController *)searchController{
    //删除上一次筛选的信息
    [_mapView removeAnnotation:self.pointAnnotation];
    [self.view addSubview:self.tableView];
    NSLog(@"presentSearchController");
}
//MARK:  2. 将要弹出搜索控制器
- (void)willPresentSearchController:(UISearchController *)searchController{
    NSLog(@"willPresentSearchController");
}
//MARK:  3. 已经弹出搜索控制器
- (void)didPresentSearchController:(UISearchController *)searchController{
    NSLog(@"didPresentSearchController");
}
//MARK:  4. 将要消失搜索控制器
- (void)willDismissSearchController:(UISearchController *)searchController{
    NSLog(@"willDismissSearchController");
}
//MARK: 5. 已经消失搜索控制器--删除所搜结果的tableView
- (void)didDismissSearchController:(UISearchController *)searchController{
    [self.tableView removeFromSuperview];
    NSLog(@"didDismissSearchController");
}
//MARK: 点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchController.searchBar endEditing:YES];
//    [self.searchController setActive:NO];
}

//MARK: 搜索控制器
- (UISearchController *)searchController{
    if (_searchController == nil) {
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.delegate = self;
        // 设置结果更新代理
        searchController.searchResultsUpdater = self;
        // 因为在当前控制器展示结果, 所以不需要这个透明视图  //搜索时，背景变暗色
        searchController.dimsBackgroundDuringPresentation = YES;
        if (@available(iOS 9.1, *)) {
            //搜索时，背景变模糊
            searchController.obscuresBackgroundDuringPresentation = NO;
        }
        //是否隐藏导航栏,默认是YES
        searchController.hidesNavigationBarDuringPresentation = NO;
        
        //配置searchBar
        searchController.searchBar.frame = CGRectMake(45, 5, KUIScreenWidth - 55, 35);
        self.navigationItem.titleView = searchController.searchBar;
        searchController.searchBar.placeholder = @"搜索";
        [searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
        //分类设置
//        searchController.searchBar.showsScopeBar = NO;
//        searchController.searchBar.scopeButtonTitles = self.categoryArr;
//        searchController.searchBar.selectedScopeButtonIndex = 1;
        searchController.searchBar.delegate = self;
        // 改变取消按钮字体颜色
        //        searchController.searchBar.tintColor =  [UIColor whiteColor];
        // 改变searchBar背景颜色
        //        searchController.searchBar.barTintColor = [UIColor blueColor];
        // 取消searchBar上下边缘的分割线
        //        searchController.searchBar.backgroundImage = [[UIImage alloc] init];
        // 显示背景
        //        searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
        _searchController = searchController;
    }
    return _searchController;
}

//MARK: 结果展示
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 44 + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width - 20, self.view.bounds.size.height - 44 - [UIApplication sharedApplication].statusBarFrame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
        //        _tableView.tableHeaderView = _searchController.searchBar;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
//MARK: 初始数据
- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    return _datas;
}
//MARK: 结果展示
- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    return _results;
}
//MARK: 搜索的分类设置
- (NSArray *)categoryArr{
    if (_categoryArr == nil) {
        _categoryArr = @[@"餐饮",@"高等院校",@"公司",@"景区"];
    }
    return _categoryArr;
}

@end
