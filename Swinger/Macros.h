//
//  Macros.h
//  Swinger
//
//  Created by Min Kwon on 6/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#ifndef Swinger_Macros_h
#define Swinger_Macros_h

#import "Globals.h"

// Normalize the position to screen resolution. 
// For example, assume screen width is 480 pixels
// Screen is scaled to 0.5, so width now becomes 960
// If an object is in the middle of the screen on the zoomed out screen, it's position will be 480
// but if you call the function below, it will return 240 (macro below will return absolute
// position of the object regardless of zoom based on the physical pixel dimension of screen)
#define normalizeToScreenCoord(gameNodePos, objectPos, scale)   (((gameNodePos) + (objectPos)) * (scale))



#define ssautores(x)    ((g_isIpad || g_isRetina) ? (x*2) : (x))
#define sshires(x, y)   ((g_isIpad || g_isRetina) ? (x) : (y)) 
#define ssipad(x, y)    (g_isIpad ? (x) : (y))
#define ssipadauto(x)   (g_isIpad ? (x*2) : (x))
#define ssall(x, y, z)  (g_isIpad ? (x) : (g_isRetina ? (y) : (z)))

#define ccc3to4(x,y)        (ccc4(x.r,x.g,x.b,y))

#endif
