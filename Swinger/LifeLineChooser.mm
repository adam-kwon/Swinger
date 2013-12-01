//
//  LifeLineChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 9/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LifeLineChooser.h"
#import "LifeLineData.h"
#import "StoreItem.h"
#import "Macros.h"
#import "UserData.h"
#import "GPImageButton.h"

@implementation LifeLineChooser

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
        
        // create life line item
        CCArray * lifeLines = [storeData lifeLineData];
        items = [[CCArray alloc] initWithCapacity:[lifeLines count]];
        
        for (LifeLineData * phb in lifeLines) {
            if (phb.price == 0.0f) {
                continue;
            }
            
            StoreItem * item = [StoreItem make: [CCSprite spriteWithSpriteFrameName: phb.spriteName]
                                          size: CGSizeMake(self.contentSize.width, rowHeight)
                                        parent: self
                                          type: kStoreLifeLineType 
                                        itemId: phb.numLives
                                          name: [NSString stringWithFormat: phb.numLives > 1 ? @"%d Life Lines" : @"%d Life Line", phb.numLives] 
                                   description: phb.description
                                     productId: phb.description
                                         price: phb.price
                                        status: kStoreItemOnSale
                                         level: 0];
            
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

- (BOOL) select:(StoreItem *)item {
    
    CCLOG(@"%@ was selected!", item.itemName);
    
    return YES;
}

/*- (BOOL) buy:(StoreItem *)item {
    CCLOG(@"%@ was bought!", item.itemName);
    return YES;
}*/

- (void) refresh {
    
}

@end
