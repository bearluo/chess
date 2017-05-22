//
//  SinaWeiboPlatform.h
//  DDZDouble
//
//  Created by  on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WBLibrary/WBGameCenterManager.h"
#import "ThirdPartPlatform.h"

@interface SinaWeiboPlatform : ThirdPartPlatform<WBGameCenterDelegate >
{
}

+(SinaWeiboPlatform*) sharedPlatform;
- (id) init;
- (void) login;
- (void) logout;
- (void) requestUserInfo;
@end
