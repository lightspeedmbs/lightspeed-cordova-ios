//
//  LightspeedPushCDVPlugin.m
//  LightspeedPushCDVPlugin
//
//  Created by Bobie on 10/16/13.
//  Copyright (c) 2013 Herxun. All rights reserved.
//

#import "LightspeedPushCDVPlugin.h"
#import "CDVPlugin.h"
#import "AnPush.h"
#import "LSPushPluginAppDelegate.h"

static LightspeedPushCDVPlugin* m_sharedInstance;

@interface LightspeedPushCDVPlugin ()

/* CDVPlugin callback */
@property (nonatomic, strong) NSString* strCallbackId;
@property (nonatomic, strong) NSString* strNotificationCallbackId;

/* Controls */
@property (nonatomic, strong) NSString* strLightspeedAppKey;
@property (nonatomic, strong) NSMutableArray* arrayChannelsToRegister;
@property (nonatomic, strong) NSMutableArray* arrayChannelsToUnregister;
@property (nonatomic, assign) BOOL bLightspeedSetup;

@end

@implementation LightspeedPushCDVPlugin

- (LightspeedPushCDVPlugin*)initWithWebView:(UIWebView*)webView
{
    if (!m_sharedInstance)
    {
        m_sharedInstance = (LightspeedPushCDVPlugin*)[super initWithWebView:webView];
    }
    
    return m_sharedInstance;
}

+ (LightspeedPushCDVPlugin*)sharedLightspeedPushCDVPlugin
{
    return m_sharedInstance;
}

#pragma mark - setup remote notificaion
- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command
{
    self.strCallbackId = command.callbackId;
    
    NSDictionary* dictParameters = [command.arguments objectAtIndex:0];
    
    NSInteger nRemoteNotificationTypes = iOSNotificationTypeBadge | iOSNotificationTypeSound | iOSNotificationTypeAlert;
    if ([dictParameters objectForKey:@"iOSRemoteNotificationTypes"])
    {
        nRemoteNotificationTypes = [[dictParameters objectForKey:@"iOSRemoteNotificationTypes"] intValue];
    }
    
    if ([dictParameters objectForKey:@"channelsToRegister"])
    {
        self.arrayChannelsToRegister = [dictParameters objectForKey:@"channelsToRegister"];
    }
    
    if ([dictParameters objectForKey:@"appKey"])
    {
        self.strLightspeedAppKey = [dictParameters objectForKey:@"appKey"];
    }
    else
    {
        BOOL bGood = NO;
        [self _sendCommandResult:bGood resultCode:kstrLSPushInvalidAppKey callbackId:command.callbackId];
    }
    
    [AnPush registerForPushNotification:(UIRemoteNotificationType)nRemoteNotificationTypes];
}

- (void)registerForRemoteNotificationResult:(BOOL)bSuccess token:(NSData*)deviceToken error:(NSError*)error
{
    if (bSuccess && deviceToken != nil)
    {
        LSPushPluginAppDelegate* appDelegate = (LSPushPluginAppDelegate*)[[UIApplication sharedApplication] delegate];
        [AnPush setup:self.strLightspeedAppKey deviceToken:deviceToken delegate:appDelegate secure:YES];
        
        if ([self.arrayChannelsToRegister count])
        {
            [[AnPush shared] register:self.arrayChannelsToRegister overwrite:YES];
        }
    }
    else
    {
        BOOL bGood = NO;
        [self _sendCommandResult:bGood resultCode:kstrLSPushFailedToRegisterRemoteNotification callbackId:self.strCallbackId];
    }
}

