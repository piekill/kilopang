//
//  GCHelper.h
//  kilopang
//
//  Created by Junxing Yang on 4/29/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface GCHelper : NSObject <GKLeaderboardViewControllerDelegate> {
	BOOL gameCenterAvailable;
	BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;

- (void) showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void) reportScore: (int64_t) score forCategory: (NSString*) category;
@end
