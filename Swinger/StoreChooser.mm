//
//  StoreChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreChooser.h"
#import "StoreItem.h"
#import "Macros.h"
#import "UserData.h"
#import "StoreScene.h"

const int NUM_ITEMS_PER_PAGE = 4;
const int INS_FUNDS_TAG = 58;
const int BUY_CONF_TAG = 57;
const int BUY_COINS_TAG = 59;
const int BUY_DOUBLER_TAG = 60;

@implementation StoreChooser

- (id) initWithSize:(CGSize)theSize store: (StoreScene *) theStore {
    self = [super init];
    
    if (self) {
        self.contentSize = theSize;
        store = theStore;
        userData = [UserData sharedInstance];
    }
    
    return self;
}

- (void) onEnter {
    CCLOG(@"**** StoreChooser onEnter");
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** StoreChooser onExit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark - Touch Handling
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.visible) {
        touchStart = [touch locationInView:[touch view]];
        touchStart = [[CCDirector sharedDirector] convertToGL:touchStart];
    
        lastMoved = touchStart;
    }
    
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!self.visible) {
        return;
    }
    
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    const int threshold = 40;
    float deltaScroll = touchPoint.y - touchStart.y;
    
    if (deltaScroll < -threshold) {
        // Scroll up
        currentlyVisibleItemIndex = MAX(0, currentlyVisibleItemIndex-NUM_ITEMS_PER_PAGE);     
    } else if (deltaScroll > threshold) {
        // Scroll down
        currentlyVisibleItemIndex = MIN([items count]-NUM_ITEMS_PER_PAGE, currentlyVisibleItemIndex+NUM_ITEMS_PER_PAGE);   
    } else {
        // Selection (touch)
        // Handled by respective StoreItems
    }
    
    if (currentlyVisibleItemIndex < 0) {
        currentlyVisibleItemIndex = 0;
    } else if (currentlyVisibleItemIndex >= [items count]) {
        currentlyVisibleItemIndex = [items count] - 1;
    }
    
    StoreItem *item = [items objectAtIndex:currentlyVisibleItemIndex];
    float nextY = normalizeToScreenCoord(self.position.y, item.position.y, 1.0);
    float deltaY = nextY - (self.contentSize.height /*- ssipadauto(30)*/);
    id ease = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:0.25 
                                                                  position:CGPointMake(0, -deltaY)]];
    [self runAction:ease];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!self.visible) {
        return;
    }
    
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    float deltaScroll = touchPoint.y - lastMoved.y;
    self.position = CGPointMake(self.position.x, self.position.y + deltaScroll);
    
    lastMoved = touchPoint;
}

- (BOOL) select:(StoreItem *)item {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return YES;
}

- (BOOL) buy:(StoreItem *)item {
    //NSAssert(NO, @"This is an abstract method and should be overridden");
    //return NO;
    
    if (item.itemType != kStoreBankType) {        
        if (userData.totalCoins >= item.itemPrice) {
            // try to purchase it
            currItem = item;
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Buy %@?", item.itemName] message:[NSString stringWithFormat:@"Do you want to buy this item for %.0f coins?", item.itemPrice] delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:nil] autorelease];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"Yes!"];
            alert.tag = BUY_CONF_TAG;
            [alert show];
            
        } else {
            // unable to purchase redirect to bank
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Need more coins..." message:@"Check out your options" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:nil] autorelease];
            alert.tag = INS_FUNDS_TAG;
            // optional - add more buttons:
            [alert addButtonWithTitle:@"Yes!"];
            [alert show];
        }
    } else {
        // process IAP purchase
        currItem = item;
        int tag = BUY_COINS_TAG;
        
        if (item.itemId <= 0) { // XXX - change this to the actual product id of the coin doubler
            // Coin doubler purchase
            tag = BUY_DOUBLER_TAG;
        }
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Buy %@?", item.itemName] message:[NSString stringWithFormat:@"Do you want to buy this item for $%.2f?", item.itemPrice] delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:nil] autorelease];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes!"];
        alert.tag = tag;
        [alert show];
    }
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        if (alertView.tag == INS_FUNDS_TAG) {
            // not enough coins go to buy some
            [store goToBank];
        } else if (alertView.tag == BUY_CONF_TAG) {
            // buy the product
            if (currItem.itemType == kStorePowerUpType) {
                [userData purchasePowerUp:currItem.itemName type:currItem.itemId cost:currItem.itemPrice];
            }
            else if (currItem.itemType == kStoreLifeLineType) {
                [userData purchaseLives:currItem.itemId cost:currItem.itemPrice];
            }
            
            StoreItemStatus status = currItem.itemStatus;
            
            if (currItem.itemType == kStorePowerUpType) {
                status = kStoreItemSelected;
            } else if (currItem.itemType == kStorePlayerType) {
                status = kStoreItemPurchased;
            }
            
            currItem.itemStatus = status;
            
            [currItem refresh];
            [store refresh];
            currItem = nil;
        } else if (alertView.tag == BUY_COINS_TAG) {
            // iap purchase coins
            [UserData sharedInstance].totalCoins += currItem.itemId;
            [store refresh];
        } else if (alertView.tag == BUY_DOUBLER_TAG) {
            [UserData sharedInstance].unlimitedCoinDoubler = YES;
            
            currItem.itemStatus = kStoreItemSelected;
            
            [currItem refresh];
            [store refresh];
        }
    }
}

- (void) refresh {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void) refreshStore {
    [store refresh];
}

@end
