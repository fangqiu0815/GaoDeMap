//
//  NetworkTool.m
//  jinDuGold
//
//  Created by zhouyu on 16/9/29.
//  Copyright © 2016年 jinDu. All rights reserved.
//

#import "NetworkTool.h"

static NetworkTool *instance;

@implementation NetworkTool

+ (instancetype _Nullable)shareNetworkTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkTool alloc]init];
        //  让AFN默认也支持接收text/html文件类型
        instance.responseSerializer.acceptableContentTypes
        = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
        
        // 设置超时时间--60s时长太长
        [instance.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        instance.requestSerializer.timeoutInterval = 20.f;
        [instance.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    });
    return instance;
}

//MARK: 一次封装的网络工具类
- (void)requestWithType:(requestType)type URLString:(NSString *)URLString parameters:(nullable id)parameters progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    if (type == requestTypeGET) {
        [instance GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    } else if (type == requestTypePOST) {
        [instance POST:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    }
}

//MARK: 二次封装的网络工具类---此层的block是最难理解的,这里的形参block和实参block含义不一样,只是类型一样,orginalSuccess形参block是回调过来的,包含的参数已经有了值,而success是实参block,等待被调用给参数列表赋值
- (void)requestWithType:(requestType)type URLString:(nonnull NSString *)URLString parameters:(nullable id)parameters success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure{
    //(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
    void (^orginalSuccess)(NSURLSessionDataTask * _Nullable, id  _Nullable) = ^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        //success((NSDictionary *)responseObject);---------将NSURLSessionDataTask省掉
        success(responseObject);
    };
    //(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure---------将NSURLSessionDataTask省掉
    void (^orginalFailure)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    };
    //将progress省掉
    [self requestWithType:type URLString:URLString parameters:parameters progress:nil success:orginalSuccess failure:orginalFailure];
}

//MARK: 三次封装的网络工具类
+ (void)requestWithType:(requestType)type URLString:(nonnull NSString *)URLString parameters:(nullable id)parameters success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure {
    [[NetworkTool shareNetworkTool] requestWithType:type URLString:URLString parameters:parameters success:success failure:failure];
}

//MARK: 上传头像到服务器
+ (void)updateIconImage:(UIImage *_Nonnull)newIconImage andURLString:(NSString *_Nonnull)URLString andParameters:(NSDictionary *_Nullable)parameters andName:(NSString *_Nonnull)name andFileName:(NSString *_Nonnull)fileName andMimeType:(NSString *_Nonnull)mimeType success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure {

    //(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
    void (^orginalSuccess)(NSURLSessionDataTask * _Nullable, id  _Nullable) = ^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        //success((NSDictionary *)responseObject);
        success(responseObject);
    };
    //(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
    void (^orginalFailure)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    };
    
    [[NetworkTool shareNetworkTool] POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [documents stringByAppendingPathComponent:fileName];
        NSData *data = [NSData dataWithContentsOfFile:path];
        // formData : 用于拼接文件上传时的表单数据
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } progress:nil success:orginalSuccess failure:orginalFailure];
}

// MARK: 下载头像
+ (UIImage *)downloadIconImageWithURLString:(NSString *_Nonnull)URLString andIconImageName:(NSString *_Nonnull)iconImageName {
    
    __block UIImage *newIconImage;
    
     //1.网络请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
     //让AFN返回原始的二进制数据,我们自己来解析
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    NSURLSessionDownloadTask *downloadTask = [instance downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // 在这个代码块里面指定文件下载完成之后的缓存路径,指定好了之后,会自动的剪切到completionHandler里面
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:iconImageName];
        NSURL *pathURL = [NSURL fileURLWithPath:fullPath];
        ZYLog(@"%@",pathURL);
        return pathURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完后,从Documents里获取头像,并显示
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *newIconImagePath = [documents stringByAppendingPathComponent:iconImageName];
        newIconImage = [UIImage imageWithContentsOfFile:newIconImagePath];
    }];
    [downloadTask resume];
    
    return newIconImage;
}


//头像保存到本地
- (void)saveIconImageToDocument:(UIImage *)newIconImage withName:(NSString *)newIconImageName {
    NSData *imageData = UIImageJPEGRepresentation(newIconImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:newIconImageName];
    [imageData writeToFile:fullPath atomically:NO];
}



@end
