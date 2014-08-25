//
//  LSPushPluginAppDelegate.h
//
//  Created by Bobie on 6/17/13.
//  Copyright (c) 2013 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnPush.h"
#import "WLCordovaAppDelegate.h"

@interface LSPushPluginAppDelegate : WLCordovaAppDelegate <UIApplicationDelegate, AnPushDelegate>
@property (strong, nonatomic) UIWindow *window;

@end
