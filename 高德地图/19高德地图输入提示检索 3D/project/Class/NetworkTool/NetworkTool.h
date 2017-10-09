//
//  NetworkTool.h
//  jinDuGold
//
//  Created by zhouyu on 16/9/29.
//  Copyright © 2016年 jinDu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


typedef enum{
    requestTypeGET,
    requestTypePOST
}requestType;

@interface NetworkTool : AFHTTPSessionManager

/**
 *  创建单例
 *
 *  @return 网络请求单例
 */
+ (instancetype _Nullable)shareNetworkTool;

- (void)requestWithType:(requestType)type URLString:(nonnull NSString *)URLString parameters:(nullable id)parameters progress:(nullable void (^)(NSProgress *_Nonnull downloadProgress))downloadProgress success:(nullable void (^)(NSURLSessionDataTask *_Nullable task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *_Nonnull error))failure;

- (void)requestWithType:(requestType)type URLString:(nonnull NSString *)URLString parameters:(nullable id)parameters success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure;

/**
 *  类方法网络请求
 *
 *  @param type       请求类型
 *  @param URLString  URLString
 *  @param parameters 参数
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+ (void)requestWithType:(requestType)type URLString:(nonnull NSString *)URLString parameters:(nullable id)parameters success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure;

/**
 *  上传头像到服务器
 *
 *  @param newIconImage   要上传的图片
 *  @param URLString    URLString
 *  @param parameters   post请求的参数
 *  @param name         上传到服务器的字段名
 *  @param fileName     上传到服务器的图片的名称
 *  @param mimeType     图片类型
 *  @param success     成功的回调
 *  @param failure     失败的回调
 */
+ (void)updateIconImage:(UIImage *_Nonnull)newIconImage andURLString:(NSString *_Nonnull)URLString andParameters:(NSDictionary *_Nullable)parameters andName:(NSString *_Nonnull)name andFileName:(NSString *_Nonnull)fileName andMimeType:(NSString *_Nonnull)mimeType success:(nullable void (^)(id _Nullable responseObject))success  failure:(nullable void (^)(NSError *_Nonnull error))failure;

/**
 *  从服务器下载头像
 *
 *  @param URLString     URLString
 *  @param iconImageName 头像图片保存到本地的名称
 *
 *  @return 返回头像图片
 */
+ (UIImage *_Nonnull)downloadIconImageWithURLString:(NSString *_Nonnull)URLString andIconImageName:(NSString *_Nonnull)iconImageName;
@end
