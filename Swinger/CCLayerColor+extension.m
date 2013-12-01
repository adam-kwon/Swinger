//
//  CCLayerColor+extension.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/14/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "CCLayerColor+extension.h"

@implementation CCLayerColor(extension)

+ (id) lineAtY:(float)y {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    return [CCLayerColor lineAtY:y withWidth:screenSize.width height:1 andColor:ccc4(160, 160, 160, 255)];    
}

+ (id) lineAtY:(float)y withWidth:(float)width andColor:(ccColor4B)color {
    return [CCLayerColor lineAtY:y withWidth:width height:1 andColor:color];
}

+ (id) lineAtY:(float)y withWidth:(float)width height:(float)height andColor:(ccColor4B)color {
    CCLayerColor *layer = [CCLayerColor layerWithColor:color];
    [layer setContentSize:CGSizeMake(width, height)];
    layer.position = ccp(0, y);
    return layer;    
}

+ (id) getFullScreenLayerWithColor:(ccColor4B)color ofScreenLength:(int)length {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCLayerColor *layer = [CCLayerColor layerWithColor:color];
    [layer setContentSize:CGSizeMake(screenSize.width*length, screenSize.height)];
    layer.position = ccp(0, 0);
    return layer;    
}

+ (id) getFullScreenLayerWithColor:(ccColor4B)color {
    return [self getFullScreenLayerWithColor:color ofScreenLength:1];
}

@end
