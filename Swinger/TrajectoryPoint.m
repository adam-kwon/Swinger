//
//  TrajectoryPoint.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/23/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "TrajectoryPoint.h"
#import "Constants.h"

@implementation TrajectoryPoint

- (id) initDot {
    self = [super init];
    if (self) {
        
        /*ccColor3B inColor = CC3_COLOR_BLUE;
        ccColor3B outColor = CC3_COLOR_WHITE;
        
        CCLayerColor *dot = [CCLayerColor layerWithColor:ccc4(inColor.r, inColor.g, inColor.b, 255) width:ssipadauto(4) height:ssipadauto(4)];
        CCLayerColor *outline = [CCLayerColor layerWithColor:ccc4(outColor.r, outColor.g, outColor.b, 255) width:ssipadauto(2) height:ssipadauto(2)];
        
        outline.position = ccp(ssipadauto(1),ssipadauto(1));
        
        [dot addChild: outline];*/
        
        //CCSprite *dot = [CCSprite spriteWithFile:@"whiteDot.png"];
        //CCLabelBMFont *dot = [CCLabelBMFont labelWithString:@"." fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32)];
        CCSprite * dot = [CCSprite spriteWithSpriteFrameName:@"TrajectoryDot.png"];
        dot.anchorPoint = ccp(0,0);
        
        [self addChild:dot];
    }
    return self;
}

+ (id) make {
    return [[[self alloc] initDot] autorelease];
}

/*-(void) setScaleX: (float)newScaleX
{
    CCLOG(@"DISABLED SCALING ON TRAJECTORY POINT!");
    [super setScaleX:1];
}

-(void) setScaleY: (float)newScaleY
{
    CCLOG(@"DISABLED SCALING ON TRAJECTORY POINT!");
    [super setScaleY:1];
}

-(void) setScale:(float) s
{
    CCLOG(@"DISABLED SCALING ON TRAJECTORY POINT!");
    [super setScale:1];
}*/

@end
