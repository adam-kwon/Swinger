//
//  AchievementManager.m
//  Swinger
//
//  Created by James Sandoz on 9/6/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "AchievementManager.h"

#import <GameKit/GameKit.h>

#import "Achievement.h"
#import "GPGameCenter.h"

#define FILE_ACHIEVE_ARCHIVE            "SwingStarAchievements.archive"



@implementation AchievementManager

static AchievementManager* sharedInstance;

#pragma mark - Initialization
+(AchievementManager*) sharedInstance {
    CCLOG(@"AchievmeentManager sharedInstance\n");
    @synchronized([AchievementManager class]) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id) init {
    
    if ((self = [super init])) {
        [self loadAchievements];
        [self loadLeaderboards];
        
        sharedInstance = self;
    }
    
    return self;
}


- (void) reportScoreToGameCenter:(NSString*)key score:(int)scoreToReport {
    CCLOG(@"In reportScoreToGameCenter:%@ score:%d\n", key, scoreToReport);
    NSString *gameCenterId = [keyToLeaderboardIds objectForKey:key];
    if (gameCenterId == nil) {
        NSLog(@"ERROR: Tried to log unknown leaderboard, key=%@\n", key);
        return;
    }
    
    CCLOG(@"looked up gameCenterId: %@\n", gameCenterId);
    
    GKScore *score = [[[GKScore alloc] initWithCategory:gameCenterId] autorelease];
    score.value = scoreToReport;
    CCLOG(@"created score:%@\n", score);
    
    // send to gamecenter
    [[GPGameCenter sharedInstance] sendScore:score];
}


- (void) reportAchievementToGameCenter:(Achievement*)achievement {
    
    //CCLOG(@"In reportAchievementToGameCenter: %@ %@\n", achievement.key, achievement.gkAchievement);
    
    // persist the achievements
    [NSKeyedArchiver archiveRootObject:keyToAchievements toFile:@FILE_ACHIEVE_ARCHIVE];
    
    // report the achievement
    [[GPGameCenter sharedInstance] sendAchievement:achievement.gkAchievement];
}

- (Achievement *) getAchievementForKey:(NSString *)key {
    return [keyToAchievements objectForKey:key];
}


- (void) loadAchievements {
    
    // First try to load the persisted achievements
//    keyToAchievements = [[NSKeyedUnarchiver unarchiveObjectWithFile:@FILE_ACHIEVE_ARCHIVE] retain];
    
    //XXX need to handle case where achievements have changed?

    // achievements were not loaded, load them now
    if (keyToAchievements == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        // load the achievements from the plist
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"achievements" ofType:@"plist"];
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *plist = (NSDictionary*)
        [NSPropertyListSerialization propertyListFromData:plistXML 
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                                   format:&format 
                                         errorDescription:&errorDesc];
        
        if (!plist) {
            NSLog(@"**** Error reading achievements.plist: %@, format: %d", errorDesc, format);
        } else {
            for (NSString *key in [plist allKeys]) {
                NSString *id = [plist valueForKey:key];                    
                Achievement *ach = [[Achievement alloc] initForKey:key gameCenterId:id];
                [dict setObject:ach forKey:key];
            }
        }
        
        keyToAchievements = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
    }
}

- (void) loadLeaderboards {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // load the achievements from the plist
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Leaderboards" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *plist = (NSDictionary*)
    [NSPropertyListSerialization propertyListFromData:plistXML 
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                               format:&format 
                                     errorDescription:&errorDesc];
    
    if (!plist) {
        NSLog(@"**** Error reading Leaderboards.plist: %@, format: %d", errorDesc, format);
    } else {
        for (NSString *key in [plist allKeys]) {
            NSString *id = [plist valueForKey:key];            
            [dict setObject:id forKey:key];
        }
    }
    
    keyToLeaderboardIds = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];    
}

