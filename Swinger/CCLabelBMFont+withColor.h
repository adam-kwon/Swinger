//
//  CCLabelBMFont+withColor.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/12/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

@interface CCLabelBMFont (WithColor)

+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color scaleX:(float)sx scaleY:(float)sy;
+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color scale:(float)s;
+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile color:(ccColor3B)color;
+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile scale:(float)s;
+ (id) labelWithString:(NSString*)str fntFile:(NSString*)fntFile scaleX:(float)sx scaleY:(float)sy;


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

@end
