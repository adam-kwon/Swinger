//
//  DeviceDetection.m
//  Scroller
//
//  Created by min on 3/9/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "DeviceDetection.h"

@implementation DeviceDetection

+ (DeviceType) detectDevice {
    NSString *model= [[UIDevice currentDevice] model];
    struct utsname u;
	uname(&u);
	
    CCLOG(@"**** u.machine = %s", u.machine);
    if (!strncmp(u.machine, "iPhone1,1", 7)) {
		return MODEL_IPHONE;
	} else if (!strncmp(u.machine, "iPhone1,2", 7)){
		return MODEL_IPHONE_3G;
	} else if (!strncmp(u.machine, "iPhone2,1", 7)){
		return MODEL_IPHONE_3GS;
	} else if (!strncmp(u.machine, "iPhone3,1", 7)){
		return MODEL_IPHONE_4;
	} else if (!strncmp(u.machine, "iPhone4,1", 7)) {
        return MODEL_IPHONE_4S;
    } else if (!strncmp(u.machine, "iPhone5,1", 7)) {
        return MODEL_IPHONE_5;
    } else if (!strncmp(u.machine, "iPod1,1", 5)){
		return MODEL_IPOD_TOUCH_GEN1;
	} else if (!strncmp(u.machine, "iPod2,1", 5)){
		return MODEL_IPOD_TOUCH_GEN2;
	} else if (!strncmp(u.machine, "iPod3,1", 5)){
		return MODEL_IPOD_TOUCH_GEN3;
	} else if (!strncmp(u.machine, "iPod4,1", 5)) {
      return MODEL_IPOD_TOUCH_GEN4;  
    } else if (!strncmp(u.machine, "iPad1,1", 5)){
		return MODEL_IPAD;
	} else if (!strncmp(u.machine, "iPad2,1", 5)) {
        return MODEL_IPAD2;
    } else if (!strncmp(u.machine, "iPad3,3", 5)) {
        return MODEL_IPAD3;
    } else if (!strcmp(u.machine, "i386") || !strcmp(u.machine, "x86_64")){
		//NSString *iPhoneSimulator = @"iPhone Simulator";
		NSString *iPadSimulator = @"iPad Simulator";
		if([model compare:iPadSimulator] == NSOrderedSame)
			return MODEL_IPAD_SIMULATOR;
		else
			return MODEL_IPHONE_SIMULATOR;
	}
	else {
		return MODEL_UNKNOWN;
	}
}

+ (BOOL) isIpad {
    if ([DeviceDetection detectDevice] == MODEL_IPAD
        || [DeviceDetection detectDevice] == MODEL_IPAD_SIMULATOR) {
        return YES;
    }
    return NO;
}

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator {
    NSString *returnValue = @"Unknown";
	
    switch ([DeviceDetection detectDevice])	{
        case MODEL_IPHONE_SIMULATOR:
			returnValue = @"iPhone Simulator";
			break;
		case MODEL_IPOD_TOUCH_GEN1:
			returnValue = @"iPod Touch 1st";
			break;
		case MODEL_IPOD_TOUCH_GEN2:
			returnValue = @"iPod Touch 2nd";
			break;
		case MODEL_IPOD_TOUCH_GEN3:
			returnValue = @"iPod Touch 3rd";
			break;
        case MODEL_IPOD_TOUCH_GEN4:
            returnValue = @"iPod Touch 4th";
            break;
		case MODEL_IPHONE:
			returnValue = @"iPhone";
			break;
		case MODEL_IPHONE_3G:
			returnValue = @"iPhone 3G";
			break;
		case MODEL_IPHONE_3GS:
			returnValue = @"iPhone 3GS";
			break;
		case MODEL_IPHONE_4:
			returnValue = @"iPhone 4";
			break;
        case MODEL_IPHONE_4S:
            returnValue = @"iPhone 4S";
            break;
		case MODEL_IPAD:
			returnValue = @"iPad";
			break;
        case MODEL_IPAD2:
            returnValue = @"iPad2";
            break;
        case MODEL_IPAD3:
            returnValue = @"iPad3";
            break;
		default:
			break;
	}
	
	return returnValue;
}

+ (NSString*) uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [(NSString*)uuidStringRef autorelease];
}

@end