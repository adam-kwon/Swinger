//
//  Objective.m
//  Swinger
//
//  Created by James Sandoz on 9/15/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Objective.h"

#import "Constants.h"

#define CC3_ACHIEVE_COMPLETE CC3_COLOR_STEEL_GREEN
#define CC3_ACHIEVE_COMPLETE_BORDER CC3_COLOR_DARK_STEEL_GREEN

#define CC3_ACHIEVE_INCOMPLETE CC3_COLOR_STEEL_BLUE
#define CC3_ACHIEVE_INCOMPLETE_BORDER CC3_COLOR_BLUE

@implementation Objective

+ (id) nodeWithObj:(ObjectiveData *)objData {
    return [[[self alloc] initWithObj:objData] autorelease];
}


- (id) initWithObj:(ObjectiveData *)objData {
    
    if ((self = [super init])) {
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        objectiveData = objData;
        
        ccColor3B bgColor = CC3_ACHIEVE_INCOMPLETE;
        ccColor3B borderColor = CC3_ACHIEVE_INCOMPLETE_BORDER;
        ccColor3B textColor = CC3_COLOR_GRAY2;
        ccColor3B iconColor = CC3_COLOR_GRAY2;
        if (objData.complete) {
            bgColor = CC3_ACHIEVE_COMPLETE;
            borderColor = CC3_ACHIEVE_COMPLETE_BORDER;
            textColor = CC3_COLOR_WHITE;
            iconColor = CC3_COLOR_WHITE;
        }
        
        // Background
        background = [CCLayerColor layerWithColor:ccc3to4(CC3_ACHIEVE_INCOMPLETE, 225)];
        
//        self.contentSize = CGSizeMake(ssipadauto(380), ssipadauto(50));
        self.contentSize = CGSizeMake(screenSize.width*.8f, screenSize.height*.15625f);
        background.contentSize = self.contentSize;
        [self addChild:background z:-2];
        
        icon = [CCSprite spriteWithSpriteFrameName:@"Balloons.png"];
        icon.scale = .75f;
        icon.position = ccp([icon boundingBox].size.width/2 + ssipadauto(5), [icon boundingBox].size.height/2);
        icon.color = iconColor;
        [self addChild:icon z:5];
        
        // Borders
        NSMutableArray *tmpBorders = [NSMutableArray arrayWithCapacity:4];
        CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_ACHIEVE_INCOMPLETE_BORDER, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, ssipadauto(1));
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0,0);
        [self addChild: border z:-1];
        [tmpBorders addObject:border];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_ACHIEVE_INCOMPLETE_BORDER, 255)];
        border.contentSize = CGSizeMake(ssipadauto(2), self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(self.contentSize.width - ssipadauto(2), 0);
        [self addChild: border z:-1];
        [tmpBorders addObject:border];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_ACHIEVE_INCOMPLETE_BORDER, 255)];
        border.contentSize = CGSizeMake(ssipadauto(1), self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, 0);
        [self addChild: border z:-1];
        [tmpBorders addObject:border];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_ACHIEVE_INCOMPLETE_BORDER, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, ssipadauto(1));
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, self.contentSize.height - ssipadauto(1));
        [self addChild: border z:-1];
        [tmpBorders addObject:border];
        
        borders = [[[NSArray arrayWithArray:tmpBorders] autorelease] retain];
        
        // Description
        descriptionLabel = [CCLabelBMFont labelWithString:objectiveData.description fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        descriptionLabel.anchorPoint = ccp(0,0);
        descriptionLabel.position = ccp(ssipadauto(50), self.contentSize.height/2 - [descriptionLabel boundingBox].size.height/2);
        descriptionLabel.color = textColor;
        [self addChild:descriptionLabel];
        
        // Reward
        NSString *rewardStr = [NSString stringWithFormat:@"x %d", objectiveData.rewardAmount];
        rewardLabel = [CCLabelBMFont labelWithString:rewardStr fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        rewardLabel.anchorPoint = ccp(0,0);
        rewardLabel.position = ccp(self.contentSize.width - ssipadauto(60), self.contentSize.height/2 - [rewardLabel boundingBox].size.height/2);
        rewardLabel.color = textColor;
        [self addChild:rewardLabel];

        CCSprite *rewardIcon = [CCSprite spriteWithSpriteFrameName:@"Coin1_1.png"];
        rewardIcon.position = ccp(rewardLabel.position.x - [rewardIcon boundingBox].size.width/2 - ssipadauto(5), self.contentSize.height/2);
        [self addChild:rewardIcon];
    }

    return self;
}


- (void) showCompleted {

    // update the objective
    objectiveData.complete = YES;
    
    // update the colors
    [icon setColor:CC3_COLOR_WHITE];
    background.color = CC3_ACHIEVE_COMPLETE;
    descriptionLabel.color = CC3_COLOR_WHITE;
    rewardLabel.color = CC3_COLOR_WHITE;

    for (CCLayerColor *border in borders) {
        border.color = CC3_ACHIEVE_COMPLETE_BORDER;
    }
}

@end
