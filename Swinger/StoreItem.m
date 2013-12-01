//
//  StoreItem.mm
//  Swinger
//
//  Created by Isonguyo Udoka on 7/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Macros.h"
#import "StoreItem.h"
#import "GPLabel.h"
#import "GPUtil.h"
#import "CCLayerColor+extension.h"
#import "Constants.h"
#import "GPImageButton.h"
#import "UserData.h"
#import "StoreChooser.h"

@implementation StoreItem

@synthesize itemType;
@synthesize itemId;
@synthesize itemName;
@synthesize itemDescription;
@synthesize itemProductId;
@synthesize itemPrice;
@synthesize itemStatus;
@synthesize itemSprite;
@synthesize itemParent;
@synthesize itemLevel;

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
      level: (int) theLevel {
   
    return [[[self alloc] initWithSprite: theSprite size: theSize parent: theParent type: theType itemId: theItemId name:theName description:theDescription productId: theProductId price:thePrice status:theStatus level:theLevel] autorelease];
}

- (id) initWithSprite: (CCSprite *) theSprite 
                 size: (CGSize) theSize
               parent: (StoreChooser *) theParent
                 type: (StoreItemType) theType 
               itemId: (int) theItemId
                 name: (NSString *) theName 
          description: (NSString *) theDescription
            productId: (NSString *) theProductId
                price: (float) thePrice 
               status: (StoreItemStatus) theStatus
                level: (int) theLevel {
    
    self = [super init];
    if (self != nil) {
        //
        
        itemParent = theParent;
        itemType = theType;
        itemId = theItemId;
        itemName = theName;
        itemDescription = theDescription;
        itemProductId = theProductId;
        itemPrice = thePrice;
        itemSprite = theSprite;
        itemStatus = theStatus;
        itemLevel = theLevel;
        
        self.contentSize = theSize;
        self.anchorPoint = ccp(0,1);
        
        if (theType == kStorePlayerType) {
            theSprite.contentSize = CGSizeMake(ssipadauto(85), ssipadauto(75));
            theSprite.position = ccp(ssipadauto(5), [self boundingBox].size.height - ssipad(10,-5));
        } else {
            theSprite.contentSize = CGSizeMake(ssipadauto(30), ssipadauto(40));
            theSprite.position = ccp(ssipadauto(10), [self boundingBox].size.height - ssipad(10,0));
        }
        
        theSprite.anchorPoint = ccp(0,1);
        [self addChild: theSprite];
        
        name = [CCLabelBMFont labelWithString:theName fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        name.color = CC3_COLOR_CANTALOPE;
        name.anchorPoint = ccp(0,1);
        name.position = ccp(theSprite.position.x + [theSprite boundingBox].size.width + ssipadauto(10), theSprite.position.y - ssipad(10, theType == kStorePlayerType ? 20 : 5));
        [self addChild: name];

        // create buttons and controls to select/purchase items
        [self createStatusAndPriceControls];
        
        CCLabelBMFont * descr = [CCLabelBMFont labelWithString:theDescription fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        descr.scale = 0.65f;
        descr.anchorPoint = ccp(0,1);
        descr.position = ccp(name.position.x, name.position.y - ssipad(40,23));
        [self addChild: descr];
        
        CCLayerColor * background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 245)];
        background.contentSize = self.contentSize;
        background.anchorPoint = self.anchorPoint;
        background.position = ccp(0,0);
        [self addChild: background z:-2];
        
        // Borders
        CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, 1);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0,0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(2, self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(self.contentSize.width - 2, 0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(1, self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, 0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, 1);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, self.contentSize.height - 1);
        [self addChild: border z:-1];
    }
    
    return self;
}

