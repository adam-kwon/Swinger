//
//  StoreItem.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"

@class StoreChooser;
@class GPImageButton;

typedef enum {
    kStorePlayerType,
    kStorePowerUpType,
    kStoreLifeLineType,
    kStoreBankType
} StoreItemType;

typedef enum {
    kStoreItemSelected,
    // states below indicate item is not selected
    kStoreItemPurchased,
    kStoreItemUnlocked,
    // states below indicate item is locked
    kStoreItemLocked,
    kStoreItemOnSale,
    kStoreItemNew,
    
} StoreItemStatus;

@interface StoreItem : CCNode {
    
    StoreChooser    *itemParent;
    StoreItemType   itemType;
    int             itemId;
    NSString        *itemName;
    NSString        *itemDescription;
    NSString        *itemProductId;
    float           itemPrice;
    StoreItemStatus itemStatus;        
    CCSprite        *itemSprite;
    int             itemLevel;
    
    CGPoint         touchStart;
    CGPoint         lastMoved;
    
    // mutable data
    CCLabelBMFont   *name;
    CCSprite        *statusSprite;
    CCLabelBMFont   *statusLabel;
    GPImageButton   *selectButton;
}

@property (nonatomic, readonly) StoreItemType itemType;
@property (nonatomic, readonly) int itemId;
@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSString *itemDescription;
@property (nonatomic, readonly) NSString *itemProductId;
@property (nonatomic, readonly) float itemPrice;
@property (nonatomic, readwrite, assign) StoreItemStatus itemStatus;
@property (nonatomic, readonly) CCSprite *itemSprite;
@property (nonatomic, readonly) StoreChooser *itemParent;
@property (nonatomic, readonly) int itemLevel;

+ (id) make: (CCSprite *) theSprite 
       size: (CGSize) theSize
     parent: (StoreChooser *) theParent
       type: (StoreItemType) theType
     itemId: (int) theItemId
       name: (NSString *) theName 
description: (NSString *) theDescription
  productId: (NSString *) theProductId
      price: (float) thePrice 
     status: (StoreItemStatus) theStatus
      level: (int) theLevel;

- (void) refresh;

@end
