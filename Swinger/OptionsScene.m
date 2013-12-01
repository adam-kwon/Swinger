//
//  StoreItemContainer.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "OptionsScene.h"
#import "Macros.h"
#import "Constants.h"
#import "AudioEngine.h"
#import "CCLayerColor+extension.h"
#import "MainMenuScene.h"
#import "GPImageButton.h"
#import "UserData.h"

@implementation OptionsScene

+ (id) node {
    return [[[self alloc] init] autorelease];
}

- (id) init {
    
    if (self = [super init]) {
        
        //[self loadSpriteSheets];
        screenSize = [[CCDirector sharedDirector] winSize];
        
        // shadow
        CCLayerColor * shadow = [CCLayerColor getFullScreenLayerWithColor: ccc3to4(CC3_COLOR_BLUE, 200)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        CCSprite *wallPaper = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        wallPaper.scaleX = screenSize.width/[wallPaper boundingBox].size.width + 0.1;
        wallPaper.scaleY = screenSize.height/[wallPaper boundingBox].size.height + 0.1;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild:wallPaper z:-2];
        
        [self moveWallpaper: wallPaper];
        
        // add back button
        GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"backButton.png"];
        backButton.position = CGPointMake(ssipad(890, screenSize.width - 46), ssipad(704, 298));
        
        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [backButton setText:backText];
        
        [self addChild:backButton];
        
        // add music and sound buttons
        music = [CCSprite spriteWithFile:@"music.png"];
        GPImageButton *musicBtn = [GPImageButton controlOnTarget:self andSelector:@selector(toggleMusic) imageFromSprite: music];
        musicBtn.position = ccp(screenSize.width/4 - [music boundingBox].size.width, screenSize.height - screenSize.height/4);
        [self addChild: musicBtn];
        
        soundFx = [CCSprite spriteWithFile:@"sound.png"];
        GPImageButton *soundFxBtn = [GPImageButton controlOnTarget:self andSelector:@selector(toggleSoundFx) imageFromSprite: soundFx];
        soundFxBtn.position = ccp(musicBtn.position.x + [music boundingBox].size.width/2 + ssipadauto(70), musicBtn.position.y);
        [self addChild: soundFxBtn];
        
        [self initMusicAndSoundFx];
        
        //----------
        // Init twitter, facebook, social media plugins
        //-----------
        CCSprite *logo = [CCSprite spriteWithFile:@"twitter.png"];
        logo.scale = 0.1;
        GPImageButton *twitter = [GPImageButton controlOnTarget:self andSelector:@selector(twitter) imageFromSprite:logo];
        twitter.position = ccp(soundFxBtn.position.x + ssipad(360,180), soundFxBtn.position.y);
        [self addChild: twitter];
        
        logo = [CCSprite spriteWithFile:@"facebook.png"];
        logo.scale = 0.25;
        GPImageButton *facebook = [GPImageButton controlOnTarget:self andSelector:@selector(facebook) imageFromSprite:logo];
        facebook.position = ccp(twitter.position.x + [twitter boundingBox].size.width/2 + ssipadauto(80), soundFxBtn.position.y);
        [self addChild: facebook];
        
        logo = [CCSprite spriteWithFile:@"youtube.png"];
        logo.scale = 0.25;
        GPImageButton *youtube = [GPImageButton controlOnTarget:self andSelector:@selector(youtube) imageFromSprite:logo];
        youtube.position = ccp(facebook.position.x + [facebook boundingBox].size.width/2 + ssipadauto(80), soundFxBtn.position.y);
        [self addChild: youtube];
        
        GPImageButton *news = [GPImageButton controlOnTarget:self andSelector:@selector(news) imageFromFile:@"Button_Store.png"];
        //news.scale = 0.85;
        CCLabelBMFont *text = [CCLabelBMFont labelWithString:@"NEWS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.65;
        [news setText:text];
        news.position = ccp(ssipad(180, 90), ssipad(musicBtn.position.y - 150, musicBtn.position.y - 75));
        [self addChild:news];
        //[buttonCache addObject:news];
        
        float buttonGap = ssipadauto(50);
        
        GPImageButton *credits = [GPImageButton controlOnTarget:self andSelector:@selector(credits) imageFromFile:@"Button_Store.png"];
        //credits.scale = 0.85;
        text = [CCLabelBMFont labelWithString:@"CREDITS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.65f;
        [credits setText:text];
        credits.position = ccp(news.position.x, news.position.y - buttonGap);
        [self addChild:credits];
        //[buttonCache addObject: credits];
        
        // Separator
        ccColor4B lineColor = ccc3to4(CC3_COLOR_CANTALOPE, 255);
        float sepXPos = news.position.x + [news size].width/2 - ssipadauto(10);
        float sepYPos = news.position.y + [news size].height/2 + ssipadauto(10);
        
        CCLayerColor *separator = [CCLayerColor layerWithColor:lineColor];
        [separator setContentSize:CGSizeMake(1, -(news.position.y + [news size].height/2 + ssipadauto(10)))];//ssipad(-200,-100))];
        separator.position = ccp(sepXPos, sepYPos);
        [self addChild: separator z:-1];
        
        separator = [CCLayerColor layerWithColor:lineColor];
        [separator setContentSize:CGSizeMake(screenSize.width - sepXPos, 1)];
        separator.position = ccp(sepXPos, sepYPos);
        [self addChild: separator z:-1];
    }
    
    return self;
}

- (void) news {
    
}

- (void) credits {
    
}

- (void) twitter {
    
}

- (void) facebook {
    
}

- (void) youtube {
    
}

- (void) moveWallpaper: (CCSprite *) theWallpaper {
    float duration = 20;
    float moveAmt = [theWallpaper boundingBox].size.width - screenSize.width;
    
    theWallpaper.position = ccp(0,0);
    
    if (moveAmt > 0) {
        
        CCMoveBy * scrollRight = [CCMoveBy actionWithDuration:duration position: ccp(theWallpaper.position.x - moveAmt, 0)];
        CCScaleTo * scaleUp = [CCScaleBy actionWithDuration:duration scale:1.25f];
        CCSpawn * spawn1 = [CCSpawn actionOne:scrollRight two:scaleUp];
        
        [theWallpaper stopAllActions];
        [theWallpaper runAction: [CCRepeatForever actionWithAction:[CCSequence actions:spawn1, [spawn1 reverse], nil]]];
    }
}

- (void) goBack {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuScene node]]];    
}

