//
//  UserData.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 6/13/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "UserData.h"
#import "Constants.h"

#define PER_KEY_FX_VOLUME                                       @"gamepeons_swinger_1"
#define PER_KEY_MUSIC_VOLUME                                    @"gamepeons_swinger_2"
#define PER_KEY_CUSTOM_MUSIC                                    @"gamepeons_swinger_3"
#define PER_KEY_PLAYLIST                                        @"gamepeons_swinger_4"
#define PER_KEY_GAME_VERSION                                    @"gamepeons_swinger_5"
#define PER_KEY_DEVICE_ID                                       @"gamepeons_swinger_6"

#define PER_KEY_PLAYER_SKIN                                     @"gamepeons_swinger_7"
#define PER_KEY_POWER_UPS                                       @"gamepeons_swinger_8"

#define PER_KEY_WORLD_LEVELS                                    @"gamepeons_swinger_9"
#define PER_KEY_TOTAL_COINS                                     @"gamepeons_swinger_10"
#define PER_KEY_TOTAL_STARS                                     @"gamepeons_swinger_11"
#define PER_KEY_HIGH_SCORES                                     @"gamepeons_swinger_12"
#define PER_KEY_BEST_TIMES                                      @"gamepeons_swinger_13"

#define PER_KEY_WORLDS                                          @"gamepeons_swinger_14"

@interface UserData(Private)
@end

@implementation UserData

@synthesize device;
@synthesize profile;
@synthesize isCustomMusic;
@synthesize fxVolumeLevel;
@synthesize musicVolumeLevel;
@synthesize reduceVolume;
@synthesize playList;
@synthesize gameVersion;
@synthesize date;
@synthesize deviceId;

@synthesize playerType;

@synthesize totalCoins;
@synthesize totalLives;
@synthesize unlimitedCoinDoubler;

@synthesize currentCoins;
@synthesize currentStars;
@synthesize currentScore;
@synthesize currentTime;

@synthesize landingBonus;
@synthesize perfectJumpCount;
@synthesize imperfectJumpCount;
@synthesize restartCount;
@synthesize skipCount;

static const int levelsPerWorld = 16;
static UserData *sharedInstance;

+ (UserData*) sharedInstance {
	NSAssert(sharedInstance != nil, @"UserData instance not yet initialized!");
	return sharedInstance;
}

- (void) dealloc {
    
    [levels release];
    [highScores release];
    [bestTimes release];
    
    [super dealloc];
}


- (id)init {
    if ((self = [super init])) {
        sharedInstance = self;
        reduceVolume = NO;
        totalCoins = 2000;
    }
    
    return self;
}

- (void) savePlayList:(MPMediaItemCollection *)collection {
    NSArray *items = [collection items];
    NSMutableArray *listToSave = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
    for (MPMediaItem *song in items) {
        if (i++ > 20) {
            break;
        }
        NSNumber *persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
        [listToSave addObject:persistentId];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:listToSave];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PER_KEY_PLAYLIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadPlayList {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_PLAYLIST];
    if (nil != data) {
        NSMutableArray *theList = [NSMutableArray arrayWithCapacity:1];
        NSArray *decodedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [theList addObjectsFromArray:decodedData];
        NSMutableArray *allTheSongs = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i < [theList count]; i++) {
            MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
            [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[theList objectAtIndex:i] forProperty:MPMediaItemPropertyPersistentID]];
            NSArray *songs = [songQuery items];
            [allTheSongs addObjectsFromArray:songs];
        }
        //playList = [[MPMediaItemCollection alloc] initWithItems:allTheSongs];
        if (nil != allTheSongs && [allTheSongs count] > 0) {
            playList = [MPMediaItemCollection collectionWithItems:allTheSongs];
        }

    } else {
        playList = nil;
    }    
}

- (BOOL) getBOOL:(NSString*)key {
    BOOL r = NO;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str != nil) {
        if ([@"YES" isEqualToString:str]) {
            r = YES;
        }
    }
    return r;
}

- (void) setBool:(BOOL)flag ForKey:(NSString*)key  {
    if (flag) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:key];            
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:key];            
    }
}


- (float) getFloat:(NSString*)key withDefault:(float)d {
    float v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        v = [str floatValue];
    }
    return v;
}

