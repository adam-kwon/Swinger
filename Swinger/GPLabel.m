//
//  GPLabel.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 9/7/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPLabel.h"
#import "Globals.h"
#import "Constants.h"
#import "AudioEngine.h"
#import "CCLabelBMFont+withColor.h"
#import "UserData.h"

@implementation GPLabel 
@synthesize originalPosition;
@synthesize enabled;

- (id)initOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str withObject:(id)obj touchPriority:(int)priority {
    if ((self = [super init])) {
        target = t;
        selector = s;
        enabled = YES;
        label = [CCLabelBMFont labelWithString:str fntFile:font];
        originalScale = 1.0; //ssautores(0.5);
        self.scale = originalScale; 
        originalPosition = self.position;
        param = obj;
        touched = NO;
        touchPriority = priority;
        [self addChild:label];
    }
    
    return self;
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)fontFile withString:(NSString*)str withObject:(id)obj touchPriority:(int)priority {
    return [[[self alloc] initOnTarget:t andSelector:s fontFile:fontFile withString:str withObject:obj touchPriority:priority] autorelease];
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)fontFile withString:(NSString*)str withObject:(id)obj {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:fontFile withString:str withObject:obj touchPriority:TOUCH_PRIORITY_HIGHEST];
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str touchPriority:(int)priority {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:font withString:str withObject:str touchPriority:priority];        
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s fontFile:(NSString*)font withString:(NSString*)str {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:font withString:str withObject:nil touchPriority:TOUCH_PRIORITY_HIGHEST];    
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str withObject:(id)obj {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:sshires(FONT_DEFAULT, FONT_DEFAULT) 
                         withString:str withObject:nil touchPriority:TOUCH_PRIORITY_HIGHEST];
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:sshires(FONT_HOBO_64, FONT_HOBO_32) 
                         withString:str withObject:nil touchPriority:TOUCH_PRIORITY_HIGHEST];
}

+ (id) controlOnTarget:(id)t andSelector:(SEL)s withString:(NSString*)str touchPriority:(int)priority {
    return [GPLabel controlOnTarget:t andSelector:s fontFile:sshires(FONT_HOBO_64, FONT_HOBO_32) 
                         withString:str withObject:nil touchPriority:priority];
}

- (void) setAnchorPoint:(CGPoint)anchorPoint {
    label.anchorPoint = anchorPoint;
}


// Searches for substring and sets it to a color.
// Example:
// String is "Testing 123 hello"
// [obj setColorSubString:@"123" color:FONT_COLOR_RED];
// Will set "123" to color red.
- (void) setColorSubString:(NSString*)str color:(ccColor3B)c {
    [label setColorSubString:str color:c];
}

// Search for first occurence of string, and sets everything after that to a color.
// Example:
// String is "Testing 123 hello"
// [obj setColorSubStringIndexOf:@" " color:FONT_COLOR_RED];
// Will set "123 hello" to red.
- (void) setColorSubStringIndexOf:(NSString*)str color:(ccColor3B)c {
    [label setColorSubStringIndexOf:str color:c];
}


- (void) setColor:(ccColor3B)color {
    label.color = color;
}

- (void) setScale:(float)scale {
    originalScale = scale;
    super.scale = scale;
}

- (CGPoint) getOriginalPosition {
    return originalPosition;
}


- (CGRect) boundingBox {
    return [label boundingBox];
}

- (CGRect) rectInPixel {
    CGSize s = [label boundingBox].size;
//    return CGRectMake(label.position.x + -(s.width)/2, label.position.y + -(s.height)/2, s.width, s.height);
    
    return CGRectMake(label.position.x + -(s.width*label.anchorPoint.x), label.position.y + -(s.height*label.anchorPoint.y), s.width, s.height);
}

- (BOOL) containsTouchLocation:(UITouch*)touch {
    CGPoint p = [self convertTouchToNodeSpace:touch];
    CGRect r = [self rectInPixel];
    return CGRectContainsPoint(r, p);
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"ENABLED = %d", enabled);
    if (!self.visible || selector == nil) return NO;
    if (!enabled) return NO;
    
    if ([self containsTouchLocation:touch]) {
        if (target != nil) {
            id grow = [CCScaleTo actionWithDuration:0.05 scale:originalScale + 0.04];
            [self runAction:grow];
        }
        touched = YES;
    }
	return YES;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.visible || selector == nil) return;
    if (!enabled) return;
    if (target != nil) {
        id shrink = [CCScaleTo actionWithDuration:0.05 scale:originalScale];
        [self runAction:shrink];
    }
    if (touched) {
        if (!g_block) {
            g_block = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"globalLock" object:nil];
            [[AudioEngine sharedEngine] playEffect:SND_BLOP gain:[UserData sharedInstance].fxVolumeLevel];
            [target performSelector:selector withObject:param];
            touched = NO;
        }
    }
}

- (void) centerWidthAtY:(float)y {
    CCNode *parent = [self parent];
    if (labelImage == nil) {
        self.position = ccp([parent boundingBox].size.width/2, y);    
    } else {
        float totalWidth = [labelImage boundingBox].size.width + [label boundingBox].size.width;
        self.position = ccp(([parent boundingBox].size.width - totalWidth)/2, y);
    }
}

- (void) alignLeftAtY:(float)y padding:(float)padding {
    CCNode *parent = [self parent];
    float diff = ([parent boundingBox].size.width - [label boundingBox].size.width*self.scale)/2;
    self.position = ccp(padding + [parent boundingBox].size.width/2 - diff, y);
}

- (void) setLabelImage:(CCSprite*)image {
    labelImage = image;
    image.anchorPoint = ccp(0, 0.5);
    image.position = ccp(image.position.x, image.position.y + ssipad(10, 5));
    label.anchorPoint = ccp(0, 0.5);
    [self addChild:image];
    label.position = ccp([image boundingBox].size.width, label.position.y);
}


- (void) startProcessingTouch {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:touchPriority swallowsTouches:NO];    
}

- (void) stopProcessingTouch {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];    
}


- (void) onEnter {
    CCLOG(@"**** GPLabel onEnter");
    [self startProcessingTouch];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** GPLabel onExit");
    [self stopProcessingTouch];
	[super onExit];
}	

- (void) dealloc {
    CCLOG(@"**** GPLabel dealloc");
    [super dealloc];
}

@end
