//
//  GameLoadingScene.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCScene.h"

typedef enum {
    kGoToSceneMain,
    kGoToSceneWorldSelection,
    kGoToSceneLevelSelection,
    kGoToSceneGameStart,
    kGoToSceneGamePlay,
    kGoToSceneStore,
    kGoToSceneOptions,
} GoToScene;

@interface GameLoadingScene : CCScene {
    
    CGSize          screenSize;
    CCNode          *progressNode;
    CCProgressTimer *progressDonut;
    GoToScene        nextScene;
    NSString        *world;
    float            level;
    CCLabelBMFont   *loadingText;
}

+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene;
+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene world: (NSString*) worldName;
+ (id) nodeWithDelay: (float) delay goTo: (GoToScene) theNextScene world: (NSString*) worldName level: (float) theLevel;

@end
