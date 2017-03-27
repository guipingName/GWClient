
#import "GPNetWorkManager.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const HSReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const HSReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

typedef void (^AFNetworkReachabilityStatusBlock)(HSReachabilityStatus status);

typedef NS_ENUM(NSUInteger, HSReachabilityAssociation) {
    HSReachabilityForAddress = 1,
    HSReachabilityForAddressPair = 2,
    HSReachabilityForName = 3,
};


static HSReachabilityStatus HSReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    HSReachabilityStatus status = HSReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = HSReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = HSReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = HSReachabilityStatusReachableViaWiFi;
    }

    return status;
}


static void HSReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    HSReachabilityStatus status = HSReachabilityStatusForFlags(flags);
    AFNetworkReachabilityStatusBlock block = (__bridge AFNetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }


    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ HSReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:HSReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });

}


static const void * HSReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}


static void HSReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface GPNetWorkManager ()
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef HSnetworkReachability;//
@property (readwrite, nonatomic, assign) HSReachabilityAssociation networkReachabilityAssociation;//
@property (readwrite, nonatomic, assign) HSReachabilityStatus HSnetworkReachabilityStatus;
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;//
@end

@implementation GPNetWorkManager


+ (instancetype)sharedManager {
    static GPNetWorkManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;

        _sharedManager = [self HSManagerForAddress:&address];
    });

    return _sharedManager;
}


+ (instancetype) HSManagerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);

    GPNetWorkManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = HSReachabilityForAddress;

    return manager;
}


- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.HSnetworkReachability = reachability;
    self.HSnetworkReachabilityStatus = HSReachabilityStatusUnknown;

    return self;
}

- (void)dealloc {
    [self stopMonitoring];

    if (_HSnetworkReachability) {
        CFRelease(_HSnetworkReachability);
        _HSnetworkReachability = NULL;
    }
}

//#pragma mark -
//
- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == HSReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == HSReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.HSnetworkReachability) {
        return;
    }

    __weak __typeof(self)weakSelf = self;
    AFNetworkReachabilityStatusBlock callback = ^(HSReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.HSnetworkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, HSReachabilityRetainCallback, HSReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.HSnetworkReachability, HSReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.HSnetworkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    switch (self.networkReachabilityAssociation) {
        case HSReachabilityForName:
            break;
        case HSReachabilityForAddress:
        case HSReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.HSnetworkReachability, &flags);
                HSReachabilityStatus status = HSReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);

                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:HSReachabilityDidChangeNotification object:nil userInfo:@{ HSReachabilityNotificationStatusItem: @(status) }];


                });
            });
        }
            break;
    }
}


- (void)stopMonitoring {
    if (!self.HSnetworkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.HSnetworkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

//- (NSString *)localizedNetworkReachabilityStatusString {
//    return AFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
//}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(HSReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
