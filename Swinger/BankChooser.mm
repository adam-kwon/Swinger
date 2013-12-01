//
//  BankChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 9/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "BankChooser.h"
#import "StoreItem.h"
#import "Macros.h"
#import "UserData.h"
#import "BankData.h"

@implementation BankChooser

+ (id) make: (CGSize) theSize store: (StoreScene*) theStore {
    return [[[self alloc] initWithUserData: [UserData sharedInstance] size: theSize store: theStore] autorelease];
}

- (id) initWithUserData: (UserData *) theUserData size: (CGSize) theSize store: (StoreScene *) theStore {
    self = [super initWithSize:theSize store: theStore];
    
    if (self != nil) {
        userData = theUserData;
        storeData = [StoreManager sharedInstance];
        
        //float myWidth = self.contentSize.width;// - ssipadauto(60);
        float startHeight = self.contentSize.height;// - ssipadauto(30);
        float rowHeight = startHeight/4;
        currentHeight = startHeight;
        
        //pane = [CCNode node];
        //pane.contentSize = CGSizeMake(myWidth, startHeight);
        //[self addChild: pane z:1];
        
        CCArray * iaps = [storeData bankData];
        items = [[CCArray alloc] initWithCapacity:[iaps count]];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        for (BankData * iap in iaps) {
            
            NSMutableString * theName = [NSMutableString stringWithString: iap.name];
            [theName retain];
            StoreItemStatus status = kStoreItemOnSale;
            
            if (iap.numCoins > 0) {
                NSString * numCoins = [numberFormatter stringFromNumber:[[NSNumber alloc] initWithInt: iap.numCoins]];
                [theName appendFormat:@" (%@)", numCoins];
            } else {
                
                if ([UserData sharedInstance].unlimitedCoinDoubler) {
                    status = kStoreItemSelected; // already purchased
                }
            }
            
            StoreItem * item = [StoreItem make: [CCSprite spriteWithSpriteFrameName: iap.spriteName]
                                          size: CGSizeMake(self.contentSize.width, rowHeight)
                                        parent: self
                                          type: kStoreBankType 
                                        itemId: iap.numCoins
                                          name: theName
                                   description: iap.description
                                     productId: iap.productId
                                         price: iap.price 
                                        status: status
                                         level: 0];
            
            item.anchorPoint = ccp(0,1);
            item.position = ccp(ssipadauto(2), currentHeight);
            [self addChild: item];
            
            currentHeight -= item.contentSize.height + ssipadauto(1);
            [items addObject: item];
        }
    }
    
    return self;
}

- (BOOL) select:(StoreItem *)item {
    return YES;
}

/*- (BOOL) buy:(StoreItem *)item {
    return NO;
}*/

- (void) refresh {
    
    /*for (StoreItem * item in items) {
        
        if (item.itemId <= 0) {
            
            if ([UserData sharedInstance].unlimitedCoinDoubler) {
                item.itemStatus = kStoreItemSelected; // already purchased
                [item refresh];
            }
        }
    }*/
}

@end
