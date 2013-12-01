//
//  CatcherGameObject.h
//  Swinger
//
//  Created by Min Kwon on 6/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PhysicsObject.h"

@protocol CatcherGameObject 

- (int) getIndexInLevelObjects;
- (void) setIndexInLevelObjects:(int)index;
- (float) distanceToNextCatcher;
- (void) setLevelObjects:(NSArray*)currentLevelObjects;
- (NSArray*) getLevelObjects;
- (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) getNextCatcherGameObject;
- (void) setCollideWithPlayer:(BOOL)doCollide;
- (CGPoint) getCatchPoint; // localized position where player will be caught
- (float) getHeight;
- (void) setSwingerVisible:(BOOL)visible;
@end
