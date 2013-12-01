//
//  GPDialog.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 11/9/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPDialog.h"
#import "GPUtil.h"
#import "Macros.h"
#import "GPButton.h"
#import "CCLabelBMFont+withColor.h"
#import "CCLayerColor+extension.h"
#import "GPDummyControl.h"
#import "AudioEngine.h"
#import "Globals.h"

@implementation GPDialog 
@synthesize texts;
@synthesize title;
@synthesize fontScale;
@synthesize content;
@synthesize touchPriority;
@synthesize size;
@synthesize matrixTheme;

- (void) dealloc {
    NSLog(@"**** GPDialog dealloc");
    [super dealloc];
}
- (void) removeSelf {
    [self unschedule:@selector(removeSelf)];
    [self removeFromParentAndCleanup:YES];    
}

- (void) slideOutFromBottom {
    //[[AudioEngine sharedEngine] playEffect:@SND_MACHINE gain:[UserData sharedInstance].fxVolumeLevel];
    id slideUp = [CCMoveTo actionWithDuration:0.8f position:ccp(0, [[CCDirector sharedDirector] winSize].height)];
    id ease = [CCEaseExponentialOut actionWithAction:slideUp];
    id callback = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];
    id seq = [CCSequence actions:ease, callback, nil];

    [self runAction:seq];
}

- (void) okCallback:(id)param {
    if (target != nil) {
        [target performSelector:callBack withObject:param];
    }
    if (isFullScreen) {
        [self schedule:@selector(removeSelf) interval:1.0];
    } else {
        [self removeSelf];
    }
}

- (void) cancelCallback:(id)param {
    if (cancelCallBack != nil) {
        [target performSelector:cancelCallBack withObject:param];
    }
    if (isFullScreen) {
        [self slideOutFromBottom];
    } else {
        [self removeFromParentAndCleanup:YES];
    }
}

- (void) slideInFromTop {
    //[[AudioEngine sharedEngine] playEffect:@SND_MACHINE gain:[UserData sharedInstance].fxVolumeLevel];
    id slideDown = [CCMoveTo actionWithDuration:0.8f position:ccp(0, 0)];
    id ease = [CCEaseExponentialOut actionWithAction:slideDown];
    [self runAction:ease];    
}

- (void) addButtons {
    ccColor4B lineColor = ccc4(255, 165, 0, 255);
    if (matrixTheme) {
        lineColor = ccc4(0, 255, 0, 255);
    }
    
    ccColor3B fontColor = CC3_COLOR_WHITE;
    ccColor3B borderColor = CC3_COLOR_ORANGE;
    
    if (matrixTheme) {
        fontColor = CC3_COLOR_GREEN;
        borderColor = CC3_COLOR_GREEN;
    }
    
    CCLayerColor *line = [CCLayerColor layerWithColor:lineColor];
    if (isFullScreen) {
        [line setContentSize:CGSizeMake(g_isIpad ? 800 : 400, 1)];        
    } else {
        [line setContentSize:CGSizeMake(g_isIpad ? 500 : 350, 1)];
    }
    line.position = ccp(171, g_isIpad ? 104 : 52);
    line.position = [GPUtil centerWidth:line inParent:layer];
    [layer addChild:line];

    if (okText == nil && cancelText == nil) {
        GPButton *okButton = [GPButton controlOnTarget:self 
                                              selector:@selector(okCallback:) 
                                            withObject:callBackObj
                                                  text:@"OK"
                                           borderWidth:1
                                           borderColor:borderColor
                                                 color:fontColor
                                                  xPad:80
                                                  yPad:ssautores(10)
                                                 scale:ssautores(0.5)
                                         touchPriority:touchPriority];
        
        okButton.position = ccp([layer boundingBox].size.width/2 - okButton.size.width/2, ssipadauto(10));
        [layer addChild:okButton];            
    } else if (cancelText == nil) {
        GPButton *okButton = [GPButton controlOnTarget:self 
                                              selector:@selector(okCallback:) 
                                            withObject:callBackObj
                                                  text:okText
                                           borderWidth:1
                                           borderColor:borderColor
                                                 color:fontColor
                                                  xPad:80
                                                  yPad:(10)
                                                 scale:ssautores(0.5) 
                                         touchPriority:touchPriority];
        
        okButton.position = ccp([layer boundingBox].size.width/2 - okButton.size.width/2, ssipadauto(10));
        [layer addChild:okButton];            
    } else {   
        GPButton *okButton = [GPButton controlOnTarget:self 
                                              selector:@selector(okCallback:) 
                                            withObject:callBackObj
                                                  text:okText
                                           borderWidth:1
                                           borderColor:borderColor
                                                 color:fontColor
                                                  xPad:80
                                                  yPad:ssautores(10)
                                                 scale:ssautores(0.5) 
                                         touchPriority:touchPriority];
        
        GPButton *cancelButton = [GPButton controlOnTarget:self 
                                                  selector:@selector(cancelCallback:)
                                                withObject:callBackObj
                                                      text:cancelText
                                               borderWidth:1
                                               borderColor:borderColor
                                                     color:fontColor
                                                      xPad:80
                                                      yPad:ssautores(10)
                                                     scale:ssautores(0.5) 
                                             touchPriority:touchPriority];
        
        float totalSize = okButton.size.width + ssipadauto(10) + cancelButton.size.width;
        float startX = [layer boundingBox].size.width/2 - totalSize/2;
        okButton.position = ccp(startX, ssipadauto(10));
        cancelButton.position = ccp(startX + okButton.size.width + ssipadauto(10), ssipadauto(10));
        [layer addChild:okButton];
        [layer addChild:cancelButton];
        
    }     
    
    GPDummyControl *dummyControl = [GPDummyControl nodeWithTouchPriority:touchPriority+1 swallow:YES];
    [self addChild:dummyControl];
}

