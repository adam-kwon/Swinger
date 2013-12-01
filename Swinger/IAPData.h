//
//  IAPData.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/22/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

//#define IAP_1000_SURVIVORS      @"com.gamepeons.apocalypse2012.1000lives"
//#define IAP_3000_SURVIVORS      @"com.gamepeons.apocalypse2012.3000lives"
//#define IAP_6000_SURVIVORS      @"com.gamepeons.apocalypse2012.5000lives"
//#define IAP_20000_SURVIVORS     @"com.gamepeons.apocalypse2012.5000lives"


#define IAP_1000_SURVIVORS                  @"com.chillingo.2012AD.1000lives"
#define IAP_3000_SURVIVORS                  @"com.chillingo.2012AD.3000lives"
#define IAP_6000_SURVIVORS                  @"com.chillingo.2012AD.6000lives"
#define IAP_20000_SURVIVORS                 @"com.chillingo.2012AD.20000lives"

@class IAP;

@interface IAPData : NSObject {
    NSMutableDictionary         *iapDict;
}

- (IAP*) getIAP:(NSString*)productId;
- (NSArray*) getProducts;

- (void) purchasedIAP:(NSString*)productId;

@end
