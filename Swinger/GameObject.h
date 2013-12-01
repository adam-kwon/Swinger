//
//  GameObject.h
//  SwingProto
//
//  Created by James Sandoz on 3/19/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Constants.h"

@protocol GameObject

- (GameObjectType) gameObjectType;
- (void) updateObject:(ccTime)dt scale:(float)scale;
- (BOOL) isSafeToDelete;
- (void) safeToDelete;

- (void) show;
- (void) hide;

- (void) reset; // some objects need to be reset on restart

@property (readwrite, nonatomic, assign) int gameObjectId;

@end
