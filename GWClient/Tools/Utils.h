//
//  Utils.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void) aCoder:(UserInfoModel *) model;

+ (UserInfoModel *) aDecoder;

+ (UITextField *) createTextField;

+(void)hintView:(UIView *)superView message:(NSString *) message;

+(void)GETaa:(ApiType) ApiType params:(NSDictionary *)params succeed:(void (^)(id))success fail:(void (^)(NSError *))failure;

+(void)GET:(ApiType) ApiType params:(NSDictionary *)params succeed:(void (^)(id))success fail:(void (^)(NSError *))failure;
@end
