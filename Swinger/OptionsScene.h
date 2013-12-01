//
//  StoreItemContainer.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "GPImageButton.h"

@interface OptionsScene : CCNode {
    
    CGSize screenSize;
    
    CCSprite *music;
    //GPImageButton *musicBtn;
    CCSprite *soundFx;
    //GPImageButton *soundFxBtn;
    
    /*CCSprite *facebook;
    CCSprite *twitter;
    CCSprite *youtube;*/
}

+ (id) node;

@end
