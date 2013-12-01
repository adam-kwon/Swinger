//
//  Block.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FloatingPlatform.h"

@interface FloatingBlock : FloatingPlatform {
    
    BOOL breakApart;
    NSMutableArray * particles;
}

@end
