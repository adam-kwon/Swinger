//
//  GPLabel.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 9/7/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPControl.h"

@interface GPLabel : CCNode<CCTargetedTouchDelegate, GPControl> {
    CCLabelBMFont               *label;
    CCSprite                    *labelImage;
    CGPoint                     originalPosition;
    float                       originalScale;
    id                          target;
    SEL                         selector;
    BOOL                        touched;
    id                          param;
    int                         touchPriority;
    BOOL                        enabled;
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)fontFile withString:(NSString*)str withObject:(id)obj touchPriority:(int)priority;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str withObject:(id)obj;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str touchPriority:(int)priority;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str withObject:(id)obj;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str touchPriority:(int)priority;
+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str;

- (void) setLabelImage:(CCSprite*)image;
- (void) startProcessingTouch;
- (void) stopProcessingTouch;
- (CGRect) boundingBox;
- (void) setColor:(ccColor3B)color;
- (void) setScale:(float)scale;
- (void) centerWidthAtY:(float)y;
- (void) alignLeftAtY:(float)y padding:(float)padding;
- (void) setAnchorPoint:(CGPoint)anchorPoint;
// Searches for substring and sets it to a color.
// Example:
// String is "Testing 123 hello"
// [obj setColorSubString:@"123" color:FONT_COLOR_RED];
// Will set "123" to color red.
- (void) setColorSubString:(NSString*)str color:(ccColor3B)c;

// Search for first occurence of string, and sets everything after that to a color.
// Example:
// String is "Testing 123 hello"
// [obj setColorSubStringIndexOf:@" " color:FONT_COLOR_RED];
// Will set "123 hello" to red.
- (void) setColorSubStringIndexOf:(NSString*)str color:(ccColor3B)c;


@property (nonatomic, readwrite, assign) CGPoint originalPosition;
@property (nonatomic, readwrite, assign) BOOL enabled;
@end
