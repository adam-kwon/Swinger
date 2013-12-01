//
//  SkyLayer.h
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@class StarsFirework;

@interface SkyLayer : CCLayer {
    CGSize              screenSize;
    CCArray             *clouds;
    CCArray             *streaks;
    CCNode              *celestialBodyHolder;
    CCSprite            *celestialBody;

    StarsFirework       *fireWork;
    int                 fireWorkCount;
    int                 numFireWorksToPlay;
    float               speedFactor;

    CCSpriteBatchNode   *batchNode;
}

+ (SkyLayer*) sharedLayer;
- (void) cleanupLayer;
- (void) zoomBy: (float) scaleAmount;
- (void) scaleBy: (float)scaleAmount duration:(ccTime)duration;
- (void) showFireWork;
- (void) scrollUp:(float)dy;
- (void) startSpeedStreaks:(float)speedFactor;
- (void) stopSpeedStreaks;

@end