- (void) initMusicAndSoundFx {
    
    //CCLOG(@"CURRENT MUSIC VOLUME %f, %f", [[AudioEngine sharedEngine] backgroundMusicVolume], [[AudioEngine sharedEngine] effectsVolume]);
    
    UserData * ud = [UserData sharedInstance];
    
    [self setMusicOn: ud.musicVolumeLevel > 0];
    [self setSoundOn: ud.fxVolumeLevel > 0];
}

- (void) toggleMusic {
    
    UserData * ud = [UserData sharedInstance];
    
    if (ud.musicVolumeLevel > 0) {
        ud.musicVolumeLevel = 0;
    } else {
        ud.musicVolumeLevel = 1;
    }
    
    [[AudioEngine sharedEngine] setBackgroundMusicVolume: ud.musicVolumeLevel];
    [self setMusicOn: ud.musicVolumeLevel > 0];
}

- (void) setMusicOn: (BOOL) on {
    
    float opacity = on ? 255 : 100;
    
    music.opacity = opacity;
}

- (void) toggleSoundFx {
    
    UserData * ud = [UserData sharedInstance];
    
    if (ud.fxVolumeLevel > 0) {
        ud.fxVolumeLevel = 0;
    } else {
        ud.fxVolumeLevel = 1;
    }
    
    [[AudioEngine sharedEngine] setEffectsVolume: ud.fxVolumeLevel];
    [self setSoundOn: ud.fxVolumeLevel > 0];
}

- (void) setSoundOn: (BOOL) on {
    
    float opacity = on ? 255 : 100;
    
    soundFx.opacity = opacity;
}

- (void) dealloc {
    CCLOG(@"--------Options Pane Deallocated--------");
    
    [super dealloc];
}

@end
