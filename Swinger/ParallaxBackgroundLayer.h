//
//  ParallaxBackgroundLayer.h
//  Swinger
//
//  Created by Isonguyo Udoka on 5/19/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCLayer.h"

@class LevelItem;

@interface ParallaxBackgroundLayer : CCLayer {
    
    BOOL            pauseScroll;
    CGSize          screenSize;
    
    CCNode          *frontParallax;
    CCNode          *frontAccent; // accents for front parallax like torch light fire
    CCNode          *hillParallax;
    CCNode          *backParallax;
    CCNode          *groundHolder;
    CCSprite        *ground; // ground is statically added to parallax layer and does not scroll but scales (y axis only) itself on zoom
    
    float           frontScale;
    float           hillScale;
    float           backScale;
    
    CCArray         *foregroundObjects; // Foreground objects from level manager
    CCArray         *crows;
    CCArray         *flags;
    CCArray         *balloons;
    CCArray         *torchFires;
    
    float           gamePlayHeight;
}

+ (ParallaxBackgroundLayer*) sharedLayer;

- (void) initParallaxLayers;
- (void) initLayer;
- (void) cleanupLayer:(BOOL)forNextLevel;
- (void) scrollXBy:(float)scrollXAmount YBy:(float)scrollYAmount;
- (void) zoomBy: (float) scaleAmount;
- (void) scaleBy: (float)scaleAmount duration:(ccTime)duration;
- (void) addToForegroundObjectsList:(LevelItem*)node;

@end
