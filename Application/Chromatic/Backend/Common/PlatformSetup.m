//
//  NSObject+PlatformSetup.m
//  Chromatic
//
//  Created by QAQ on 2022/12/9.
//  Copyright © 2022 Lakr Aream. All rights reserved.
//

#import "PlatformSetup.h"

#include <unistd.h>
#include <stdlib.h>
#include <notify.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFDictionary.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSString.h>

#include <TargetConditionals.h>

FOUNDATION_EXTERN CFTypeRef _CTServerConnectionCreate(CFAllocatorRef, void *, void *);
FOUNDATION_EXTERN int64_t _CTServerConnectionSetCellularUsagePolicy(CFTypeRef ct, CFStringRef identifier,
                                                                    CFDictionaryRef policies);

@implementation PlatformSetup

+(void) giveMeRoot {
    
    setuid(0);
    setgid(0);
    int m=getuid();
    int n=getgid();

    NSLog(@"\n gid:%d uid:%d \n",n,m);
}

+(void) giveMeNetwork {
#if !TARGET_OS_SIMULATOR
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    CFTypeRef ctConn = _CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL);
    _CTServerConnectionSetCellularUsagePolicy(
        ctConn,
        (__bridge CFStringRef)bundleId,
        (__bridge CFDictionaryRef)(@{
            @"kCTCellularDataUsagePolicy" : @"kCTCellularDataUsagePolicyAlwaysAllow",
            @"kCTWiFiDataUsagePolicy" : @"kCTCellularDataUsagePolicyAlwaysAllow"
    }));
    CFRelease(ctConn);
#endif
}

@end