#pragma mark - register/unregister for channels
- (void)registerChannels:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dictParameter = [command.arguments objectAtIndex:0];
    if ([dictParameter objectForKey:@"channels"])
    {
        if (!self.arrayChannelsToRegister)
        {
            self.arrayChannelsToRegister = [NSMutableArray arrayWithCapacity:0];
        }
        
        NSArray* arrayChannels = [dictParameter objectForKey:@"channels"];
        for (NSString* strChannel in arrayChannels)
        {
            if (![self.arrayChannelsToRegister containsObject:strChannel])
            {
                [self.arrayChannelsToRegister addObject:strChannel];
            }
        }
    }
    
    if (self.bLightspeedSetup)
    {
        [[AnPush shared] register:self.arrayChannelsToRegister overwrite:YES];
        [self.arrayChannelsToRegister removeAllObjects];
    }
}

- (void)unregisterChannels:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dictParameter = [command.arguments objectAtIndex:0];
    if ([dictParameter objectForKey:@"channels"])
    {
        if (!self.arrayChannelsToUnregister)
        {
            self.arrayChannelsToUnregister = [NSMutableArray arrayWithCapacity:0];
        }
        
        NSArray* arrayChannels = [dictParameter objectForKey:@"channels"];
        for (NSString* strChannel in arrayChannels)
        {
            if (![self.arrayChannelsToUnregister containsObject:strChannel])
            {
                [self.arrayChannelsToUnregister addObject:strChannel];
            }
        }
    }
    
    if (self.bLightspeedSetup)
    {
        [[AnPush shared] unregister:self.arrayChannelsToUnregister];
        [self.arrayChannelsToUnregister removeAllObjects];
    }
}

- (void)registerChannelsResult:(BOOL)bSuccess anid:(NSString*)anid error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToRegisterChannels callbackId:self.strCallbackId];
    }
}

- (void)unregisterChannelsResult:(BOOL)bSuccess error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToUnregisterChannels callbackId:self.strCallbackId];
    }
}

#pragma mark - mute & silent
- (void)setMute:(CDVInvokedUrlCommand*)command
{
    self.strCallbackId = command.callbackId;
    
    [[AnPush shared] setMute];
}

- (void)setMuteSchedule:(CDVInvokedUrlCommand*)command;
{
    self.strCallbackId = command.callbackId;
    
    NSDictionary* dictParameter = [command.arguments objectAtIndex:0];
    
    BOOL bInvalidHour = NO;
    NSInteger nHour = 0;
    if ([dictParameter objectForKey:@"hour"])
    {
        nHour = [[dictParameter objectForKey:@"hour"] intValue];
        if (!(nHour >= 0 && nHour <= 23))
        {
            bInvalidHour = YES;
        }
    }
    else
    {
        bInvalidHour = YES;
    }

    BOOL bInvalidMinute = NO;
    NSInteger nMinute = 0;
    if ([dictParameter objectForKey:@"minute"])
    {
        nMinute = [[dictParameter objectForKey:@"minute"] intValue];
        if (!(nMinute >= 0 && nMinute <= 59))
        {
            bInvalidMinute = YES;
        }
    }
    else
    {
        bInvalidMinute = YES;
    }
    
    BOOL bInvalidDuration = NO;
    NSInteger nDuration = 0;
    if ([dictParameter objectForKey:@"duration"])
    {
        nDuration = [[dictParameter objectForKey:@"duration"] intValue];
    }
    else
    {
        bInvalidDuration = YES;
    }
    
    if (bInvalidHour || bInvalidMinute || bInvalidDuration)
    {
        BOOL bGood = NO;
        [self _sendCommandResult:bGood resultCode:kstrLSPushInvalidArgument callbackId:self.strCallbackId];
        return;
    }
    
    [[AnPush shared] setMuteWithHour:nHour minute:nMinute duration:nDuration];
}

- (void)clearMute:(CDVInvokedUrlCommand*)command
{
    self.strCallbackId = command.callbackId;
    
    [[AnPush shared] clearMute];
}

