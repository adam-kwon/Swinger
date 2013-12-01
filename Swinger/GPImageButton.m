//
//  GPImageButton.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 9/8/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPImageButton.h"
#import "Constants.h"
#import "AudioEngine.h"
#import "Notifications.h"
#import "Globals.h"
#import "UserData.h"


@implementation GPImageButton
@synthesize originalPosition;
@synthesize enabled;

- (id) initOnTarget:(id)t 
        andSelector:(SEL)s 
         withObject:(id)obj 
      imageFromFile:(NSString *)fileName 
    imageFromSprite:(CCSprite*)sprite 
  withTouchPriority:(int)priority {
    
    if ((self = [super init])) {
        enabled = YES;
        target = t;
        selector = s;
        param = obj;
        touchPriority = priority;
        if (nil != fileName) {
            button = [CCSprite spriteWithFile:fileName];
        } else {
            button = sprite;
        }
        //button.anchorPoint = ccp(0, 0);
        button.position = ccp(0, 0);
        [self addChild:button];
    }
    
    return self;
}

- (void) setScale:(float)scale {
    button.scale = scale;
}

- (CGSize) size {
    return [button boundingBox].size;
}

- (void) setText:(CCLabelBMFont*)text {
    text.position = CGPointMake([self size].width/2, [self size].height/2);
    [button addChild:text];
    buttonText = text;
}

- (void) setTextColor: (ccColor3B) color {
    buttonText.color = color;
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
         imageFromFile:(NSString*)fileName 
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority {
 
    return [[[self alloc] initOnTarget:t andSelector:s withObject:obj imageFromFile:fileName imageFromSprite:sprite withTouchPriority:priority] autorelease];    
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
         imageFromFile:(NSString *)fileName {
    
    return [GPImageButton controlOnTarget:t andSelector:s withObject:obj imageFromFile:fileName imageFromSprite:nil withTouchPriority:TOUCH_PRIORITY_HIGHEST+1];
}

+ (id) controlOnTarget:(id)t
           andSelector:(SEL)s 
         imageFromFile:(NSString*)fileName {
    
    return [GPImageButton controlOnTarget:t andSelector:s withObject:nil imageFromFile:fileName imageFromSprite:nil withTouchPriority:TOUCH_PRIORITY_HIGHEST+1];
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
         imageFromFile:(NSString*)fileName 
     withTouchPriority:(int)priority {
    
    return [GPImageButton controlOnTarget:t andSelector:s withObject:nil imageFromFile:fileName imageFromSprite:nil withTouchPriority:priority];    
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
       imageFromSprite:(CCSprite*)sprite {
    
    return [GPImageButton controlOnTarget:t andSelector:s withObject:nil imageFromFile:nil imageFromSprite:sprite withTouchPriority:TOUCH_PRIORITY_HIGHEST+1];        
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj 
       imageFromSprite:(CCSprite*)sprite {

    return [GPImageButton controlOnTarget:t andSelector:s withObject:obj imageFromFile:nil imageFromSprite:sprite withTouchPriority:TOUCH_PRIORITY_HIGHEST+1];        
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority {
    return [GPImageButton controlOnTarget:t andSelector:s withObject:nil imageFromFile:nil imageFromSprite:sprite withTouchPriority:priority];
}

+ (id) controlOnTarget:(id)t 
           andSelector:(SEL)s 
            withObject:(id)obj
       imageFromSprite:(CCSprite*)sprite 
     withTouchPriority:(int)priority {
    return [GPImageButton controlOnTarget:t andSelector:s withObject:obj imageFromFile:nil imageFromSprite:sprite withTouchPriority:priority];    
}

- (CGPoint) getOriginalPosition {
    return originalPosition;
}

- (void) setOpacity:(GLubyte)opacity {
    button.opacity = opacity;
}

- (void) setSwallows:(BOOL)swallows {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:touchPriority swallowsTouches:swallows];
    touchDelegateAdded = YES;
}

- (void) onEnter {
    if (!touchDelegateAdded) {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:touchPriority swallowsTouches:NO];
    }
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** GPImageButton onExit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (CGRect) rectInPixel {
    CGSize s = [button boundingBox].size;
    //CCLOG(@"x=%f y=%f, width=%f height=%f", button.position.x, button.position.y, s.width, s.height);
    return CGRectMake(button.position.x + -(s.width*button.anchorPoint.x), 
                      button.position.y + -(s.height*button.anchorPoint.y), 
                      s.width, 
                      s.height);

}

- (BOOL) containsTouchLocation:(UITouch*)touch {
    CGPoint p = [self convertTouchToNodeSpace:touch];
    CGRect r = [self rectInPixel];
    BOOL doesContainIt = CGRectContainsPoint(r, p);
    //CCLOG(@"GPImageButton touchX=%f touchY=%f contains it? %d isblock=%d", p.x, p.y, doesContainIt, g_block);
    return doesContainIt;
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

- (void) buttonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GLOBAL_LOCK object:nil];
    if (target != nil) {
        [target performSelector:selector withObject:param];    
    }    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.visible) return;
    if (!enabled) return;
    if ([self containsTouchLocation:touch] && !g_block) {
        g_block = YES;
        id press = [CCScaleTo actionWithDuration:0.05 scaleX:self.scaleX - 0.1 scaleY:self.scaleY -  0.1];
        id press2 = [CCScaleTo actionWithDuration:0.05 scaleX:self.scaleX + 0.05 scaleY:self.scaleY + 0.05];
        id press3 = [CCScaleTo actionWithDuration:0.02 scaleX:self.scaleX - 0.05 scaleY:self.scaleY - 0.05];
        id press4 = [CCScaleTo actionWithDuration:0.02 scaleX:self.scaleX + 0.02 scaleY:self.scaleY + 0.02];
        id press5 = [CCScaleTo actionWithDuration:0.02 scaleX:self.scaleX - 0.02 scaleY:self.scaleY - 0.02];
        id press6 = [CCScaleTo actionWithDuration:0.02 scaleX:self.scaleX scaleY:self.scaleY];
        id cb = [CCCallFunc actionWithTarget:self selector:@selector(buttonPressed)];
        id seq = [CCSequence actions:press, press2, press3, press4, press5, press6, cb, nil];
        [self runAction:seq];
        [[AudioEngine sharedEngine] playEffect:SND_BLOP gain:[UserData sharedInstance].fxVolumeLevel];        

    }
}

- (void) dealloc {
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    buttonText = nil;
    
    [super dealloc];
}

@end
