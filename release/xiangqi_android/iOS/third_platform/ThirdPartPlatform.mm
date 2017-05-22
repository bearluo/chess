//
//  ThirdPartPlatform.m
//  DDZDouble
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ThirdPartPlatform.h"

static NSString* LuaEventName = @"LuaEventCall";

@implementation ThirdPartPlatform

@synthesize RequestResult = requestResult_;
@synthesize EventName = eventName_;

-(id) init
{
    if (self = [super init])
    {
        eventName_ = [[NSString alloc] initWithCString:"" encoding:NSUTF8StringEncoding];
        requestResult_ = [[NSString alloc] initWithCString:"" encoding:NSUTF8StringEncoding];
    }
    
    return self;
}

-(void) didRequestEnd:(BOOL)result
{
    dict_set_string([LuaEventName UTF8String], [LuaEventName UTF8String], [eventName_ UTF8String]);
    if (result) {
        dict_set_int([eventName_ UTF8String],"CallResult",0);
        dict_set_string([eventName_ UTF8String],[[eventName_ stringByAppendingFormat:@"_result"] UTF8String],[requestResult_ UTF8String]);
    }
    else {
        dict_set_int([eventName_ UTF8String],"CallResult",1);
    }
    
    call_lua("event_call");
}

- (void)dealloc
{
    [eventName_ release];
    [requestResult_ release];
    [super dealloc];
}
@end
