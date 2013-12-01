//
//  CCLayerColor+extension.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/14/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

@interface CCLayerColor (extension)
+ (id) lineAtY:(float)y;
+ (id) lineAtY:(float)y withWidth:(float)width andColor:(ccColor4B)color;
+ (id) lineAtY:(float)y withWidth:(float)width height:(float)height andColor:(ccColor4B)color;
+ (id) getFullScreenLayerWithColor:(ccColor4B)color;
+ (id) getFullScreenLayerWithColor:(ccColor4B)color ofScreenLength:(int)length;
@end
