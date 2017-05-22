//
//  GuestPlatform.m
//  DDZDouble
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <string>

std::string getMacAddress();

#import "GuestPlatform.h"

static GuestPlatform* guestPlatform_;

@implementation GuestPlatform

+ (GuestPlatform *)sharedPlatform
{
    if (guestPlatform_ == nil) {
        guestPlatform_ = [[GuestPlatform alloc] init];
    }
    return guestPlatform_;
}

- (id) init
{
    if(guestPlatform_ != nil) {
        return guestPlatform_;
    }
    if(self=[super init])
    {
        
    }
    return self;
}
- (void) login
{
    std::string macAddr = getMacAddress();
    
    [userInfo_ release];
    userInfo_ = [[@"{\"imei\":\"" stringByAppendingFormat:@"%@%@,%@%@%@",
                  [NSString stringWithFormat:@"%s",macAddr.c_str()],
                  @"\"",
                  @"\"name\":\"",[[UIDevice currentDevice] name],@"\"}"]
                   retain];

    self.RequestResult = userInfo_;
    [self didRequestEnd:true];
}
- (void) logout
{
    [guestPlatform_ autorelease];
    guestPlatform_ = nil;
    [self didRequestEnd:true];
}
@end

///////////////////////////////////////////////////////////////////////////////



std::string getMacAddress()
{
    int mib[6];
    size_t len;
    char* buf;
    unsigned char* ptr;
    struct if_msghdr* ifm;
    struct sockaddr_dl* sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if (!(mib[5]=if_nametoindex("en0"))) {
        return "";
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0)<0) {
        return "";
    }
    
    if (!(buf=(char*)malloc(len))) {
        return "";
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0)) {
        return "";
    }
    
    ifm = (struct if_msghdr*)buf;
    sdl = (struct sockaddr_dl*)(ifm+1);
    ptr = (unsigned char*)LLADDR(sdl);
    
    
    char tmp[32];
    
    sprintf(tmp, "%02x%02x%02x%02x%02x%02x",*(ptr++),*(ptr++),*(ptr++),*(ptr++),*(ptr++),*ptr);
    
    free(buf);
    return tmp;
}