- (CCLayerColor*) getBorder {
    CCLayerColor *borderLayer;
    if (isFullScreen) {
        borderLayer = [CCLayerColor getFullScreenLayerWithColor:ccc4(0, 0, 0, 255)];
        borderLayer.anchorPoint = CGPointZero;
        self.position = ccp(0, [[CCDirector sharedDirector] winSize].height);
    } else {
        CCLayerColor *back = [CCLayerColor getFullScreenLayerWithColor:ccc4(0, 0, 0, 100)];
        back.anchorPoint = CGPointZero;
        back.position = CGPointZero;
        [self addChild:back];
        
        borderLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 20)];
        [borderLayer setContentSize:CGSizeMake(g_isIpad ? 840 : 450, g_isIpad ? 600 : 290)];
        borderLayer.anchorPoint = ccp(0, 0);
        borderLayer.position = [GPUtil center:borderLayer];        
    }
        
//    CCSprite *rivet1 = [CCSprite spriteWithSpriteFrameName:@"Rivet.png"];
//    CCSprite *rivet2 = [CCSprite spriteWithSpriteFrameName:@"Rivet.png"];
//    CCSprite *rivet3 = [CCSprite spriteWithSpriteFrameName:@"Rivet.png"];
//    CCSprite *rivet4 = [CCSprite spriteWithSpriteFrameName:@"Rivet.png"];
//    
//    rivet1.position = ccp(20, [borderLayer boundingBox].size.height - 20); 
//    
//    rivet2.position = ccp([borderLayer boundingBox].size.width - 20, [borderLayer boundingBox].size.height - 20); 
//    
//    rivet3.position = ccp(20, 20); 
//    
//    rivet4.position = ccp([borderLayer boundingBox].size.width - 20, 20); 
//    
//    rivet1.position = ccp(20, [borderLayer boundingBox].size.height - 20); 
//    [borderLayer addChild:rivet1];
//    
//    rivet2.position = ccp([borderLayer boundingBox].size.width - 20, [borderLayer boundingBox].size.height - 20); 
//    [borderLayer addChild:rivet2];
//    
//    rivet3.position = ccp(20, 20); 
//    [borderLayer addChild:rivet3];
//    
//    rivet4.position = ccp([borderLayer boundingBox].size.width - 20, 20); 
//    [borderLayer addChild:rivet4];

    return borderLayer;
}

