//
//  Constants.h
//  Swinger
//
//  Created by James Sandoz on 4/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#ifndef Swinger_Constants_h
#define Swinger_Constants_h

#include "Macros.h"

// Set to use an appropriate PTM_RATIO on ipad to make the game behave
// the same on ipad/iphone
#define USE_CONSISTENT_PTM_RATIO 1


#define USE_FIXED_TIME_STEP     1

#define PLAYER_BODY_SPRITE_TAG  2012

#define CATEGORY_HOLDER     	0x0000
#define CATEGORY_ANCHOR         0x0000
#define CATEGORY_ROPE           0x0001
#define CATEGORY_CATCHER        0x0002
#define CATEGORY_JUMPER         0x0004
#define CATEGORY_GROUND         0x0008
#define CATEGORY_FINAL_PLATFORM 0x0010
#define CATEGORY_CANNON         0x0020
#define CATEGORY_SPRING         0x0040
#define CATEGORY_STAR           0x0080
#define CATEGORY_LOOP           0x0100
#define CATEGORY_STRONGMAN      0x0400
#define CATEGORY_ENEMY          0x0800
#define CATEGORY_FLOATING_PLATFORM 0x1000
#define CATEGORY_MISSILE        0x400

#define MOTOR_SPEED             3

#define MIN_SCROLL_DELTA        1
#define MAX_SCROLL_DELTA        10
#define SCROLL_DELTA            5

#define DO_GRIP                 0 // 1 - turns grip on, 0 - turns grip off
#define USE_CONSTANT_JUMP_FORCE_FROM_SWING 1 // use a constant jump force for the swing instead of player velocity when joint is destroyed 

#define CC3_COLOR_LIME_GREEN       ccc3(173,  255, 47)
#define CC3_COLOR_CANTALOPE        ccc3(255, 204, 102)
#define CC3_COLOR_WHITE            ccc3(255, 255, 255)
#define CC3_COLOR_GRAY             ccc3(102, 102, 102)
#define CC3_COLOR_GRAY2            ccc3(153, 153, 153)
#define CC3_COLOR_YELLOW           ccc3(251, 193, 24)
#define CC3_COLOR_RED              ccc3(200, 27, 34)
#define CC3_COLOR_ORANGE           ccc3(204, 95, 44)
#define CC3_COLOR_GREEN            ccc3(0,   255, 0)
#define CC3_COLOR_BLUE             ccc3(51,  102, 153)
#define CC3_COLOR_STEEL_BLUE       ccc3(79,  148, 205)
#define CC3_COLOR_BLACK            ccc3(0,   0,  0)
#define CC3_COLOR_STEEL_GREEN      ccc3(96, 224, 128)
#define CC3_COLOR_DARK_STEEL_GREEN ccc3(32, 160, 64)

// Touch priority
#define TOUCH_PRIORITY_LOADING      -1000
#define TOUCH_PRIORITY_TOP          -600
#define TOUCH_PRIORITY_HIGHEST      -500
#define TOUCH_PRIORITY_HIGH         -200
#define TOUCH_PRIORITY_NORMAL       0
#define TOUCH_PRIORITY_LOW          200
#define TOUCH_PRIORITY_LOWEST       500

#define FONT_ARIAL_ROUND_MT_BOLD    @"arial-rounded-mt-bold.fnt"
#define FONT_HOBO_64                @"hobo64.fnt"
#define FONT_HOBO_32                @"hobo32.fnt"
#define FONT_BUBBLEGUM_16           @"bubbleGumFont-16.fnt"
#define FONT_BUBBLEGUM_32           @"bubbleGumFont-32.fnt"
#define FONT_BUBBLEGUM_64           @"bubbleGumFont-64.fnt"
#define FONT_DEFAULT                FONT_ARIAL_ROUND_MT_BOLD


#define FONT_SCORE_LABEL            @"MarkerFelt-Wide"

#define FONT_COLOR_CANTALOPE        ccc3(255, 204, 102)
#define FONT_COLOR_WHITE            ccc3(255, 255, 255)
#define FONT_COLOR_GRAY             ccc3(102, 102, 102)
#define FONT_COLOR_YELLOW           ccc3(251, 193, 24)
#define FONT_COLOR_RED              ccc3(200, 27, 34)
#define FONT_COLOR_ORANGE           ccc3(204, 95, 44)
#define FONT_COLOR_GREEN            ccc3(0, 255, 0)

#define WORLD_GRASS_KNOLLS          @"Grassy Knolls"
#define WORLD_FOREST_RETREAT        @"Forest Retreat"

typedef enum {
    kGameObjectNone,
    kGameObjectDummy,
    kGameObjectStar,
    kGameObjectCoin,
    kGameObjectCoin5,
    kGameObjectCoin10,
    kGameObjectCatcher,
    kGameObjectJumper,
    kGameObjectGround,
    kGameObjectFinalPlatform,
    kGameObjectWind,
    kGameObjectCrow,
    kGameObjectCannon,
    kGameObjectSpring,
    kGameObjectTent1,
    kGameObjectTent2,
    kGameObjectBalloonCart,
    kGameObjectPopcornCart,
    kGameObjectTree1,
    kGameObjectTree2,
    kGameObjectTree3,
    kGameObjectTree4,
    kGameObjectTreeClump1,
    kGameObjectTreeClump2,
    kGameObjectTreeClump3,
    kGameObjectBoxes,
    kGameObjectTorch,
    kGameObjectElephant,
    kGameObjectWheel,
    kGameObjectFloatingPlatform,
    kGameObjectCurvedPlatform,
    kGameObjectFallingPlatform,
    kGameObjectBlock,
    kGameObjectStrongMan,
    kGameObjectLoop,
    
    // Powerups
    kGameObjectMagnet,
    kGameObjectShield,
    kGameObjectSpeedBoost,
    kGameObjectJetPack,
    kGameObjectAngerPotion,
    kGameObjectCoinDoubler,
    kGameObjectMissileLauncher,
    kGameObjectGrenadeLauncher,
    kGameObjectMissile,
    
    // Enemies
    kGameObjectBoulder,
    kGameObjectHunter,
    kGameObjectInsect,
    kGameObjectSaw,
    kGameObjectOilBarrel
} GameObjectType;

typedef enum {
    kPlayerTypeNone,
    kPlayerTypeGonzo
} PlayerType;

typedef enum {
    kContactNone,
    kContactTop,
    kContactBottom
} ContactLocation;


#endif
