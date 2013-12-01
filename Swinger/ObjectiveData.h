//
//  ObjectiveData.h
//  Swinger
//
//  Created by James Sandoz on 9/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kObjectiveRewardNone,
    kObjectiveRewardCoin,
    kObjectiveRewardStar
} ObjectiveReward;


@interface ObjectiveData : NSObject  {
    NSString        *objId;
    NSString        *achieveKey;
    NSString        *description;
    ObjectiveReward rewardType;
    int             rewardAmount;
    BOOL            complete;
}


@property (readwrite, nonatomic, assign) NSString *objId;
@property (readwrite, nonatomic, assign) NSString *achieveKey;
@property (readwrite, nonatomic, assign) NSString *description;
@property (readwrite, nonatomic, assign) ObjectiveReward rewardType;
@property (readwrite, nonatomic, assign) int rewardAmount;
@property (readwrite, nonatomic, assign) BOOL complete;



@end
