//
//  MainGameScene.h
//  Swinger
//
//  Created by James Sandoz on 4/23/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//


@interface MainGameScene : CCScene {
    CGSize screenSize;
    NSString *world;
    int level;
    BOOL currentlyShaking;
}

+ (MainGameScene *) sharedScene;
+ (id) nodeWithWorld:(NSString*)world level:(int)level;
- (void) shake: (float) shakeAmt duration: (float) duration;
- (void) levelComplete: (NSObject *) stats;

@property (nonatomic, readonly) NSString *world;
@property (nonatomic, readonly) int level;
@end
