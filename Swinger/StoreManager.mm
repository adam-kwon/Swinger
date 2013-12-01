//
//  StoreManager.m
//  Swinger
//
//  Created by Isonguyo Udoka on 9/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreManager.h"
#import "PowerUpData.h"
#import "PlayerSkinData.h"
#import "LifeLineData.h"
#import "BankData.h"
#import "WorldData.h"

@interface StoreManager(Private)
@end

@implementation StoreManager

@synthesize worldData;
@synthesize playerSkinData;
@synthesize powerUpData;
@synthesize lifeLineData;
@synthesize bankData;
@synthesize newItemUnlocked;

static StoreManager *sharedInstance;

+ (StoreManager*) sharedInstance {
	NSAssert(sharedInstance != nil, @"StoreManager instance not yet initialized!");
	return sharedInstance;
}

- (id) init {
    
    if ((self = [super init])) {
        sharedInstance = self;
        [self initStoreData];
    }
    
    return self;
}

- (void) initStoreData {
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    
    plistPath = [[NSBundle mainBundle] pathForResource:@"store" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *plist = (NSDictionary*)
    [NSPropertyListSerialization propertyListFromData:plistXML 
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                               format:&format 
                                     errorDescription:&errorDesc];
    if (!plist) {
        NSLog(@"**** Error reading store.plist: %@, format: %d", errorDesc, format);
    }
    
    NSArray *storeData = [[plist allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *storeDataType in storeData) {
        
        if ([@"Worlds" isEqualToString:storeDataType]) {
            
            NSDictionary *worlds = [plist objectForKey:storeDataType];
            [self initWorlds: worlds];
        } else if ([@"PlayerSkins" isEqualToString:storeDataType]) {
            
            NSDictionary *playerSkins = [plist objectForKey:storeDataType];
            [self initPlayerSkins: playerSkins];
        } else if ([@"PowerUps" isEqualToString:storeDataType]) {
            
            NSDictionary *powerUpValues = [plist objectForKey:storeDataType];
            [self initPowerUps: powerUpValues];
        } else if ([@"LifeLines" isEqualToString:storeDataType]) {
            
            NSDictionary *lifeLineValues = [plist objectForKey:storeDataType];
            [self initLifeLines: lifeLineValues];
        } else if ([@"IAPs" isEqualToString:storeDataType]) {
            
            NSDictionary *iapValues = [plist objectForKey:storeDataType];
            [self initIAPs: iapValues];
        }
    }
}

- (WorldData *) getWorldData: (NSString *) worldName {
    
    WorldData * data = nil;
    
    for (WorldData * wData in worldData) {
        
        if ([wData.name isEqualToString:worldName]) {
            data = wData;
            break;
        }
    }
    
    return data;
}

- (void) initWorlds: (NSDictionary *) values {
    
    NSMutableArray *tmpValues = [NSMutableArray array];
    
    for (NSDictionary *value in values) {
        
        WorldData * data = [[WorldData alloc] init];
        
        data.name = [NSString stringWithString:(NSString *)[value objectForKey:@"Name"]];
        data.description = [NSString stringWithString:(NSString *)[value objectForKey:@"Description"]];
        data.spriteName = [NSString stringWithString:(NSString *)[value objectForKey:@"Sprite"]];
        data.price = [(NSNumber *)[value objectForKey:@"Price"] floatValue];
        data.level = [(NSNumber *)[value objectForKey:@"Level"] intValue];
        
        CCLOG(@"------ Loading world %@ - %@ - %@", data.name, data.description, data.spriteName);
        
        [tmpValues addObject: data];
    }
    
    worldData = [CCArray arrayWithNSArray: tmpValues];
    [worldData retain];
}

- (void) initPlayerSkins: (NSDictionary *) values {
    
    NSMutableArray *tmpValues = [NSMutableArray array];
    
    for (NSDictionary *value in values) {
        
        PlayerSkinData * data = [[PlayerSkinData alloc] init];
        
        data.type = [self getPlayerType: (NSString *)[value objectForKey:@"Type"]];;
        data.name = [NSString stringWithString:(NSString *)[value objectForKey:@"Name"]];
        data.description = [NSString stringWithString:(NSString *)[value objectForKey:@"Description"]];
        data.spriteName = [NSString stringWithString:(NSString *)[value objectForKey:@"Sprite"]];
        data.price = [(NSNumber *)[value objectForKey:@"Price"] floatValue];
        data.level = [(NSNumber *)[value objectForKey:@"Level"] intValue];
        
        CCLOG(@"------ Loading Player Skin %@ - %@ - %@", data.name, data.description, data.spriteName);
        
        [tmpValues addObject: data];
    }
    
    playerSkinData = [CCArray arrayWithNSArray: tmpValues];
    [playerSkinData retain];
}

- (PlayerType) getPlayerType: (NSString *) type {
    
    if ([@"Gonzo1" isEqualToString: type]) {
        return kPlayerTypeGonzo;
    }
    
    return kPlayerTypeGonzo;
}

- (void) initPowerUps: (NSDictionary *) values {
        
    //NSArray *sortedValues = [[values allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *tmpValues = [NSMutableArray array];
    
    for (NSDictionary *value in values) {
        
        PowerUpData * data = [[PowerUpData alloc] init];
        
        data.category = [self getGameObjectType: (NSString *)[value objectForKey:@"Category"]];
        data.type = [self getPowerUpTypeFromString: (NSString *)[value objectForKey:@"Type"]];
        data.name = [NSString stringWithString:(NSString *)[value objectForKey:@"Name"]];
        data.description = [NSString stringWithString:(NSString *)[value objectForKey:@"Description"]];
        data.spriteName = [NSString stringWithString:(NSString *)[value objectForKey:@"Sprite"]];
        data.price = [(NSNumber *)[value objectForKey:@"Price"] floatValue];
        data.level = [(NSNumber *)[value objectForKey:@"Level"] intValue];
        
        CCLOG(@"------ Loading Power Up %@ - %@ - %@", data.name, data.description, data.spriteName);
        
        [tmpValues addObject: data];
    }
    
    powerUpData = [CCArray arrayWithNSArray: tmpValues];
    [powerUpData retain];
}

- (GameObjectType) getGameObjectType: (NSString *) category {
    
    if ([@"Magnet" isEqualToString:category]) {
        return kGameObjectMagnet;
    } else if ([@"SpeedBoost" isEqualToString:category]) {
        return kGameObjectSpeedBoost;
    } else if ([@"AngerPotion" isEqualToString:category]) {
        return kGameObjectAngerPotion;
    } else if ([@"Shield" isEqualToString:category]) {
        return kGameObjectShield;
    } else if ([@"CoinDoubler" isEqualToString:category]) {
        return kGameObjectCoinDoubler;
    } else if ([@"MissileLauncher" isEqualToString:category]) {
        return kGameObjectMissileLauncher;
    } else if ([@"JetPack" isEqualToString:category]) {
        return kGameObjectJetPack;
    } else if ([@"GrenadeLauncher" isEqualToString:category]) {
        return kGameObjectGrenadeLauncher;
    }
    
    return kGameObjectNone;
}

- (PowerUpType) getPowerUpTypeFromString: (NSString *) type {
    
    if ([@"Medium" isEqualToString:type]) {
        return kPowerUpTypeMedium;
    } else if ([@"Long" isEqualToString:type]) {
        return kPowerUpTypeLong;
    } else if ([@"Extended" isEqualToString:type]) {
        return kPowerUpTypeExtended;
    }
    
    return kPowerUpTypeShort;
}

- (PowerUpType) getPowerUpType: (GameObjectType) powerUpCategory {
    
    UserData * uData = [UserData sharedInstance];
    int userLevel = [uData getNumLevelsCompleted];
    
    PowerUpType typeFound = kPowerUpTypeShort;
    int levelFound = 0;
    
    for (PowerUpData * puData in powerUpData) {
        
        if (puData.category == powerUpCategory) {
            
            if (puData.level > levelFound && ((userLevel >= puData.level && puData.price == 0.0f) || [uData isPowerUpPurchased:puData.name type:puData.type])) {
                levelFound = puData.level;
                typeFound = puData.type;
            }
        }
    }
    
    return typeFound;
}

- (void) initLifeLines: (NSDictionary *) values {
    
    NSMutableArray *tmpValues = [NSMutableArray array];
    
    for (NSDictionary *value in values) {
        
        LifeLineData * data = [[LifeLineData alloc] init];
        
        data.numLives = [(NSNumber *)[value objectForKey:@"Amount"] intValue];
        data.description = [NSString stringWithString:(NSString *)[value objectForKey:@"Description"]];
        data.spriteName = [NSString stringWithString:(NSString *)[value objectForKey:@"Sprite"]];
        data.price = [(NSNumber *)[value objectForKey:@"Price"] floatValue];
        data.level = [(NSNumber *)[value objectForKey:@"Level"] floatValue];
        
        CCLOG(@"------ Loading Life Line %@ - %@", data.description, data.spriteName);
        
        [tmpValues addObject: data];
    }
    
    lifeLineData = [CCArray arrayWithNSArray: tmpValues];
    [lifeLineData retain];
}

- (void) initIAPs: (NSDictionary *) values {
    
    NSMutableArray *tmpValues = [NSMutableArray array];
    
    for (NSDictionary *value in values) {
        
        BankData * data = [[BankData alloc] init];
        
        data.name = [NSString stringWithString:(NSString *)[value objectForKey:@"Name"]];
        
        data.description = [NSString stringWithString:(NSString *)[value objectForKey:@"Description"]];
        data.productId = [NSString stringWithString:(NSString *)[value objectForKey:@"ProductId"]];
        data.spriteName = [NSString stringWithString:(NSString *)[value objectForKey:@"Sprite"]];
        data.numCoins = [(NSNumber *)[value objectForKey:@"Coins"] intValue];
        data.price = [(NSNumber *)[value objectForKey:@"Price"] floatValue];
        
        CCLOG(@"------ Loading IAPs %@ - %@", data.productId, data.description);
        
        [tmpValues addObject: data];
    }
    
    bankData = [CCArray arrayWithNSArray: tmpValues];
    [bankData retain];
}

- (void) dealloc {
    
    [playerSkinData release];
    [powerUpData release];
    [lifeLineData release];
    [bankData release];
    
    [super dealloc];
}

@end
