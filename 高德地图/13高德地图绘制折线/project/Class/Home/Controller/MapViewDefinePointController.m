//
//  MapViewDefinePointController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewDefinePointController.h"
#import "CustomAnnotationView.h"

@interface MapViewDefinePointController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation MapViewDefinePointController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
//    添加自定义样式点标记------iOS SDK可自定义标注（包括 自定义标注图标 和 自定义气泡图标），均通过MAAnnotationView来实现。
    //自定义标注图标
//    若大头针样式的标注不能满足您的需求，您可以自定义标注图标。步骤如下：
//    （1） 添加标注数据对象，可参考大头针标注的步骤（1）。
//    （2） 导入标记图片文件到工程中。这里我们导入一个名为 restauant.png 的图片文件。
//    （3） 在 <MAMapViewDelegate>协议的回调函数mapView:viewForAnnotation:中修改 MAAnnotationView 对应的标注图片。示例代码如下：
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
    pointAnnotation.title = @"方恒国际";
    pointAnnotation.subtitle = @"阜通东大街6号";
    
    [_mapView addAnnotation:pointAnnotation];
    
    
    //添加自定义气泡
//    (1） 新建自定义气泡类 CustomCalloutView，继承 UIView。
// （2） 在 CustomCalloutView.h 中定义数据属性，包含：图片、商户名和商户地址。
    
    //添加自定义AnnotationView
//    由于是高度自定义内容，以下文档中仅提供OC语言的示例：
//    （1） 新建类CustomAnnotationView，继承MAAnnotationView或MAPinAnnotationView。若继承MAAnnotationView，则需要设置标注图标；若继承MAPinAnnotationView，使用默认的大头针标注
//    （2） 在CustomAnnotationView.h中定义自定义气泡属性
    
    //(5） 修改ViewController.m，在MAMapViewDelegate的回调方法mapView:viewForAnnotation中的修改annotationView的类型

    
     [self initToolBar];
}

////添加默认样式点标记
//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]]){
//        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
//        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
//        if (annotationView == nil){
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
//        }
//        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
//        return annotationView;
//    }
//    return nil;
//}

////自定义标注图标
//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]]){
//        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
//        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
//        if (annotationView == nil){
//            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
//        }
//        annotationView.image = [UIImage imageNamed:@"tabbar_home_select"];
//        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -18);
//        ZYLog(@"%@",annotationView);//MAAnnotationView - 0x146eea1a0; frame = {{-15, -33}, {30, 30}}; visible: 0, zIndex: 0
//        return annotationView;
//    }
//    return nil;
//}

//添加自定义样式点标记
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"tabbar_home_select"];
        
        // 设置为NO，用以调用自定义的calloutView
        annotationView.canShowCallout = NO;
        
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
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
