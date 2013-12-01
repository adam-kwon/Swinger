//
//  DeviceDetection.h
//  Scroller
//
//  Created by min on 3/9/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import <sys/utsname.h>

@interface DeviceDetection : NSObject

typedef enum {
    MODEL_UNKNOWN=0,/**< unknown model */
    MODEL_IPHONE_SIMULATOR,/**< iphone simulator */
    MODEL_IPAD_SIMULATOR,/**< ipad simulator */
    MODEL_IPAD3_SIMULATOR,
    MODEL_IPOD_TOUCH_GEN1,/**< ipod touch 1st Gen */
    MODEL_IPOD_TOUCH_GEN2,/**< ipod touch 2nd Gen */
    MODEL_IPOD_TOUCH_GEN3,/**< ipod touch 3th Gen */
    MODEL_IPOD_TOUCH_GEN4,
    MODEL_IPHONE,/**< iphone  */
    MODEL_IPHONE_3G,/**< iphone 3G */
    MODEL_IPHONE_3GS,/**< iphone 3GS */
    MODEL_IPHONE_4,	/**< iphone 4 */
    MODEL_IPHONE_4S, /**< iPhone 4S */
    MODEL_IPHONE_5,
	MODEL_IPAD,/** ipad  */
    MODEL_IPAD2,
    MODEL_IPAD3
} DeviceType;

+ (DeviceType) detectDevice;
+ (NSString*) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIpad;
+ (NSString*) uuid;
@end

