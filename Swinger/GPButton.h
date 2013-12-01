//
//  GPButton.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/15/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPControl.h"
#import "GPUtil.h"

@class GPImageButton;

@interface GPButton : CCNode<GPControl> {
    CGPoint         originalPosition;
    CGSize          size;
    GPImageButton   *button;
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
         touchPriority:(int)priority;

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
         touchPriority:(int)priority;


- (void) setEnabled:(BOOL)enabled;

@property (nonatomic, readwrite, assign) CGPoint originalPosition;
@property (nonatomic, readwrite, assign) CGSize size;
@end
