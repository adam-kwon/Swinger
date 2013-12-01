//
//  CCHeadBodyAnimate.h
//  Swinger
//
//  Created by Min Kwon on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@class CCHeadBodyAnimation;

@interface CCHeadBodyAnimate : CCAnimate {
    CCHeadBodyAnimation *headBodyAnimation_;
    id origBodyFrame_;
    CCSprite *bodySprite;
    CCArray *positions;
}

+ (id) actionWithHeadBodyAnimation:(CCAnimation*)anim restoreOriginalFrame:(BOOL)b;
- (id) initWithHeadBodyAnimation:(CCAnimation*)anim restoreOriginalFrame:(BOOL)b;

@property (readwrite,nonatomic,retain) CCHeadBodyAnimation *headBodyAnimation;

@end
