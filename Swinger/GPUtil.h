//
//  GPUtil.h
//  CloudSoar
//
//  Created by Min Kwon on 3/21/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//


CG_INLINE float fast_sign(float f) {
    if (f > 0) return 1;
    return (f == 0) ? 0 : -1;
}

@interface GPUtil : NSObject {
    
}

+ (double) randomFrom:(double)n1 to:(double)n2;
+ (CGPoint) center:(CCNode*)node;
+ (CGPoint) centerWidth:(CCNode*)node;
+ (CGPoint) centerHeight:(CCNode*)node;
+ (CGPoint) center:(CCNode*)node inParent:(CCNode*)parent;
+ (CGPoint) centerWidth:(CCNode*)node inParent:(CCNode*)parent;
+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node inParent:(CCNode*)parent;
+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node y:(float)y inParent:(CCNode*)parent;
+ (CGPoint) centerWidthDefaultAnchor:(CCNode*)node y:(float)y parentSize:(CGSize)size;
+ (CGPoint) centerHeight:(CCNode*)node inParent:(CCNode*)parent;
+ (CCSprite*) createButtonWithText:(NSString*)levelStr 
                       borderWidth:(float)borderWidth 
                       borderColor:(ccColor3B)color 
                             color:(ccColor3B)fontColor
                       absXPadding:(BOOL)absSize
                          xPadding:(float)xPdding 
                          yPadding:(float)yPadding 
                             scale:(float)scale;



+ (CCSprite*) createButtonWithText:(NSString*)levelStr 
                       borderWidth:(float)borderWidth 
                       borderColor:(ccColor3B)color 
                          xPadding:(float)xPdding 
                          yPadding:(float)yPadding;


+ (NSString*) getAtlasImageName:(NSString*)atlas;
+ (NSString*) getAtlasPList:(NSString*)atlas;

@end
