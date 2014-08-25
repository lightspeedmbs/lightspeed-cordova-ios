//
//  LSPushPluginAppDelegate.m
//
//  Created by Bobie on 6/17/13.
//  Copyright (c) 2013 Herxun. All rights reserved.
//

#import "LSPushPluginAppDelegate.h"
#import "LightspeedPushCDVPlugin.h"

@implementation LSPushPluginAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL ret = [super application:application didFinishLaunchingWithOptions:launchOptions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWLNativeInit:) name:@"didFinishWLNativeInit" object:nil];
    return ret;
}

-(void) didFinishWLNativeInit:(NSNotification *)notification {
    /*
     * If you need to do any extra app-specific initialization, you can do it here.
     * Note: At this point webview is available.
     **/
    
}

#pragma mark - remote notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (plugin)
    {
        BOOL bSuccess = YES;
        [plugin registerForRemoteNotificationResult:bSuccess token:deviceToken error:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (plugin)
    {
        BOOL bSuccess = NO;
        [plugin registerForRemoteNotificationResult:bSuccess token:nil error:error];
    }
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (application.applicationState == UIApplicationStateActive)
    {
        /* do something, if needed */
    }
    
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (plugin)
    {
        [plugin remoteNotificationReceived:userInfo];
    }
}

#pragma mark - Lightspeed Push Delegate
- (void)didRegistered:(NSString *)anid withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;

    if (![error isEqualToString:@""] || !anid || [anid isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin registerChannelsResult:bSuccess anid:@"" error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin registerChannelsResult:bSuccess anid:anid error:@""];
    }
}

- (void)didUnregistered:(BOOL)success withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;
    
    if (!success || ![error isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin unregisterChannelsResult:bSuccess error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin unregisterChannelsResult:bSuccess error:@""];
    }
}

- (void)didSetMute:(BOOL)success withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;
    
    if (!success || ![error isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin setMuteResult:bSuccess error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin setMuteResult:bSuccess error:@""];
    }
}

- (void)didClearMute:(BOOL)success withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;
    
    if (!success || ![error isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin clearMuteResult:bSuccess error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin clearMuteResult:bSuccess error:@""];
    }
}

- (void)didSetSilent:(BOOL)success withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;
    
    if (!success || ![error isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin setSilentResult:bSuccess error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin setSilentResult:bSuccess error:@""];
    }
}

- (void)didClearSilent:(BOOL)success withError:(NSString *)error
{
    LightspeedPushCDVPlugin* plugin = [LightspeedPushCDVPlugin sharedLightspeedPushCDVPlugin];
    if (!plugin)
        return;
    
    if (!success || ![error isEqualToString:@""])
    {
        BOOL bSuccess = NO;
        [plugin clearSilentResult:bSuccess error:error];
    }
    else
    {
        BOOL bSuccess = YES;
        [plugin clearSilentResult:bSuccess error:@""];
    }
}

#pragma mark - application lifecycle management
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSString *result = [super.viewController.webView stringByEvaluatingJavaScriptFromString:@"WL.App.BackgroundHandler.onAppEnteringBackground();"];
	if([result isEqualToString:@"hideView"]){
		[[self.viewController view] setHidden:YES];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSString *result = [super.viewController.webView stringByEvaluatingJavaScriptFromString:@"WL.App.BackgroundHandler.onAppEnteringForeground();"];
	if([result isEqualToString:@"hideViewToForeground"]){
		[[self.viewController view] setHidden:NO];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [super applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
