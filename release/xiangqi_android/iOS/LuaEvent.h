//
//  LuaEvent.h
//  babe_ios
//
//  Created by  on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LuaEvent : NSObject <UIActionSheetDelegate,UINavigationControllerDelegate ,UIImagePickerControllerDelegate>
{
    UIPopoverController* popoverController_;
}

-(void)GuestZhLogin;
-(void)GusetZhLogout;
-(void)FBLogin;
-(void)FBLogout;
-(void)FBUninstall;
-(void)SinaLogin;
-(void)SinaLogout;

-(void)GetLocalPathWithURL;
-(void)GetBatteryLevel;
-(void)UploadImage;
@end
