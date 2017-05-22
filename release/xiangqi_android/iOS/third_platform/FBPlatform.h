//#import <Foundation/Foundation.h>
#import "facebook/FBConnect.h"
#import "ThirdPartPlatform.h"

typedef enum APICall {
    kAPIUserinfo,
    kAPIGraphUserPermissionsDelete,
} APICall;

@class Facebook;
@class FBLoginDialog;

@interface FBPlatform : ThirdPartPlatform<FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>{
    Facebook* facebook_;
    NSArray* permissions_;
    
    APICall currentAPICall_;
}

+ (FBPlatform *)sharedPlatform;

- (id) init;
- (void) login;
- (void) logout;
- (void) uninstall;
- (void) requestUserInfo;

- (BOOL)handleOpenURL:(NSURL *)url;
@end