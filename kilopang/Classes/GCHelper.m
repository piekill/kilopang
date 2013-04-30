//
//  GCHelper.m
//  kilopang
//
//  Created by Junxing Yang on 4/29/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
static UIViewController* currentModalViewController = nil;
+ (GCHelper *) sharedInstance {
	if (!sharedHelper) {
		sharedHelper = [[GCHelper alloc] init];
	}
	return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer =@"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer
										   options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
	if ((self = [super init])) {
		gameCenterAvailable = [self isGameCenterAvailable];
		if (gameCenterAvailable) {
			NSNotificationCenter *nc =
			[NSNotificationCenter defaultCenter];
			[nc addObserver:self
				   selector:@selector(authenticationChanged)
					   name:GKPlayerAuthenticationDidChangeNotificationName
					 object:nil];
		}
	}
	return self;
}

- (void)authenticationChanged {
	
	if ([GKLocalPlayer localPlayer].isAuthenticated &&!userAuthenticated) {
		NSLog(@"Authentication changed: player authenticated.");
		userAuthenticated = TRUE;
	} else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
		NSLog(@"Authentication changed: player not authenticated");
		userAuthenticated = FALSE;
	}
	
}

#pragma mark User functions

- (void)authenticateLocalUser {
	
	if (!gameCenterAvailable) return;
	
	NSLog(@"Authenticating local user...");
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
	} else {
		NSLog(@"Already authenticated!");
	}
}

- (void) showLeaderboard
{
    if (!gameCenterAvailable) return;
	
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
		
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        currentModalViewController = [[UIViewController alloc] init];
        [window addSubview:currentModalViewController.view];
        [currentModalViewController presentModalViewController:leaderboardController animated:YES];
    }
	
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    if(currentModalViewController !=nil){
        [currentModalViewController dismissModalViewControllerAnimated:NO];
        [currentModalViewController release];
        [currentModalViewController.view removeFromSuperview];
        currentModalViewController = nil;
    }
}

- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	scoreReporter.value = score;
	
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil)
		{
			// handle the reporting error
			NSLog(@"上传分数出错.");
			//If your application receives a network error, you should not discard the score.
			//Instead, store the score object and attempt to report the player’s process at
			//a later time.
		}else {
			NSLog(@"上传分数成功");
		}
		
	}];
}
@end
