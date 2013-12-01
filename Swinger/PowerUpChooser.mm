//
//  PowerUpChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 9/1/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreItem.h"
#import "PowerUpChooser.h"
#import "PowerUpData.h"
#import "StoreScene.h"

const int INS_FUNDS_TAG = 58;
const int BUY_CONF_TAG = 57;

@implementation PowerUpChooser

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
        
        // create player power up items
        CCArray * powerUps = [storeData powerUpData];
        items = [[CCArray alloc] initWithCapacity: [powerUps count]];
        
        NSMutableArray * puShort = [[NSMutableArray alloc] initWithCapacity: 7];
        NSMutableArray * puMedium = [[NSMutableArray alloc] initWithCapacity: 7];
        NSMutableArray * puLong = [[NSMutableArray alloc] initWithCapacity: 7];
        NSMutableArray * puExtended = [[NSMutableArray alloc] initWithCapacity: 7];
        
        for (PowerUpData * puData in powerUps) {
            // load powerup items
            StoreItem * item = [self createStoreItem: puData rowHeight: rowHeight];
            
            if (puData.type == kPowerUpTypeMedium) {
                [puMedium addObject: item];
            } else if (puData.type == kPowerUpTypeLong) {
                [puLong addObject: item];
            } else if (puData.type == kPowerUpTypeExtended) {
                [puExtended addObject: item];
            } else {
                [puShort addObject: item];
            }
        }
        
        for (StoreItem * item in puShort) {
            [self addItem: item];
        }
        [puShort removeAllObjects];
        
        for (StoreItem * item in puMedium) {
            [self addItem: item];
        }
        [puMedium removeAllObjects];
        
        for (StoreItem * item in puLong) {
            [self addItem: item];
        }
        [puLong removeAllObjects];
        
        for (StoreItem * item in puExtended) {
            [self addItem: item];
        }
        [puExtended removeAllObjects];
    }
    
    return self;
}

- (void) addItem: (StoreItem *) item {
    
    [items addObject: item];
    item.anchorPoint = ccp(0,1);
    item.position = ccp(ssipadauto(2), currentHeight);
    currentHeight -= item.contentSize.height + ssipadauto(1);
    [self addChild: item];
}

- (StoreItem *) createStoreItem: (PowerUpData *) puData rowHeight: (float) rowHeight {
    
    StoreItemStatus status = [self getStatus: puData];
    StoreItem * item = [StoreItem make: [CCSprite spriteWithFile: puData.spriteName]
                                  size: CGSizeMake(self.contentSize.width, rowHeight)
                                parent: self
                                  type: kStorePowerUpType 
                                itemId: puData.type
                                  name: puData.name
                           description: puData.description
                             productId: puData.description
                                 price: puData.price * (status == kStoreItemLocked ? 2 : 1)
                                status: status
                                 level: puData.level];
    
    return item;
}

- (StoreItemStatus) getStatus: (PowerUpData *)puData {
    
    StoreItemStatus status = [userData getNumLevelsCompleted] >= puData.level ? kStoreItemUnlocked : kStoreItemLocked;
    BOOL purchased = puData.price == 0.0f || [userData isPowerUpPurchased: puData.name type: puData.type];
    
    if (purchased) {
        status = kStoreItemSelected;
    }
    
    return status;
}

- (BOOL) select:(StoreItem *)item {
    // not used
    return YES;
}

/*- (BOOL) buy:(StoreItem *)item {
    CCLOG(@"Want to buy %@", item.itemName);
    
    if (userData.totalCoins >= item.itemPrice) {
        // try to purchase it
        currItem = item;
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Buy %@?", item.itemName] message:@"Do you want to buy this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes!"];
        alert.tag = BUY_CONF_TAG;
        [alert show];
        
    } else {
        // unable to purchase redirect to bank
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Need more coins..." message:@"Check out your options" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
        alert.tag = INS_FUNDS_TAG;
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes!"];
        [alert show];
    }
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == INS_FUNDS_TAG) {
     
        if (buttonIndex == 1) {
            [store goToBank];
        }
    } else if (alertView.tag == BUY_CONF_TAG) {
        
        if (buttonIndex == 1) {
            // buy the product
            [userData purchasePowerUp:currItem.itemName type:currItem.itemId cost:currItem.itemPrice];
            currItem.itemStatus = kStoreItemSelected;
            [currItem refresh];
            [store refresh];
            currItem = nil;
        }
    }
}*/

- (void) refresh {
    // reload item states
}

@end
