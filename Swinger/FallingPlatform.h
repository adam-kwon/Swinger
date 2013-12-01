//
//  FallingPlatform.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/21/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FloatingPlatform.h"

@interface FallingPlatform : FloatingPlatform {
    
    CGPoint startPosition;
    BOOL    fell;
}

- (void) fall;

@property (nonatomic, readwrite, assign) BOOL fell;

@end
