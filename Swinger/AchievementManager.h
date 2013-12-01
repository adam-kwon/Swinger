//
//  AchievementManager.h
//  Swinger
//
//  Created by James Sandoz on 9/6/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Achievement;

@interface AchievementManager : NSObject {
    
    NSDictionary *keyToAchievements;
    NSDictionary *keyToLeaderboardIds;
    
}

+(AchievementManager*) sharedInstance;

- (void) reportScoreToGameCenter:(NSString*)key score:(int)scoreToReport;

- (void) caughtRope;
- (void) shotFromCannon;
- (void) killedInsect;

- (void) killedByInsect;
- (void) killedBySaw;
- (void) killedByBoulder;

- (Achievement *) getAchievementForKey:(NSString *)key;

@end
