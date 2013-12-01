//
//  Cloud.m
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

@synthesize speed;

- (void) dealloc {
    CCLOG(@"------------------------------- Cloud dealloc");
    [super dealloc];
}

@end