- (void) caughtRope {
    // return immediately if we've met all rope catching achieves
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_Catch25Ropes"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    // determine which achieve should be updated
    achievement = [keyToAchievements objectForKey:@"ACH_CatchARope"];
    float newPercent = 0;
    
    if (achievement.gkAchievement.percentComplete < 100) {
        // shot from cannon achievement met!
        newPercent = 100.f;
    } else {
        achievement = [keyToAchievements objectForKey:@"ACH_Catch5Ropes"];
        if (achievement.gkAchievement.percentComplete < 100) {
            newPercent = MIN(100, achievement.gkAchievement.percentComplete + 20);
        } else {
            achievement = [keyToAchievements objectForKey:@"ACH_Catch25Ropes"];
            if (achievement.gkAchievement.percentComplete < 100) {
                newPercent = MIN(100, achievement.gkAchievement.percentComplete + 4);
            }
        }
    }
    
    // if the percent was updated, report the achieve
    if (newPercent > 0) {
        achievement.gkAchievement.percentComplete = newPercent;
        [self reportAchievementToGameCenter:achievement];
    }}

- (void) shotFromCannon {
    // return immediately if we've met all cannon shooting achieves
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_ShotFrom25Cannons"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    // determine which achieve should be updated
    achievement = [keyToAchievements objectForKey:@"ACH_ShotFromCannon"];
    float newPercent = 0;
    
    if (achievement.gkAchievement.percentComplete < 100) {
        // shot from cannon achievement met!
        newPercent = 100.f;
    } else {
        achievement = [keyToAchievements objectForKey:@"ACH_ShotFrom5Cannons"];
        if (achievement.gkAchievement.percentComplete < 100) {
            newPercent = MIN(100, achievement.gkAchievement.percentComplete + 20);
        } else {
            achievement = [keyToAchievements objectForKey:@"ACH_ShotFrom25Cannons"];
            if (achievement.gkAchievement.percentComplete < 100) {
                newPercent = MIN(100, achievement.gkAchievement.percentComplete + 4);
            }
        }
    }
    
    // if the percent was updated, report the achieve
    if (newPercent > 0) {
        achievement.gkAchievement.percentComplete = newPercent;
        [self reportAchievementToGameCenter:achievement];
    }
}

- (void) killedInsect {
    // return immediately if we've met all cannon shooting achieves
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_Killed25Insects"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    // determine which achieve should be updated
    achievement = [keyToAchievements objectForKey:@"ACH_KilledInsect"];
    float newPercent = 0;
    
    if (achievement.gkAchievement.percentComplete < 100) {
        // shot from cannon achievement met!
        newPercent = 100.f;
    } else {
        achievement = [keyToAchievements objectForKey:@"ACH_Killed5Insects"];
        if (achievement.gkAchievement.percentComplete < 100) {
            newPercent = MIN(100, achievement.gkAchievement.percentComplete + 20);
        } else {
            achievement = [keyToAchievements objectForKey:@"ACH_Killed25Insects"];
            if (achievement.gkAchievement.percentComplete < 100) {
                newPercent = MIN(100, achievement.gkAchievement.percentComplete + 4);
            }
        }
    }
    
    // if the percent was updated, report the achieve
    if (newPercent > 0) {
        achievement.gkAchievement.percentComplete = newPercent;
        [self reportAchievementToGameCenter:achievement];
    }
}


- (void) killedByInsect {
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_KilledByInsect"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    achievement.gkAchievement.percentComplete = 100;
    [self reportAchievementToGameCenter:achievement];
}

- (void) killedBySaw {
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_KilledBySaw"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    achievement.gkAchievement.percentComplete = 100;
    [self reportAchievementToGameCenter:achievement];
}

- (void) killedByBoulder {
    Achievement *achievement = [keyToAchievements objectForKey:@"ACH_KilledByBoulder"];
    if (achievement.gkAchievement.percentComplete >= 100)
        return;
    
    achievement.gkAchievement.percentComplete = 100;
    [self reportAchievementToGameCenter:achievement];
}

- (void) dealloc {
    [keyToAchievements release];
    [keyToLeaderboardIds release];
    
    [super dealloc];
}


@end
