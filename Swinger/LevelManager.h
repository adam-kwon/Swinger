//
//  LevelManager.h
//  Swinger
//
//  Created by James Sandoz on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface LevelManager : NSObject {
    NSArray *worlds;
}

- (NSArray *) getItemsForLevel:(int)level inWorld:(int)world;

@end
