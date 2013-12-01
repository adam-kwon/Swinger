//
//  CCLabelBMFont+withColor.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/12/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "CCLabelBMFont+withColor.h"

@implementation CCLabelBMFont (WithColor)

+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color scaleX:(float)sx scaleY:(float)sy {
    CCLabelBMFont *lbl = [CCLabelBMFont labelWithString:str fntFile:fntFile];
    lbl.color = color;
    if (sx == sy) {
        lbl.scale = sx;
    } else {
        lbl.scaleX = sx;
        lbl.scaleY = sy;
    }
    return lbl;        
}


+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color scale:(float)s {
    return [CCLabelBMFont labelWithString:str fntFile:fntFile color:color scaleX:s scaleY:s];
}

+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color {
    return [CCLabelBMFont labelWithString:str fntFile:fntFile color:color scaleX:1.0f scaleY:1.0f];
}

+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile scale:(float)s {
    return [CCLabelBMFont labelWithString:str fntFile:fntFile color:ccc3(255, 255, 255) scaleX:s scaleY:s];    
}

+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile scaleX:(float)sx scaleY:(float)sy; {
    return [CCLabelBMFont labelWithString:str fntFile:fntFile color:ccc3(255, 255, 255) scaleX:sx scaleY:sy];        
}


- (void) setColorSubString:(NSString*)str color:(ccColor3B)c {
    NSRange r = [self.string rangeOfString:str];
    int len = [str length];
    for (int i = r.location; i < r.location+len; i++) {
        [(CCSprite *)[[self children] objectAtIndex:i] setColor:c];
    }
}

- (void) setColorSubStringIndexOf:(NSString*)str color:(ccColor3B)c {
    NSRange r = [self.string rangeOfString:str options:NSBackwardsSearch];
    int len = [self.string length];
    for (int i = r.location; i < len; i++) {
        [(CCSprite *)[[self children] objectAtIndex:i] setColor:c];
    }    
}

@end
