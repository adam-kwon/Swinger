//
//  PlayerChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PlayerChooser.h"
#import "StoreItem.h"
#import "Macros.h"
#import "UserData.h"
#import "PlayerSkinData.h"
#import "GPImageButton.h"

const int INS_FUNDS_TAG = 58;
const int BUY_CONF_TAG = 57;

@implementation PlayerChooser

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
        
        // create player skin item
        CCArray * availablePlayers = [storeData playerSkinData];
        items = [[CCArray alloc] initWithCapacity:[availablePlayers count]];
        
        for (PlayerSkinData * psData in availablePlayers) {
            StoreItemStatus status = [self getStatus: psData];
            CCSprite * sprite = [CCSprite spriteWithSpriteFrameName: psData.spriteName];
            sprite.scale = 1.f;
            StoreItem * item = [StoreItem make: sprite
                                          size: CGSizeMake(self.contentSize.width, rowHeight)
                                        parent: self
                                          type: kStorePlayerType 
                                        itemId: psData.type
                                          name: psData.name 
                                   description: psData.description
                                     productId: psData.description
                                         price: psData.price * (status == kStoreItemLocked ? 2 : 1)
                                        status: status
                                         level: psData.level];
            
            item.anchorPoint = ccp(0,1);
            item.position = ccp(ssipadauto(2), currentHeight);
            [self addChild: item];
            
            currentHeight -= item.contentSize.height + ssipadauto(1);
            [items addObject: item];
        }
        
        // Borders
        /*CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_CANTALOPE, 255)];
         border.contentSize = CGSizeMake(1, self.contentSize.height - ssipadauto(30));
         border.anchorPoint = preview.anchorPoint;
         border.position = ccp(0,0);
         [preview addChild: border];*/
        
        //pane.visible = YES;
    }
    
    return self;
}

- (StoreItemStatus) getStatus: (PlayerSkinData *) psData {
    
    StoreItemStatus status = kStoreItemSelected;
    
    if (userData.playerType != psData.type) {
        // not currently selected
        
        status = [userData getNumLevelsCompleted] >= psData.level ? kStoreItemUnlocked : kStoreItemLocked;
        BOOL purchased = psData.price == 0.0f || [userData isPlayerSkinPurchased: psData.name type: psData.type];
        
        if (purchased) {
            status = kStoreItemPurchased;
        }
    }
    
    return status;
}

- (BOOL) select:(StoreItem *)item {
    
    CCLOG(@"%@ was selected!", item.itemName);
    
    if (item.itemType == kStorePlayerType) {
        userData.playerType = (PlayerType)item.itemId;
        item.itemStatus = kStoreItemSelected;
        [item refresh];
        [store refresh];
    }
    
    return YES;
}

/*- (BOOL) buy:(StoreItem *)item {
    CCLOG(@"%@ was bought!", item.itemName);
    
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
    
}

@end