- (void)setSilentSchedule:(CDVInvokedUrlCommand *)command
{
    self.strCallbackId = command.callbackId;
    
    NSDictionary* dictParameter = [command.arguments objectAtIndex:0];
    
    BOOL bInvalidHour = NO;
    NSInteger nHour = 0;
    if ([dictParameter objectForKey:@"hour"])
    {
        nHour = [[dictParameter objectForKey:@"hour"] intValue];
        if (!(nHour >= 0 && nHour <= 23))
        {
            bInvalidHour = YES;
        }
    }
    else
    {
        bInvalidHour = YES;
    }
    
    BOOL bInvalidMinute = NO;
    NSInteger nMinute = 0;
    if ([dictParameter objectForKey:@"minute"])
    {
        nMinute = [[dictParameter objectForKey:@"minute"] intValue];
        if (!(nMinute >= 0 && nMinute <= 59))
        {
            bInvalidMinute = YES;
        }
    }
    else
    {
        bInvalidMinute = YES;
    }
    
    BOOL bInvalidDuration = NO;
    NSInteger nDuration = 0;
    if ([dictParameter objectForKey:@"duration"])
    {
        nDuration = [[dictParameter objectForKey:@"duration"] intValue];
    }
    else
    {
        bInvalidDuration = YES;
    }
    
    if (bInvalidHour || bInvalidMinute || bInvalidDuration)
    {
        BOOL bGood = NO;
        [self _sendCommandResult:bGood resultCode:kstrLSPushInvalidArgument callbackId:self.strCallbackId];
        return;
    }
    
    BOOL bResend = NO;
    if ([dictParameter objectForKey:@"resend"])
    {
        bResend = [[dictParameter objectForKey:@"resend"] boolValue];
    }
    
    [[AnPush shared] setSilentWithHour:nHour minute:nMinute duration:nDuration resend:bResend];
}

- (void)clearSilent:(CDVInvokedUrlCommand*)command
{
    self.strCallbackId = command.callbackId;
    
    [[AnPush shared] clearSilent];
}

- (void)setMuteResult:(BOOL)bSuccess error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        NSLog(@"failed to set mute: %@", error);
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToSetMute callbackId:self.strCallbackId];
    }
}

- (void)clearMuteResult:(BOOL)bSuccess error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        NSLog(@"failed to clear mute: %@", error);
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToClearMute callbackId:self.strCallbackId];
    }
}

- (void)setSilentResult:(BOOL)bSuccess error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        NSLog(@"failed to set silent: %@", error);
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToSetSilent callbackId:self.strCallbackId];
    }
}

- (void)clearSilentResult:(BOOL)bSuccess error:(NSString*)error
{
    if (bSuccess)
    {
        [self _sendCommandResult:bSuccess resultCode:@"" callbackId:self.strCallbackId];
    }
    else
    {
        NSLog(@"failed to clear mute: %@", error);
        [self _sendCommandResult:bSuccess resultCode:kstrLSPushFailedToClearSilent callbackId:self.strCallbackId];
    }
}

#pragma mark - monitor & notify plug-in client that a notification has been received
- (void)monitorReceivedRemoteNotification:(CDVInvokedUrlCommand*)command
{
    self.strNotificationCallbackId = command.callbackId;
}

- (void)remoteNotificationReceived:(NSDictionary*)dictUserInfo
{
    if (![self.strNotificationCallbackId isEqualToString:@""])
    {
        NSString* strAlert = [[dictUserInfo objectForKey:@"aps"] objectForKey:@"alert"];
            
        BOOL bSuccess = YES;
        [self _sendCommandResult:bSuccess resultCode:strAlert callbackId:self.strNotificationCallbackId];
    }
}

#pragma mark - CDVPlugin command result
- (void)_sendCommandResult:(BOOL)bGood resultCode:(NSString*)strResultCode callbackId:(NSString*)callbackId
{
    CDVCommandStatus commandStatus = (bGood)? CDVCommandStatus_OK : CDVCommandStatus_ERROR;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:commandStatus messageAsString:strResultCode];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end
