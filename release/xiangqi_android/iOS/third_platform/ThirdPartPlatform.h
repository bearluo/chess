//
//  ThirdPartPlatform.h
//  DDZDouble
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern "C"
{
    int dict_set_string ( const char* strGroup, const char* strKey, const char* strValue );
    int dict_set_int ( const char* strGroup, const char* strKey, const int iValue );
    int call_lua ( const char* strFunctionName );
}

@interface ThirdPartPlatform : NSObject
{
    NSString* userInfo_;
    NSString* requestResult_;
    
    NSString* eventName_;
}

@property(nonatomic,readwrite,copy) NSString* RequestResult;
@property(nonatomic,readwrite,copy) NSString* EventName;

-(id) init;
-(void) didRequestEnd:(BOOL)result;
-(void) dealloc;
@end
