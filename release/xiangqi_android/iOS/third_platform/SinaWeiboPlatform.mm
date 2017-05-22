//
//  SinaWeiboPlatform.m
//  DDZDouble
//
//  Created by  on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiboPlatform.h"
#import "NSString+SBJSON.h"
#import "AppDelegate.h"

static SinaWeiboPlatform* sinaWeiboPlatform_;

@implementation SinaWeiboPlatform

+(SinaWeiboPlatform*) sharedPlatform
{
    if (sinaWeiboPlatform_ == nil) {
        sinaWeiboPlatform_ = [[SinaWeiboPlatform alloc] init];
    }
    return sinaWeiboPlatform_;
}
-(id) init
{
    if(sinaWeiboPlatform_ != nil) {
        return sinaWeiboPlatform_;
    }
    if(self=[super init])
    {
        [[WBGameCenterManager sharedInstance] startAuthorize];
        [WBGameCenterManager sharedInstance].delegate = self;
        [WBGameCenterManager sharedInstance].isLandscape = YES;
    }
    return self;
}

-(void) login
{
    id viewControoler = [[[UIApplication sharedApplication] delegate] viewController];
    [[WBGameCenterManager sharedInstance] showStartAuthorize:viewControoler];
}

- (void) logout
{
    [[WBGameCenterManager sharedInstance] loginOut];
    [sinaWeiboPlatform_ autorelease];
    sinaWeiboPlatform_ = nil;
    [self didRequestEnd:true];
}

-(void) requestUserInfo
{
    [[WBGameCenterManager sharedInstance] userInfo: [WBGameCenterManager sharedInstance].currentUserId];
}

#pragma -
#pragma mark - - - -  WBGameCenterDelegate － － － － － －
- (void)authLoginSuccessed{
    if ([[WBGameCenterManager sharedInstance] isSignning]) {
		[userInfo_ release];
        userInfo_ = [[@"\"sitemid\":" stringByAppendingFormat:@"%@%@%@,%@%@%@%@",
                                @"\"",[WBGameCenterManager sharedInstance].currentUserId,@"\"",
                                @"\"sessionKey\":",
                                @"\"",[WBGameCenterManager sharedInstance].sessionKey,@"\"" ] retain];
        
        [self requestUserInfo];
	}
    else {
        [self didRequestEnd:false];
    }
    
}

- (void)authLoginFailed{
	[self didRequestEnd:false];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString* result = [request responseString];
    result = [result substringWithRange:NSMakeRange(1, [result length]-2)];
    [userInfo_ autorelease];
    userInfo_ = [[@"{" stringByAppendingFormat:@"%@,%@%@",userInfo_,result,@"}"] retain];
    
    self.RequestResult = userInfo_;
    
    [self didRequestEnd:true];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [self didRequestEnd:false];
}


@end
