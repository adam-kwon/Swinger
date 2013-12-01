//
//  MainMenuScene.h
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <GameKit/GameKit.h>

@class MainGameScene;

@class GPImageButton;

@interface MainMenuScene : CCScene<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    
    CGSize screenSize;
    
    GPImageButton *gameCenter;
    
    // normal menu buttons
    NSArray *mainMenuButtons;
    
    // gamecenter menu buttons
    NSArray *gameCenterMenuButtons;
}

@end
