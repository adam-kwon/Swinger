//
//  IAPData.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/22/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "IAPData.h"
#import "IAP.h"
#import "UserData.h"
#import "GPUtil.h"
//#import "FlurryAnalytics.h"
//#import "FlurryConstants.h"

@implementation IAPData
- (void) dealloc {
    [iapDict release];
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        
        plistPath = [[NSBundle mainBundle] pathForResource:@"iap" ofType:@"plist"];
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *plist = (NSDictionary*) [NSPropertyListSerialization propertyListFromData:plistXML 
                                                                               mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                                                                         format:&format 
                                                                               errorDescription:&errorDesc];
        if (!plist) {
            NSLog(@"**** Error reading iap.plist: %@, format: %d", errorDesc, format);
        }
        
        iapDict = [[NSMutableDictionary alloc] init];
        
        NSEnumerator *keys = [plist keyEnumerator];
        NSString *key;
        while ((key = [keys nextObject])) {        
            NSDictionary *item = [plist objectForKey:key];
            IAP *iap = [[IAP alloc] init];
            iap.productId = key;
            //iap.productId = @"com.gamepeons.apocalypse2012.1000lives;
            iap.desc = [item objectForKey:@"desc"];
            iap.price = [item objectForKey:@"price"];
            iap.sortOrder = [((NSNumber*)[item objectForKey:@"sortOrder"]) intValue];
            [iapDict setObject:iap forKey:key];
            [iap release];
            CCLOG(@"**** Adding iap %@=%@", iap.desc, iap.price);
        }
    }
    
    return self;
}

NSInteger sortIAP(id obj1, id obj2, void *context) {
    int n1 = -1;
    int n2 = -1;
    
    if ([obj1 isKindOfClass:[IAP class]] && [obj2 isKindOfClass:[IAP class]]) {
        n1 = [obj1 sortOrder];
        n2 = [obj2 sortOrder];
    }
    
    if (n1 < n2) return NSOrderedAscending;
    else if (n1 > n2) return NSOrderedDescending;
    else return NSOrderedSame;
}

- (NSArray*) getProducts {
    NSArray *keys = [iapDict allValues];
    NSArray *sortedArray = [keys sortedArrayUsingFunction:sortIAP context:NULL];    
    return sortedArray;
}

- (IAP*) getIAP:(NSString*)productId {
    return [iapDict objectForKey:productId];
}


- (void) purchasedIAP:(NSString*)productId {
    NSDictionary *flurryParam = nil;
    
//    if ([IAP_1000_SURVIVORS isEqualToString:productId]) {
//        [UserData sharedInstance].totalSurvivorsSaved += 1000;
//        flurryParam = [NSDictionary  dictionaryWithObjectsAndKeys:@"1000 lives", @"IAP", nil];
//    } else if ([IAP_3000_SURVIVORS isEqualToString:productId]) {
//        [UserData sharedInstance].totalSurvivorsSaved += 3000;
//        flurryParam = [NSDictionary  dictionaryWithObjectsAndKeys:@"3000 lives", @"IAP", nil];
//    } else if ([IAP_6000_SURVIVORS isEqualToString:productId]) {
//        [UserData sharedInstance].totalSurvivorsSaved += 6000;
//        flurryParam = [NSDictionary  dictionaryWithObjectsAndKeys:@"6000 lives", @"IAP", nil];
//    } else if ([IAP_20000_SURVIVORS isEqualToString:productId]) {
//        [UserData sharedInstance].totalSurvivorsSaved += 20000;
//        flurryParam = [NSDictionary  dictionaryWithObjectsAndKeys:@"20000 lives", @"IAP", nil];
//    }  
//    
//    if ([UserData sharedInstance].userHasBoughtSomething == NO) {
//        [UserData sharedInstance].userHasBoughtSomething = YES;
//        [FlurryAnalytics logEvent:FLURRY_EVENT_UNIQUE_PAYING_USER];
//    }
//    
//    if (flurryParam != nil) {
//        [FlurryAnalytics logEvent:FLURRY_EVENT_PURCHASE_MADE withParameters:flurryParam];
//    }
    
    [[UserData sharedInstance] persist];
}

@end
