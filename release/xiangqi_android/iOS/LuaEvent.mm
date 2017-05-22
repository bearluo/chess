//
//  LuaEvent.m
//  babe_ios
//
//  Created by  on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.

//external c/c++ function from babe
extern "C"
{
    int dict_set_string ( const char* strGroup, const char* strKey, const char* strValue );
    const char* dict_get_string ( const char* strGroup, const char* strKey );
    int dict_set_int ( const char* strGroup, const char* strKey, const int iValue );
    int dict_set_double ( const char* strGroup, const char* strKey, double fValue );
    int call_lua ( const char* strFunctionName );
}

#import "LuaEvent.h"
#import "FBPlatform.h"
#import "SinaWeiboPlatform.h"
#import "GuestPlatform.h"


@implementation LuaEvent

-(void)GuestZhLogin
{
    [GuestPlatform sharedPlatform].EventName = @"GuestZhLogin";
    [[GuestPlatform sharedPlatform] login];
}

-(void)GusetZhLogout
{
    [GuestPlatform sharedPlatform].EventName = @"GuestZhLogout";
    [[GuestPlatform sharedPlatform] logout];
}

-(void)FBLogin
{
    [FBPlatform sharedPlatform].EventName = @"FBLogin";
    [[FBPlatform sharedPlatform] login];
}

-(void)FBLogout
{
    [FBPlatform sharedPlatform].EventName = @"FBLogout";
    [[FBPlatform sharedPlatform] logout];

}

-(void)FBUninstall
{
    [FBPlatform sharedPlatform].EventName = @"FBUninstall";
    [[FBPlatform sharedPlatform] uninstall];
}

-(void)SinaLogin
{
    [SinaWeiboPlatform sharedPlatform].EventName = @"SinaLogin";
    [[SinaWeiboPlatform sharedPlatform] login];
}

-(void)SinaLogout
{
    [SinaWeiboPlatform sharedPlatform].EventName = @"SinaLogout";
    [[SinaWeiboPlatform sharedPlatform] logout];
}

-(void)GetLocalPathWithURL
{
    const char* eventName = "GetLocalPathWithURL";
    const char* url = dict_get_string(eventName,"url");
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithCString:url encoding:NSUTF8StringEncoding]]]];
    
    NSString* imageDirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/images"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirPath]) {
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        [fileManager createDirectoryAtPath:imageDirPath attributes:nil];
        [fileManager release];
    }
    
    NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/images/download.png"];
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    dict_set_string(eventName, eventName, [@"download.png" UTF8String]);
}

-(void)GetBatteryLevel
{
    const char* eventName = "GetButtteryLevel";
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float level = [[UIDevice currentDevice] batteryLevel];
    dict_set_double(eventName, eventName, level);
}

-(void)UploadImage
{
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片选取" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"选取现有照片",@"照相", nil];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片选取" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"选取现有照片", nil];
    }
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    
    UIViewController* viewControoler = [[[UIApplication sharedApplication] delegate] viewController];
    [actionSheet showFromRect:[viewControoler.view frame] inView:viewControoler.view animated:YES];
    [actionSheet release];
}

#pragma mark - 
#pragma UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        UIViewController* viewControoler = [[[UIApplication sharedApplication] delegate] viewController];
        [popover presentPopoverFromRect:[viewControoler.view frame] inView:viewControoler.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [imagePickerController release];
        popoverController_ = popover;
    }
    else if (buttonIndex == 1){
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.allowsEditing = YES;
        UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        UIViewController* viewControoler = [[[UIApplication sharedApplication] delegate] viewController];
        [popover presentPopoverFromRect:[viewControoler.view frame] inView:viewControoler.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [imagePickerController release];
        popoverController_ = popover;
    }
}


#pragma mark  -
#pragma mark imagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
	[picker dismissModalViewControllerAnimated:YES];
    NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imagePicker.png"];
    [UIImagePNGRepresentation(img) writeToFile:pngPath atomically:YES];
    [popoverController_ dismissPopoverAnimated:YES];
    
    dict_set_string("UploadImage", "UploadImage", [pngPath UTF8String]);
}

@end