- (float) getInt:(NSString*)key withDefault:(int)d {
    int v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        v = [str intValue];
    }
    return v;
}

- (NSString*) getNSString:(NSString*)key {
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        str = [DeviceDetection uuid];
    }
    
    return str;
}

- (float) getUnsignedLong:(NSString*)key withDefault:(unsigned long)d {
    unsigned long v;
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (str == nil) {
        v = d;
    } else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        v = [[formatter numberFromString:str] unsignedLongValue];
        [formatter release];
    }
    return v;
}


- (void) readOptionsFromDisk {
    gameVersion = [[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_GAME_VERSION];
        
    self.deviceId = [self getNSString:PER_KEY_DEVICE_ID];
    isCustomMusic = [self getBOOL:PER_KEY_CUSTOM_MUSIC];
    fxVolumeLevel = [self getFloat:PER_KEY_FX_VOLUME withDefault:1.0f];
    musicVolumeLevel = [self getFloat:PER_KEY_MUSIC_VOLUME withDefault:0.5f];
    
    playerType = [self getInt:PER_KEY_PLAYER_SKIN withDefault:kPlayerTypeGonzo];
    
    levels = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_WORLD_LEVELS];
    highScores = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_HIGH_SCORES];
    bestTimes = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_BEST_TIMES];
    powerUpsPurchased = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:PER_KEY_POWER_UPS];
    worldsPurchased = (NSMutableArray*)[[NSUserDefaults standardUserDefaults]
        objectForKey:PER_KEY_WORLDS];
    
    if (levels == nil) {
        levels = [[NSMutableDictionary alloc] init];
    }
    
    if (highScores == nil) {
        highScores = [[NSMutableDictionary alloc] init];
    }
    
    if (bestTimes == nil) {
        bestTimes = [[NSMutableDictionary alloc] init];
    }
    
    if (powerUpsPurchased == nil) {
        powerUpsPurchased = [[NSMutableArray alloc] init];
    }
    
    if (worldsPurchased == nil) {
        worldsPurchased = [[NSMutableArray alloc] init];
    }
    
    device = [DeviceDetection detectDevice];
    switch (device) {
        case MODEL_IPHONE_SIMULATOR:
        case MODEL_IPOD_TOUCH_GEN3:
        case MODEL_IPOD_TOUCH_GEN4:
        case MODEL_IPHONE_3GS:
        case MODEL_IPHONE_4:
        case MODEL_IPHONE_4S:            
            profile = kPerformanceHigh;
            break;           
        case MODEL_IPAD_SIMULATOR:
        case MODEL_IPAD:
        case MODEL_IPAD2:
        case MODEL_IPAD3:
            profile = kPerformanceHigh;
            break;
        case MODEL_IPOD_TOUCH_GEN2:
            profile = kPerformanceMedium;
            break;
        case MODEL_IPHONE:
        case MODEL_IPHONE_3G:
        case MODEL_IPOD_TOUCH_GEN1:
            profile = kPerformanceLow;
            break;
        default:
            profile = kPerformanceHigh;
            break;
    }
}

- (void) purchaseWorld: (NSString *) name cost:(unsigned int) cost {
    
    if (totalCoins >= cost) {
        
        totalCoins -= cost;
        
        [worldsPurchased addObject:name];
    }
}

- (BOOL) isWorldPurchased:(NSString *)world {
    
    return [worldsPurchased containsObject: world];
}

- (void) purchasePowerUp: (NSString *) name type:(unsigned int) type cost:(unsigned int) cost {
    
    if (totalCoins >= cost) {
    
        totalCoins -= cost;
        
        NSMutableString * uniqueId = [NSMutableString stringWithString:name];
        [uniqueId appendFormat:@"-%d", type];
        
        [powerUpsPurchased addObject:uniqueId];
    }
}

- (BOOL) isPowerUpPurchased: (NSString *) name type: (unsigned int) type {
    
    NSMutableString * uniqueId = [NSMutableString stringWithString:name];
    [uniqueId appendFormat:@"-%d", type];
    
    return [powerUpsPurchased containsObject: uniqueId];
}

