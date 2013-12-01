//
//  StaticBackgroundLayer.h
//  Swinger
//
//  Created by James Sandoz on 4/23/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

@interface StaticBackgroundLayer : CCLayer {
    CGSize              screenSize;
    
    CCSpriteBatchNode   *batchNode;
    CCSprite            *background;

}

+ (StaticBackgroundLayer*) sharedLayer;

- (void) cleanupLayer;
- (void) initLayer;

@end