- (void) createStatusAndPriceControls {
    
    // cleanup previously allocated status images/msgs and price buttons
    if (statusSprite != nil) {
        [statusSprite removeFromParentAndCleanup: YES];
        statusSprite = nil;
    }
    
    if (statusLabel != nil) {
        [statusLabel removeFromParentAndCleanup: YES];
        statusLabel = nil;
    }
    
    if (selectButton != nil) {
        [selectButton removeFromParentAndCleanup: YES];
        selectButton = nil;
    }
    
    // create them new and add them
    if (itemStatus == kStoreItemSelected) {
        // Already selected put check mark next to sprite
        statusSprite = [CCSprite spriteWithFile:@"selected.png"];
        
        if (itemType == kStorePlayerType) {
            statusSprite.position = ccp(itemSprite.position.x + ssipadauto(20), itemSprite.position.y - [itemSprite boundingBox].size.height + ssipadauto(20));
        } else {
            statusSprite.position = ccp(itemSprite.position.x + ssipadauto(10), itemSprite.position.y - [itemSprite boundingBox].size.height + ssipadauto(5));
        }
        
        [self addChild: statusSprite z:2];
    } else {
        
        if (itemStatus == kStoreItemPurchased) {
            
            if (itemType == kStorePlayerType) {
                // show select button
                selectButton = [GPImageButton controlOnTarget:self andSelector:@selector(chooseMe) imageFromFile:@"Button_Options.png"];
                selectButton.position = ccp(self.contentSize.width - [selectButton boundingBox].size.width - ssipadauto(60), name.position.y - ssipadauto(10));
                [self addChild:selectButton];
                
                CCLabelBMFont * select = [CCLabelBMFont labelWithString:@"Choose Me" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
                select.scale = 0.7f;
                [selectButton setText: select];
                selectButton.scale = 0.7f;
            }
            
        } else {
            
            float priceButtonY = name.position.y - ssipad(14, 11);
            NSString * buttonImg = @"Button_Options.png";
            
            if (itemStatus == kStoreItemLocked) {
                // show item locked/price to unlock early
                statusSprite = [CCSprite spriteWithFile:@"lock.png"];
                statusSprite.position = ccp(itemSprite.position.x + ssipadauto(5), itemSprite.position.y - [itemSprite boundingBox].size.height + ssipadauto(2));
                [self addChild: statusSprite z:2];
                
                NSString * lockNumber = [NSString stringWithFormat:@"%d", (itemLevel)];
                CCLabelBMFont * lockNum = [CCLabelBMFont labelWithString:lockNumber fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
                //lockNum.color = CC3_COLOR_RED;
                lockNum.position = ccp([statusSprite boundingBox].size.width/2, [statusSprite boundingBox].size.height/2 - ssipadauto(6));
                [statusSprite addChild: lockNum];
                
                NSString * lockMessage = nil;
                
                if (itemLevel > 1) {
                    lockMessage = [NSString stringWithFormat:@"*Complete %d levels to unlock or get it early!", (itemLevel)];
                } else {
                    lockMessage = [NSString stringWithFormat:@"*Complete %d level to unlock or get it early!", (itemLevel)];
                }
                
                statusLabel = [CCLabelBMFont labelWithString:lockMessage fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
                statusLabel.scale = 0.6f;
                statusLabel.anchorPoint = ccp(0,1);
                statusLabel.color = CC3_COLOR_CANTALOPE;
                statusLabel.position = ccp(itemSprite.position.x - ssipadauto(9), statusSprite.position.y - [statusSprite boundingBox].size.height/2 - ssipad(2,0));
                [self addChild: statusLabel];
                
                priceButtonY = statusLabel.position.y - ssipad(14, 8);
                buttonImg = @"Button_Play.png";
            } else if (itemStatus == kStoreItemUnlocked) {
                // show as new item
                statusSprite = [CCSprite spriteWithFile:@"new.png"];
                statusSprite.scale = 0.5;
                statusSprite.position = ccp(itemSprite.position.x + ssipadauto(5), itemSprite.position.y - [itemSprite boundingBox].size.height + ssipadauto(2));
                [self addChild: statusSprite z:2];
            }
            
            if (itemType == kStoreBankType) {
                priceButtonY = itemSprite.position.y - [itemSprite boundingBox].size.height - ssipadauto(20);
                buttonImg = @"Button_Play.png";
            }
            
            // Show price button needed to purchase the item                
            selectButton = [GPImageButton controlOnTarget:self andSelector:@selector(buyMe) imageFromFile:buttonImg];
            selectButton.position = ccp(self.contentSize.width - [selectButton boundingBox].size.width - ssipad(120, 50), priceButtonY);
            selectButton.scale = 0.60f;
            [self addChild:selectButton];
            
            CCNode * myPrice = [CCNode node];
            
            if (itemType != kStoreBankType) {
                
                CCLabelBMFont * coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%.f", itemPrice] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
                coins.position = ccp(ssipadauto(8), 0);
                
                CCSprite *coinImg = [CCSprite spriteWithSpriteFrameName:@"Coin1_2.png"];
                coinImg.scale = 0.5;
                coinImg.position = ccp(-([coins boundingBox].size.width/2), 0);
                
                [myPrice addChild: coinImg];
                [myPrice addChild: coins];
            } else {
                
                CCLabelBMFont * price = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%.2f", itemPrice] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
                price.position = ccp(ssipadauto(5), 0);
                
                CCLabelBMFont * dollarSign = [CCLabelBMFont labelWithString: @"$" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
                dollarSign.position = ccp(-[price boundingBox].size.width/2, -[price boundingBox].size.height/2 + ssipadauto(2));
                
                [myPrice addChild: dollarSign];
                [myPrice addChild: price];
            }
            
            [selectButton addChild: myPrice];
        }
    }
}

- (void) refresh {
    
    [self createStatusAndPriceControls];
}

- (void) chooseMe {
    [itemParent select: self];
}

- (void) buyMe {
    [itemParent buy: self];
}


@end
