//
//  BankData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankData : NSObject {
    
    NSString *name;
    NSString *description;
    NSString *spriteName;
    NSString *productId;
    int      numCoins;
    float    price;
    BOOL     special;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* spriteName;
@property (nonatomic, retain) NSString* productId;
@property (nonatomic, readwrite, assign) int numCoins;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) BOOL special;

@end
