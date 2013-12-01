//
//  GPButton.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/15/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPButton.h"
#import "GPUtil.h"
#import "GPImageButton.h"
#import "Constants.h"

@implementation GPButton
@synthesize originalPosition;
@synthesize size;

- (id) initOnTarget:(id)t 
           selector:(SEL)s 
         withObject:(id)obj
               text:(NSString*)text 
        borderWidth:(int)width 
        borderColor:(ccColor3B)color 
              color:(ccColor3B)fontColor
        absXPadding:(BOOL)absSize
               xPad:(float)xPad 
               yPad:(float)yPad 
              scale:(float)scale
      touchPriority:(int)priority {

    self = [super init];
    if (self) {
        CCSprite *sprite = [GPUtil createButtonWithText:text 
                                            borderWidth:width 
                                            borderColor:color 
                                                  color:fontColor 
                                            absXPadding:absSize
                                               xPadding:xPad yPadding:yPad scale:scale];
        button = [GPImageButton controlOnTarget:t andSelector:s withObject:obj imageFromSprite:sprite withTouchPriority:priority];
        originalPosition = self.position;
        [self addChild:button];
        size = button.size;
    }
    
    return self;
}

+ (id) controlOnTarget:(id)t 
              selector:(SEL)s 
            withObject:(id)obj
                  text:(NSString*)text 
           borderWidth:(int)width 
           borderColor:(ccColor3B)color 
                 color:(ccColor3B)fontColor
                  xPad:(float)xPad 
                  yPad:(float)yPad 
                 scale:(float)scale
         touchPriority:(int)priority {

    return [GPButton controlOnTarget:t 
                            selector:s 
                          withObject:obj 
                                text:text
                         borderWidth:width 
                         borderColor:color 
                               color:fontColor 
                         absXPadding:NO
                                xPad:xPad 
                                yPad:yPad 
                               scale:scale 
                       touchPriority:priority];

}

+ (id) controlOnTarget:(id)t 
              selector:(SEL)s 
            withObject:(id)obj
                  text:(NSString*)text 
           borderWidth:(int)width 
           borderColor:(ccColor3B)color 
                 color:(ccColor3B)fontColor
           absXPadding:(BOOL)absSize
                  xPad:(float)xPad 
                  yPad:(float)yPad 
                 scale:(float)scale
         touchPriority:(int)priority {

    return [[[self alloc] initOnTarget:t 
                              selector:s 
                            withObject:obj 
                                  text:text
                           borderWidth:width 
                           borderColor:color 
                                 color:fontColor 
                           absXPadding:absSize
                                  xPad:xPad 
                                  yPad:yPad 
                                 scale:scale 
                         touchPriority:priority] autorelease];

}

- (void) setEnabled:(BOOL)enabled {
    button.enabled = enabled;
}
- (CGPoint) getOriginalPosition {
    return originalPosition;
}

@end
