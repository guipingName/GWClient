//
//  GWDataManager.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 数据处理类
 */
@interface GWDataManager : NSObject


/**
 获取数据处理单例实体

 @return 单例实体
 */
+(instancetype) sharedInstance;


/**
 单例用户请求参数接口
 */
@property(nonatomic, strong)NSDictionary *response;

/**
 用户请求回调
 */
@property (nonatomic, copy) void (^requestData) (NSData *request);

// 有进度的请求
- (void)GET:(ApiType) ApiType params:(NSDictionary *)params
   succeed:(void (^)(id))success
      fail:(void (^)(NSError *))failure;

@end
