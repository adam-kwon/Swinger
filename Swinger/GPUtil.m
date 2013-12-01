//
//  GPUtil.m
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "GPUtil.h"
#import "Constants.h"
#import "CCLabelBMFont+withColor.h"
#import "Macros.h"
#import "Globals.h"

@implementation GPUtil

+ (double) randomFrom:(double)n1 to:(double)n2 {
    double diff = n2 - n1;
    double r = n1 + (((double)arc4random()) / 0xFFFFFFFFu)*diff;
    return r;
}

+ (CCSprite*) createButtonWithText:(NSString*)levelStr 
                       borderWidth:(float)borderWidth 
                       borderColor:(ccColor3B)color 
                             color:(ccColor3B)fontColor
                       absXPadding:(BOOL)absSize
                          xPadding:(float)xPadding 
                          yPadding:(float)yPadding
                             scale:(float)scale {
    
    CCLabelBMFont *font = [CCLabelBMFont labelWithString:levelStr fntFile:FONT_ARIAL_ROUND_MT_BOLD scale:scale];
    
    float w = [font boundingBox].size.width + xPadding;
    if (absSize) {
        w = xPadding;
    }
    float h = [font boundingBox].size.height + yPadding;
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:w+1 height:h+1];
    
    [rt beginWithClear:0 g:0 b:0 a:0];
    
    CGPoint box[5];
    box[0] = ccp(borderWidth, borderWidth);
    box[1] = ccp(w-borderWidth, borderWidth);
    box[2] = ccp(w-borderWidth, h-borderWidth);
    box[3] = ccp(borderWidth, h-borderWidth);
    
    glColor4ub(color.r, color.g, color.b, 255);
    glLineWidth(borderWidth);
    ccDrawPoly(box, 4, YES);
    glLineWidth(1);
    glColor4ub(255, 255, 255, 255);
    
    CCLabelBMFont *button = [CCLabelBMFont labelWithString:[font string] fntFile:FONT_ARIAL_ROUND_MT_BOLD];
    button.scale = font.scale;
    button.color = fontColor;
    float yOffSet = ssall(5, 3, 2);
    float xOffset = ssall(1, 1, 0);
    button.position = ccp(w/2-xOffset, h/2-yOffSet);
    [button visit];
    
    [rt end];
    
    CCSprite *sprite = [CCSprite spriteWithTexture:rt.sprite.texture];
    sprite.flipY = YES;
    return sprite;  
}

+ (CCSprite*) createButtonWithText:(NSString*)levelStr 
                       borderWidth:(float)borderWidth 
                       borderColor:(ccColor3B)color
                       absXPadding:(BOOL)absSite
                          xPadding:(float)xPdding 
                          yPadding:(float)yPadding 
                             scale:(float)scale {
    return [GPUtil createButtonWithText:levelStr borderWidth:borderWidth borderColor:color color:CC3_COLOR_WHITE 
                            absXPadding:NO
                               xPadding:xPdding yPadding:yPadding scale:scale];
}


+ (CCSprite*) createButtonWithText:(NSString*)levelStr 
                       borderWidth:(float)borderWidth 
                       borderColor:(ccColor3B)color 
                          xPadding:(float)xPdding 
                          yPadding:(float)yPadding {
    
    return [GPUtil createButtonWithText:levelStr borderWidth:borderWidth  
                            borderColor:color color:CC3_COLOR_WHITE 
                            absXPadding:NO
                               xPadding:xPdding yPadding:yPadding scale:sshires(0.3,0.6)];
}

#pragma mark Centering
+ (CGPoint) center:(CCNode*)node {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    node.anchorPoint = ccp(0, 0);
    
    CGPoint center = ccp((screenSize.width - [node boundingBox].size.width) / 2,
                         (screenSize.height - [node boundingBox].size.height) / 2);
    return center;
}

+ (CGPoint) centerWidth:(CCNode*)node {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    node.anchorPoint = ccp(0, 0);
    CGPoint center = ccp((screenSize.width - [node boundingBox].size.width) / 2,
                         node.position.y);
    return center;
}

+ (CGPoint) centerHeight:(CCNode*)node {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    node.anchorPoint = ccp(0, 0);
    CGPoint center = ccp(node.position.x,
                         (screenSize.height - [node boundingBox].size.height) / 2);
    return center;
}

+ (CGPoint) center:(CCNode*)node inParent:(CCNode*)parent {
    node.anchorPoint = ccp(0, 0);
    CGPoint center = ccp(([parent boundingBox].size.width - [node boundingBox].size.width) / 2,
                         ([parent boundingBox].size.height - [node boundingBox].size.height) / 2);
    return center;    
}

+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node inParent:(CCNode*)parent {
    node.anchorPoint = ccp(0.5, 0.5);
    CGPoint center = ccp([parent boundingBox].size.width / 2, node.position.y);
    return center;
}

+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node y:(float)y inParent:(CCNode*)parent {
    node.anchorPoint = ccp(0.5, 0.5);
    CGPoint center = ccp([parent boundingBox].size.width / 2, y);
    return center;    
}

+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node y:(float)y parentSize:(CGSize)size {
    node.anchorPoint = ccp(0.5, 0.5);
    CGPoint center = ccp(size.width / 2, y);
    return center;    
}

+ (CGPoint) centerWidth:(CCNode*)node inParent:(CCNode*)parent {
    node.anchorPoint = ccp(0, 0);
    CGPoint center = ccp([parent boundingBox].size.width/2 - [node boundingBox].size.width / 2,
                         node.position.y);
    return center;
}

+ (CGPoint) centerHeight:(CCNode*)node inParent:(CCNode*)parent {
    node.anchorPoint = ccp(0, 0);
    CGPoint center = ccp(node.position.x,
                         ([parent boundingBox].size.height - [node boundingBox].size.height) / 2);
    return center;
}

#pragma mark - Atlas related
+ (NSString*) getAtlasImageName:(NSString*)atlas {
    return [NSString stringWithFormat:@"%@.png", atlas];
}

+ (NSString*) getAtlasPList:(NSString*)atlas {
    return [NSString stringWithFormat:@"%@.plist", atlas];    
}

@end