- (void) purchasePlayerSkin: (NSString *) name type:(unsigned int) type cost:(unsigned int) cost {
    
    if (totalCoins >= cost) {
        
        totalCoins -= cost;
        
        NSMutableString * uniqueId = [NSMutableString stringWithString:name];
        [uniqueId appendFormat:@"-%d", type];
        
        [playerSkinsPurchased addObject:uniqueId];
    }
}

- (BOOL) isPlayerSkinPurchased: (NSString *) name type: (unsigned int) type {
    
    NSMutableString * uniqueId = [NSMutableString stringWithString:name];
    [uniqueId appendFormat:@"-%d", type];
    
    return [playerSkinsPurchased containsObject: uniqueId];
}

- (unsigned int) getNumLevelsCompleted {
    unsigned int levelsCompleted = 0;
    
    for (id worldLevel in [levels allValues]) {
        
        if (worldLevel != nil) {
            unsigned int level = [worldLevel unsignedIntValue];
            
            if (level > 0) {
                level--;
            }
            
            levelsCompleted += level;
        }
    }
    
    //CCLOG(@"-----Num Levels Completed: %d-----", levelsCompleted);
    return levelsCompleted;
}

- (void) purchaseLives: (unsigned int) numLives cost: (unsigned int) cost {
    
    if (totalCoins >= cost) {
        totalLives += numLives;
        totalCoins -= cost;
    }
}

- (unsigned int) getLevel: (NSString*) world {
    
    id worldLevel = [levels valueForKey: world];
    unsigned int level = 1;
    
    if ( worldLevel != nil ) {
        
        level = [worldLevel unsignedIntValue];
    }
    
    return level;
}

- (BOOL) setLevel: (NSString*) world level: (unsigned int) level {

    if (level > [self getLevel:world]) {
        // make sure level is greater than our current high level
        [levels setValue:[NSNumber numberWithUnsignedInt: level] forKey:world];
        return YES;
    }
    
    return NO;
}

- (BOOL) isHighScore: (NSString *) world level: (unsigned int) level {
    
    return currentScore > [self getHighScore:world level:level];
}

- (unsigned long) getHighScore: (NSString*) world level: (unsigned int) level {
    
    id worldScore = [highScores valueForKey:[self getWorldLevelKey:world level:level]];
    unsigned long score = 0;
    
    if ( worldScore != nil ) {
        
        score = [worldScore unsignedLongValue];
    }
    
    return score;
}

- (void) setHighScore: (NSString*) world level: (unsigned int) level {

    // double check the high score
    if ([self isHighScore:world level:level]) {
        [highScores setValue:[NSNumber numberWithUnsignedLong:currentScore] forKey: [self getWorldLevelKey: world level: level]];
    }
}

- (unsigned long) getBestTime: (NSString*) world level: (unsigned int) level {
    
    id worldTime = [bestTimes valueForKey:[self getWorldLevelKey:world level:level]];
    unsigned long time = 0;
    
    if ( worldTime != nil ) {
        
        time = [worldTime unsignedLongValue];
    }
    
    return time;
}

- (void) setBestTime: (NSString*) world level: (unsigned int) level {
    // double check the best time
    if ([self isBestTime:world level:level]) {
        [bestTimes setValue:[NSNumber numberWithUnsignedLong:currentTime] forKey: [self getWorldLevelKey: world level: level]];
    }
}

- (BOOL) isBestTime: (NSString *) world level: (unsigned int) level {
    // check given time against dictionary value
    unsigned long bestTime = [self getBestTime: world level: level];
    
    return bestTime == 0 || currentTime < bestTime;
}

- (NSString *) getWorldLevelKey: (NSString *) world level: (unsigned int) level {
    return [NSString stringWithFormat:@"%@%d", world, level];
}

- (void) persist {
    [self setBool:isCustomMusic ForKey:PER_KEY_CUSTOM_MUSIC];    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", playerType] forKey:PER_KEY_PLAYER_SKIN];           

    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", deviceId] forKey:PER_KEY_DEVICE_ID];            
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", fxVolumeLevel] forKey:PER_KEY_FX_VOLUME];            
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", musicVolumeLevel] forKey:PER_KEY_MUSIC_VOLUME];     
    
    // TODO: Persist other user data elements
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
