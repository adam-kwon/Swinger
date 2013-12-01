//
//  TouchSkyLayer.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/11/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchCloudLayer : CCLayer {
    CGSize              screenSize;
    CCSprite            *clouds;
    
    CGPoint             cappedPos;
    float               cloudScale;
    float               currHeight;
    float               prevHeight;
    BOOL                scrolledToStart;
    BOOL                touchCloudReported;
    
    CCArray             *streaks;
    float               speedFactor;
}

+ (TouchCloudLayer*) sharedLayer;
- (void) initLayer;
- (void) startSpeedStreaks:(float)speedFactor;
- (void) stopSpeedStreaks;
- (void) cleanupLayer;

@end
