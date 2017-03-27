
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

//#ifndef NS_DESIGNATED_INITIALIZER
//#if __has_attribute(objc_designated_initializer)
//#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
//#else
//#define NS_DESIGNATED_INITIALIZER
//#endif
//#endif

typedef NS_ENUM(NSInteger, HSReachabilityStatus) {
    HSReachabilityStatusUnknown          = -1,
    HSReachabilityStatusNotReachable     = 0,
    HSReachabilityStatusReachableViaWWAN = 1,
    HSReachabilityStatusReachableViaWiFi = 2,
};


@interface GPNetWorkManager : NSObject

@property (readonly, nonatomic, assign) HSReachabilityStatus networkReachabilityStatus;

@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

+ (instancetype)sharedManager;//

- (void)startMonitoring;//

- (void)setReachabilityStatusChangeBlock:(void (^)(HSReachabilityStatus status))block;//

@end

extern NSString * const HSReachabilityDidChangeNotification;
extern NSString * const HSReachabilityNotificationStatusItem;
extern NSString * HSAFStringFromNetworkReachabilityStatus(HSReachabilityStatus status);
