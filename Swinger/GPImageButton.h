//
//  GPImageButton.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 9/8/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//
//  Image Button Control

#import "GPControl.h"

@interface GPImageButton : CCNode<CCTargetedTouchDelegate, GPControl> {
    id          param;
    id          target;
    SEL         selector;
    int         touchPriority;
    CCSprite    *button;
    BOOL        enabled;
    BOOL        touchDelegateAdded;
    CGPoint     originalPosition;
    CCLabelBMFont* buttonText;
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
         imageFromFile:(NSString*)fileName 
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority;

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
         imageFromFile:(NSString*)fileName;

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
         imageFromFile:(NSString*)fileName;

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
         imageFromFile:(NSString*)fileName 
     withTouchPriority:(int)priority;

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
       imageFromSprite:(CCSprite*)sprite;


+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
       imageFromSprite:(CCSprite*)sprite;

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority;


+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority;


- (void) setOpacity:(GLubyte)opacity;
- (void) setScale:(float)scale;
- (void) setSwallows:(BOOL)swallows;
- (void) setText:(CCLabelBMFont*)text;
- (void) setTextColor:(ccColor3B)color;
- (CGSize) size;

@property (nonatomic, readwrite, assign) CGPoint originalPosition;
@property (nonatomic, readwrite, assign) BOOL enabled;
@end
