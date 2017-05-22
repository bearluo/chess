
#import "FBPlatform.h"
#import	"Facebook.h"
#import <Foundation/Foundation.h>

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php

#define FB_USER_INFO @"DDZfbUserInfo"
#define FB_ACCESS_TOKEN @"FBAccessToken"
#define FB_EXPIRATION_DATE @"FBExpirationDate"

static FBPlatform *fbPlatform_;


@implementation FBPlatform

+(FBPlatform *)sharedPlatform {
    if (fbPlatform_ == nil) {
        fbPlatform_ = [[FBPlatform alloc] init];
    }
    return fbPlatform_;
}

-(id)init
{
    if(fbPlatform_ != nil) {
        return fbPlatform_;
    }
    if(self=[super init])
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FBPropertyList" ofType:@"plist"];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSString* appkey = [dictionary objectForKey:@"appkey"];

        facebook_ = [[Facebook alloc] initWithAppId:appkey andDelegate:self];
		permissions_ =[[NSArray alloc] initWithObjects: @"offline_access",nil];
        
        facebook_.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESS_TOKEN];
        facebook_.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:FB_EXPIRATION_DATE];
    }
    return self;
}

#pragma mark -
#pragma mark Facebook Call Mothods

/**
 *  facebook login and permission request
 */
- (void) login {
	//[_facebook authorize:_permissions];
    if (![facebook_ isSessionValid]) {
        [facebook_ authorize:permissions_];
    }
    else {
        self.RequestResult = userInfo_;
        if (userInfo_) {
            self.RequestResult = userInfo_;
            [self didRequestEnd:true];
        }
        else {
            [self fbDidLogin];
        }
        
    }
}

/**
 *  facebook logout
 */
- (void) logout {
	[facebook_ logout:self];
}

-(void) uninstall
{
    currentAPICall_ = kAPIGraphUserPermissionsDelete;
    // Passing empty (no) parameters unauthorizes the entire app. To revoke individual permissions
    // add a permission parameter with the name of the permission to revoke.
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    [facebook_ requestWithGraphPath:@"me/permissions"
                          andParams:params
                      andHttpMethod:@"DELETE"
                        andDelegate:self];
}

/**
 * Make a Graph API Call to get information about the current logged in user.
 */
- (void)requestUserInfo {
    currentAPICall_ = kAPIUserinfo;
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic FROM user WHERE uid=me()", @"query",
                                   nil];
    [facebook_ requestWithMethodName:@"fql.query"
                           andParams:params
                       andHttpMethod:@"POST"
                         andDelegate:self];
    
}


#pragma mark -
#pragma mark FBSessionDelegate Mothods

/**
 * Callback for facebook login
 */ 
-(void) fbDidLogin {
    [userInfo_ release];
    userInfo_ = [[NSString alloc] initWithFormat:@"%@%@%@",
                                        @"\"access_token\":\"",
                                        [facebook_ accessToken],
                                        @"\"" ];
    
    [[NSUserDefaults standardUserDefaults] setObject:[facebook_ accessToken] forKey:FB_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:[facebook_ expirationDate] forKey:FB_EXPIRATION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self requestUserInfo];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
    [self didRequestEnd:false];
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_EXPIRATION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [fbPlatform_ autorelease];
    fbPlatform_ = nil;
    [self didRequestEnd:true];
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    //NSLog(@"token extend");
}

-(void)fbSessionInvalidated {
    [self fbDidLogout];
}


#pragma mark -
#pragma mark FBRequestDelegate Mothods

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{

}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	[self didRequestEnd:false];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
    //[self didRequestEnd:false];
    
    if (kAPIUserinfo == currentAPICall_) {
    
        if ([result isKindOfClass:[NSArray class]])
        {
            result = [result objectAtIndex:0];
            NSString* ret = @"";
            
            NSArray* keys = [NSArray arrayWithObjects:@"name",@"pic",@"uid", nil];
            for (NSString* key in keys) {
                if ([result objectForKey:key]) {
                    ret = [ret stringByAppendingFormat:@"\"%@\":\"%@\",",key,[result objectForKey:key]];
                }
            }
            ret = [ret substringWithRange:NSMakeRange(0, [ret length]-1)];
            [userInfo_ autorelease];
            userInfo_ = [[@"{" stringByAppendingFormat:@"%@,%@%@",userInfo_,ret,@"}"] retain];
            self.RequestResult = userInfo_;
            [self didRequestEnd:true];
        }else {
            [userInfo_ autorelease];
            userInfo_ = nil;
            [self didRequestEnd:false];
        }
    }
    else if (kAPIGraphUserPermissionsDelete == currentAPICall_)
    {
        [self fbDidLogout];
    }
        
}

//- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
//{
//    NSString* responseString = [[[NSString alloc] initWithData:data
//                                                      encoding:NSUTF8StringEncoding]
//                                autorelease];
//   
//    int len = [responseString length] -4;
//    responseString = [responseString substringWithRange:NSMakeRange(2, len)];
//    [userInfo_ autorelease];
//    userInfo_ = [@"{" stringByAppendingFormat:@"%@,%@%@",userInfo_,responseString,@"}"];
//    self.RequestResult = userInfo_;
//    [self didRequestEnd:true];
//}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [facebook_ handleOpenURL:url];
}

@end
