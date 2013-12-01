//
//  Achievement.h
//  Swinger
//
//  Created by James Sandoz on 9/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface Achievement : NSObject<NSCoding> {
    NSString *key;
    GKAchievement *gkAchievement;
}

-(id) initForKey:(NSString *)theKey gameCenterId:(NSString *)gcId;

@property (nonatomic, readwrite, assign) NSString *key;
@property (nonatomic, readwrite, assign) GKAchievement *gkAchievement;

@end
