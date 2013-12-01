//
//  GPGameCenter.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 4/20/12.
//  Copyright (c) 2012 GAMEPEONS LLC. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface GPGameCenter : NSObject {
    BOOL isGameCenterAvailable;
    BOOL isUserAuthenticated;
    
    NSMutableArray *unreportedAchievements;
    NSMutableArray *unreportedScores;
    
}

+ (GPGameCenter*) sharedInstance;

- (BOOL) isGameCenterAvailable;
- (void) authenticationChanged;
- (void) authenticateLocalUser;

- (void) sendAchievement:(GKAchievement *)achievement;
- (void) sendScore:(GKScore*)score;


@end
