//
//  MapViewOneGPSController.m
//  project
//
//  Created by zhouyu on 2017/8/4.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "MapViewOneGPSController.h"

@interface MapViewOneGPSController ()<MAMapViewDelegate,AMapLocationManagerDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapLocationManager *locationManager;
/**
 *  后台定位是否返回逆地理信息，默认NO。
 */
@property (nonatomic, assign) BOOL locatingWithReGeocode;


//展示回调结果
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MapViewOneGPSController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    //展示定位结果
    [self initTextView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    //MARK - 由于苹果系统的首次定位结果为粗定位--推荐：kCLLocationAccuracyHundredMeters，一次还不错的定位，偏差在百米左右
//    // 带逆地理信息的一次定位（返回坐标和地址信息）
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
//    //   定位超时时间，最低2s，此处设置为2s
//    self.locationManager.locationTimeout =2;
//    //   逆地理请求超时时间，最低2s，此处设置为2s
//    self.locationManager.reGeocodeTimeout = 2;
    
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
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error){
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed){
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if (regeocode){
            NSLog(@"reGeocode:%@", regeocode);
            NSString *locationStr = [NSString stringWithFormat:@"location:{纬度lat:%f; 经度lon:%f; 精度accuracy:%f}",location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
            self.textView.text = [NSString stringWithFormat:@"%@\n%@\n%@",regeocode,locationStr,[self getCurrentTimes]];
        }
    }];
}

- (void)initTextView{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 44+[UIApplication sharedApplication].statusBarFrame.size.height, KUIScreenWidth, 105)];
    [self.view addSubview:textView];
    self.textView = textView;
}

//获取当前的时间

- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"回调时间 =  %@",currentTimeString);
    return [NSString stringWithFormat:@"回调时间: %@",currentTimeString];
}


@end
