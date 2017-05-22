//
//  GuestPlatform.h
//  DDZDouble
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdPartPlatform.h"

@interface GuestPlatform : ThirdPartPlatform
{

}

+ (GuestPlatform *)sharedPlatform;

- (id) init;
- (void) login;
- (void) logout;

@end