- (void) buildWithContentNode {
    [layer addChild:content];
    
    [self addButtons];
}

- (void) buildScreen {
    CCLabelBMFont *titleLbl = [CCLabelBMFont labelWithString:title fntFile:sshires(FONT_ARIAL_ROUND_MT_BOLD, FONT_ARIAL_ROUND_MT_BOLD)];
    titleLbl.color = CC3_COLOR_ORANGE;
    titleLbl.position = ccp([layer boundingBox].size.width/2, [layer boundingBox].size.height - [titleLbl boundingBox].size.height);
    titleLbl.position = [GPUtil centerWidthDefaultAnchor:titleLbl inParent:layer];
    [layer addChild:titleLbl];
    
//    int start = 464;
//    int start = g_isIpad ? 124 : 77;
    int start = 0;
    int totalDelta = 0;
    CCNode *node = [CCNode node];
    for (int i = [texts count] - 1; i >= 0; i--) {
        CCLabelBMFont *fnt;
        if ([[texts objectAtIndex:i] isKindOfClass:[NSString class]]) {
            fnt = [CCLabelBMFont labelWithString:[texts objectAtIndex:i] fntFile:sshires(FONT_ARIAL_ROUND_MT_BOLD, FONT_ARIAL_ROUND_MT_BOLD)];            
        } else {
            fnt = [texts objectAtIndex:i];
        }
//        fnt.anchorPoint = ccp(0.5, 1);
        fnt.scale = fontScale;
        fnt.position = ccp([layer boundingBox].size.width/2, start);
        start += [fnt boundingBox].size.height;
        totalDelta += ([fnt boundingBox].size.height);
        [node addChild:fnt];
    }
    if ([texts count] == 1) {
        node.position = ccp(node.position.x, [layer boundingBox].size.height/2 + ssipad(10, 10));
    } else {
        node.position = ccp(node.position.x,([layer boundingBox].size.height / 2 ) - (totalDelta/2));
    }
    [layer addChild:node];
    

    [self addButtons];
}

- (id) initOnTarget:(id)pTarget 
         okCallBack:(SEL)pSelector cancelCallBack:(SEL)pCancelSel okText:(NSString*)pOkText 
         cancelText:(NSString*)pCancelText withObject:(id)pObj isFullScreen:(BOOL)fullScreen {
    
    if ((self = [super init])) {
        target = pTarget;
        callBack = pSelector;
        cancelCallBack = pCancelSel;
        callBackObj = pObj;
        okText = pOkText;
        cancelText = pCancelText;
        fontScale = ssautores(0.5);
        isFullScreen = fullScreen;
        touchPriority = TOUCH_PRIORITY_TOP-500;
        layer = [self getBorder];
        size = [layer boundingBox].size;
        [self addChild:layer];
    }
    
    return self;    
}

+ (id) controlOnTarget:(id)pTarget 
            okCallBack:(SEL)pSelector 
        cancelCallBack:(SEL)pCancelSel okText:(NSString *)pOkText cancelText:(NSString *)pCancelText withObject:(id)obj {
    
    return [GPDialog controlOnTarget:pTarget 
                          okCallBack:pSelector 
                      cancelCallBack:pCancelSel 
                              okText:pOkText 
                          cancelText:pCancelText 
                          withObject:obj 
                        isFullScreen:NO];
}

+ (id) controlOnTarget:(id)pTarget 
            okCallBack:(SEL)pSelector 
        cancelCallBack:(SEL)pCancelSel 
                okText:(NSString*)pOkText 
            cancelText:(NSString*)pCancelText 
            withObject:(id)obj
          isFullScreen:(BOOL)fullScreen {
    
    return [[[self alloc] initOnTarget:pTarget 
                            okCallBack:pSelector 
                        cancelCallBack:pCancelSel 
                                okText:pOkText 
                            cancelText:pCancelText 
                            withObject:obj 
                          isFullScreen:fullScreen] autorelease];
}


	

@end
