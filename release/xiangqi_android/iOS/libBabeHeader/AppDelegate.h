//
//  AppDelegate.h
//  babe_ios
//
//  Created by  on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

@class RootViewController;

@interface AppDelegate : UIResponder <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
    bool customiPhone1x_;
    bool customiPad2x_;
}

@property (nonatomic,readwrite) bool customiPhone1x;
@property (nonatomic,readwrite) bool customiPad2x; 

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *viewController;

-(id) init;

@end
