//
//  GPGameCenter.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 4/20/12.
//  Copyright (c) 2012 GAMEPEONS LLC. All rights reserved.
//

//XXX todo: check for unreported achievements and report them when gamecenter is authenticated

#import "GPGameCenter.h"
#import "UserData.h"
#import "Achievement.h"

#define FILE_UNREPORTED_ACHIEVEMENTS    "SwingStar.UnreportedAchievements"
#define FILE_UNREPORTED_SCORES          "SwingStar.UnreportedScores"


@implementation GPGameCenter

static GPGameCenter *sharedInstance = nil;

+ (GPGameCenter*) sharedInstance {
    @synchronized([GPGameCenter class]) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

+ (id) alloc {
    @synchronized([GPGameCenter class]) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of GPGameCenter");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

- (BOOL) isGameCenterAvailable {
    // Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    // Check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id) init {
    if ((self = [super init])) {
        isGameCenterAvailable = [self isGameCenterAvailable];
        if (isGameCenterAvailable) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(authenticationChanged) 
                                                         name:GKPlayerAuthenticationDidChangeNotificationName 
                                                       object:nil];
            
            // load or create the unreported achieve/score lists
            unreportedAchievements = [[NSKeyedUnarchiver unarchiveObjectWithFile:@FILE_UNREPORTED_ACHIEVEMENTS] retain];
            if (unreportedAchievements == nil) {
                unreportedAchievements = [[NSMutableArray array] retain];
            }
            
            unreportedScores = [[NSKeyedUnarchiver unarchiveObjectWithFile:@FILE_UNREPORTED_SCORES] retain];
            if (unreportedScores == nil) {
                unreportedScores = [[NSMutableArray array] retain];
            }
        }
    }
    return self;
}

- (void)resendData {
    for (GKAchievement *achievement in unreportedAchievements) {
        [self sendAchievement:achievement];
    }
    for (GKScore *score in unreportedScores) {
        [self sendScore:score];
    }    
}

- (void) authenticationChangedHelper:(id)obj {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !isUserAuthenticated) {
        NSLog(@"**** Authentication changed: player authenticated.");
        isUserAuthenticated = YES;
        [self resendData];
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && isUserAuthenticated) {
        NSLog(@"**** Authentication changed: player not authenticated.");
        isUserAuthenticated = NO;
    }
}

- (void) authenticationChanged {
    [self performSelectorOnMainThread:@selector(authenticationChangedHelper:) withObject:nil waitUntilDone:YES];

    // iOS 3.2 and above
    /*
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([GKLocalPlayer localPlayer].isAuthenticated && !isUserAuthenticated) {
            NSLog(@"Authentication changed: player authenticated.");
            isUserAuthenticated = YES;
        }
        else if (![GKLocalPlayer localPlayer].isAuthenticated && isUserAuthenticated) {
            NSLog(@"Authentication changed: player not authenticated.");
            isUserAuthenticated = NO;
        }});
     */
}

- (void) authenticateLocalUser {
    if (!isGameCenterAvailable) return;
    
    NSLog(@"**** Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"**** Already authenticated");
    }
}


- (void) sendAchievement:(GKAchievement *)achievement {
    
    CCLOG(@"In sendAchievement: %@\n", achievement);

    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (error == NULL) {
                NSLog(@"**** Successfully sent archievement!");
                [unreportedAchievements removeObject:achievement];
            } else {
                NSLog(@"**** Achievement failed to send... will try again later.  Reason: %@", error.localizedDescription);
                [unreportedAchievements addObject:achievement];
            }
            
            [NSKeyedArchiver archiveRootObject:unreportedAchievements toFile:@FILE_UNREPORTED_ACHIEVEMENTS];
            
        });
    }];
}

- (void) sendScore:(GKScore*)score {
    CCLOG(@"in sendScore:%@\n", score);
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (error == NULL) {
                NSLog(@"**** Successfully sent score!");
                [unreportedScores removeObject:score];
            } else {
                NSLog(@"**** Score failed to send... will try again later.  Reason: %@", error.localizedDescription);
                [unreportedScores addObject:score];
            }
            
            [NSKeyedArchiver archiveRootObject:unreportedScores toFile:@FILE_UNREPORTED_SCORES];
        });
    }];    
}


- (void) dealloc {
    [super dealloc];
}

@end
