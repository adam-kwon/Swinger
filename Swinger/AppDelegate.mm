//
//  AppDelegate.m
//  Swinger
//
//  Created by Min Kwon on 3/18/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "Globals.h"
#import "UserData.h"
#import "StoreManager.h"
#import "SplashScene.h"
#import "GameRules.h"
#import "Notifications.h"
#import "DeviceDetection.h"
#import "MainGameScene.h"
#import "GamePlayLayer.h"

BOOL g_isIpad = NO;
BOOL g_isIphone5 = NO;
BOOL g_isRetina = YES;
BOOL g_block;
NSString *g_currentWorldAtlas;
GameRules g_gameRules;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [[[UserData alloc] init] readOptionsFromDisk];
    [[StoreManager alloc] init];
    
    // Disable screen sleep 
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
    [glView setMultipleTouchEnabled:YES];
    
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        g_isIpad = NO;
        g_isRetina = YES;
        if (![director enableRetinaDisplay:YES]) {
            g_isRetina = NO;
            CCLOG(@"!!!! Retina Display Not Supported !!!!");
        }
    } else {
        g_isRetina = NO;
        g_isIpad = YES;
    }
    
    if ([DeviceDetection detectDevice] == MODEL_IPHONE_5) {
        NSLog(@"**** Detected iPhone 5");
        g_isIphone5 = YES;
    } else {
        g_isIphone5 = NO;
    }
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
#if DEBUG
    [director setDisplayFPS:YES];
#else
    [director setDisplayFPS:NO];
#endif
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
    // A bug? On ios 6, need to call setRootViewController or
    // game always starts in portrait mode
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
        [window addSubview: viewController.view];
    } else {
        [window setRootViewController:viewController];
    }
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    // Per Apple's documentation: "Your application should asociate an observer with the payment queue
    // when it launches, rather than wait until the user attempts to purchase the an item. Transactions
    // are not lost when an application terminates. The next time the appliation launches, Store Kit
    // resumes processing transactions. Adding the observer during your application's initialization
    // ensures that all transactions are returned to your applications.
    //IAPHelper *iaHelper = [IAPHelper sharedInstance];
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:iaHelper];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[SplashScene node]];
    
    [self initializeGlobals];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(globalLock:) 
                                                 name:NOTIFICATION_GLOBAL_LOCK object:nil];
    
}

- (void) initializeGlobals {
#ifdef USE_CONSISTENT_PTM_RATIO
    PTM_RATIO = ssipad(64.0f, 32.0f);
#else
    PTM_RATIO = 32.0f;
#endif
    
    g_gameRules.runSpeed = 11.5f;
    g_gameRules.jumpForce = 20.f;
    g_gameRules.floatForce = 20.5f;
    g_gameRules.gravity = 2.f;
}

- (void) unblock:(id)param {
    g_block = NO;
}

- (void) globalLock:(NSNotification*)notifcation {
    [NSTimer scheduledTimerWithTimeInterval:0.2 
                                     target:self 
                                   selector:@selector(unblock:)  
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//[[CCDirector sharedDirector] pause];
    CCScene * currentScene = [CCDirector sharedDirector].runningScene;
    if ([currentScene isKindOfClass:[MainGameScene class]]) {
        [[GamePlayLayer sharedLayer] pauseGame];
    } else {
        [[CCDirector sharedDirector] pause];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AudioEngine sharedEngine] setEffectsVolume: [UserData sharedInstance].fxVolumeLevel];
    [[AudioEngine sharedEngine] setBackgroundMusicVolume: [UserData sharedInstance].musicVolumeLevel];
    CCScene * currentScene = [CCDirector sharedDirector].runningScene;
    if (![currentScene isKindOfClass:[MainGameScene class]]) {
        [[CCDirector sharedDirector] resume];
    }
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[UserData sharedInstance] persist];
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    [[UserData sharedInstance] persist];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[UserData sharedInstance] persist];
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
