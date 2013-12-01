//
//  ObjectivesScreen.m
//  Swinger
//
//  Created by James Sandoz on 9/14/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "ObjectivesScreen.h"

#import "Constants.h"
#import "GPImageButton.h"


@implementation ObjectivesScreen



+ (id) node {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if ((self = [super init])) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        [self loadObjectives];
        
        [self buildWindow];
    }
    
    return self;
}

- (void) setBackTarget:(id)target action:(SEL)sel {
    backTarget = target;
    backAction = sel;
}

- (void) updateObjectives {
//    objectiveBoxes[i]
}

- (void) buildWindow {
    CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 150)];
//    [background setContentSize:CGSizeMake(screenSize.width*.8, screenSize.height*.8)];
    [self addChild:background];
    
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"CURRENT OBJECTIVES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    title.scale = 1.25f;
    title.position = ccp(screenSize.width/2, screenSize.height - [title boundingBox].size.height);
    [self addChild:title];

    
    GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"Button_Options.png"];
    CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    [backButton setText:backText];
    backButton.position = ccp(screenSize.width/2, [backButton boundingBox].size.height + ssipadauto(30));
    [self addChild:backButton];
    
    // create the boxes to hold the objectives
    CGPoint objPos = ccp(screenSize.width/2, title.position.y - [title boundingBox].size.height - ssipad(60, 15));
    
    for (int i=0; i < 3; i++) {
        Objective *obj = currentObjectives[i];
        obj.anchorPoint = ccp(0.5f, 0.5f);
        obj.position = objPos;
        [self addChild:obj];
        
        objPos.y -= ([obj boundingBox].size.height + ssipadauto(10));
    }
    
    //XXX temporary
    //[currentObjectives[0] showCompleted];
}

- (void) goBack {
    [backTarget performSelector:backAction];
}

- (void) loadObjectives {
    // First try to load the persisted objectives
    //    keyToAchievements = [[NSKeyedUnarchiver unarchiveObjectWithFile:@FILE_ACHIEVE_ARCHIVE] retain];
    
    //XXX need to handle case where objectives have changed?
    
    // objectives were not loaded, load them now
    if (allObjectives == nil) {        
        // load the objectives from the plist
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Objectives" ofType:@"plist"];
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *plist = (NSDictionary*)
        [NSPropertyListSerialization propertyListFromData:plistXML 
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                                   format:&format 
                                         errorDescription:&errorDesc];
        
        if (!plist) {
            NSLog(@"**** Error reading Objectives.plist: %@, format: %d", errorDesc, format);
        } else {
            NSArray *sortedKeys = [[plist allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            NSMutableArray *tmpObjectives = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
            for (NSString *key in sortedKeys) {
                NSDictionary *objDict = [plist objectForKey:key];
                
                NSString *achKey = [objDict objectForKey:@"Key"];
                NSString *description = [objDict objectForKey:@"Description"];
                
                NSDictionary *reward = [objDict objectForKey:@"Reward"];
                NSString *rewardTypeStr = [reward objectForKey:@"Type"];
                ObjectiveReward rewardType = kObjectiveRewardNone;
                if (rewardTypeStr == @"Coin") {
                    rewardType = kObjectiveRewardCoin;
                } else if (rewardTypeStr == @"Star") {
                    rewardType = kObjectiveRewardStar;
                }
                
                int rewardAmount = [(NSNumber *)[reward objectForKey:@"Amount"] intValue];
                
                // create the data object
                ObjectiveData *data = [[ObjectiveData alloc] init];
                data.objId = key;
                data.achieveKey = achKey;
                data.description = description;
                data.rewardType = rewardType;
                data.rewardAmount = rewardAmount;
                data.complete = NO;
                
                // create the objective
                Objective *objective = [Objective nodeWithObj:data];
                [tmpObjectives addObject:objective];
            }
        
            allObjectives = [[[NSArray arrayWithArray:tmpObjectives] autorelease] retain];
            
            // objectives were not cached so none have been completed yet.  Start with first
            // 3
            for (int i=0; i < 3; i++) {
                currentObjectives[i] = [allObjectives objectAtIndex:i];
            }
        }
    } else {
        // figure out which objectives we are currently on
        //XXX TODO
    }
}

- (void) dealloc {
    [self removeAllChildrenWithCleanup:YES];
        
    [super dealloc];
}
@end
