//
//  LightspeedPushCDVPlugin.h
//  LightspeedPushCDVPlugin
//
//  Created by Bobie on 10/16/13.
//  Copyright (c) 2013 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"

typedef enum {
    iOSNotificationTypeNone = 0,
    iOSNotificationTypeBadge = 1,
    iOSNotificationTypeSound = 2,
    iOSNotificationTypeAlert = 4,
    iOSNotificationTypeNewsstandContentAvailability = 8
}LightspeedPushiOSNotificationType;

/* Result & error messages */
static NSString* const kstrLSPushInvalidAppKey =                        @"LSPUSH_IOS_PLUGIN_ERROR_INVALID_APPKEY";
static NSString* const kstrLSPushInvalidArgument =                      @"LSPUSH_IOS_PLUGIN_ERROR_INVALID_ARGUMENT";
static NSString* const kstrLSPushFailedToRegisterRemoteNotification =   @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_REGISTER_REMOTE_NOTIFICATION";
static NSString* const kstrLSPushFailedToRegisterChannels =             @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_REGISTER_CHANNELS";
static NSString* const kstrLSPushFailedToUnregisterChannels =           @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_UNREGISTER_CHANNELS";
static NSString* const kstrLSPushInvalidNotificationPayload =           @"LSPUSH_IOS_PLUGIN_ERROR_INVALID_NOTIFICATION_PAYLOAD";
static NSString* const kstrLSPushFailedToSetMute =                      @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_SET_MUTE";
static NSString* const kstrLSPushFailedToClearMute =                    @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_CLEAR_MUTE";
static NSString* const kstrLSPushFailedToSetSilent =                    @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_SET_SILENT";
static NSString* const kstrLSPushFailedToClearSilent =                  @"LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_CLEAR_SILENT";

@interface LightspeedPushCDVPlugin : CDVPlugin

/* Initialization */
- (LightspeedPushCDVPlugin*)initWithWebView:(UIWebView*)webView;

/* Internal APIs for AppDelegate */
+ (LightspeedPushCDVPlugin*)sharedLightspeedPushCDVPlugin;
- (void)registerForRemoteNotificationResult:(BOOL)bSuccess token:(NSData*)deviceToken error:(NSError*)error;
- (void)registerChannelsResult:(BOOL)bSuccess anid:(NSString*)anid error:(NSString*)error;
- (void)unregisterChannelsResult:(BOOL)bSuccess error:(NSString*)error;
- (void)remoteNotificationReceived:(NSDictionary*)dictUserInfo;
- (void)setMuteResult:(BOOL)bSuccess error:(NSString*)error;
- (void)clearMuteResult:(BOOL)bSuccess error:(NSString*)error;
- (void)setSilentResult:(BOOL)bSuccess error:(NSString*)error;
- (void)clearSilentResult:(BOOL)bSuccess error:(NSString*)error;


/* Plug-in APIs */

/* registerForRemoteNotification
    [purpose]
        Use this API once the application is launched to setup Lightspeed push-notification services
    [parameters]
        A JSON dictionary at the first index of the command parameter array.
        Keys:
            - "iOSRemoteNotificationTypes"
                Use |(or) notation to combine the settings in LightspeedPushiOSNotificationType you 
                need to support in your application.
                If this parameter is not provided, the plug-ing will use 
                (iOSNotificationTypeBadge | iOSNotificationTypeSound | iOSNotificationTypeAlert) by default.
            - "channelsToRegister"
                Array with string values of channels to be registered
            - "appKey"
                String, Lightspeed App-key from administration console
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_INVALID_APPKEY"
            - No app key provided in the JSON parameter
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_REGISTER_REMOTE_NOTIFICATION"
            - This error might happen due to invalid app key or other server
 */
- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command;


/* registerChannels
    [purpose]
        Specify channels to be registered for remote notifications
    [parameters]
        A JSON dictionary at the first index of the command parameter array.
        Keys:
            - "channels"
                Array with string values of channels to be registered
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_REGISTER_CHANNELS"
    [note]
        If the client tries to register a channel which has already been registered for this
        device, the channel will remain registered
 */
- (void)registerChannels:(CDVInvokedUrlCommand*)command;


/* unregisterChannels
    [purpose]
        Specify channels to be unregistered for remote notifications
    [parameters]
        A JSON dictionary at the first index of the command parameter array.
        Keys:
        - "channels"
            Array with string values of channels to be unregistered
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_UNREGISTER_CHANNELS"
 */
- (void)unregisterChannels:(CDVInvokedUrlCommand*)command;


/* setMute
    [purpose]
        If this API is used, the received remote-notification won't play any system sound
    [parameters]
        No parameters needed
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_SET_MUTE"
 */
- (void)setMute:(CDVInvokedUrlCommand*)command;


/* setMuteSchedule
    [purpose]
        Specify the a start time and duration; during the period, all Lightspeed remote notification will be received without any system sound played
    [parameters]
        A JSON dictionary at the first index of the command parameter array.
        Keys:
            - "hour"
                Integer (0~24), hour of the start time
            - "minute"
                Integer (0~59), minute of the start time
            - "duration"
                Integer, in seconds
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_SET_MUTE"
 */
- (void)setMuteSchedule:(CDVInvokedUrlCommand*)command;

/* clearMute
    [purpose]
        Clear the mute state
    [parameters]
        No parameters needed
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_CLEAR_MUTE"
 */
- (void)clearMute:(CDVInvokedUrlCommand*)command;


/* setSilentSchedule
    [purpose]
        Specify the a start time and duration; during the period, user won’t receive any remote notification from Lightspeed.
        A “resend” parameter can be specified whether to re-send the queued notification to the device during the silent period.
    [parameters]
        A JSON dictionary at the first index of the command parameter array.
        Keys:
            - "hour"
                Integer (0~24), hour of the start time
            - "minute"
                Integer (0~59), minute of the start time
            - "duration"
                Integer, in seconds
            - "resend"
                Boolean, whether to re-send the notification or not
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_SET_SILENT"
 */
- (void)setSilentSchedule:(CDVInvokedUrlCommand*)command;


/* clearMute
    [purpose]
        Clear the silent state
    [parameters]
        No parameters needed
    [possible errors]
        "LSPUSH_IOS_PLUGIN_ERROR_FAILED_TO_CLEAR_SILENT"
 */
- (void)clearSilent:(CDVInvokedUrlCommand*)command;


/* monitorReceivedRemoteNotification
    [purpose]
        Use this API wherever a module needs to handle the received remote notification
    [parameters]
        No parameters needed
    [possible errors]
        No error will be returned
    [note]
        By executing this API, the callback-ID will be kept in the plug-in and the plug-in 
        will notify the client via the callback-ID when the notification is received.
        Only one callback-ID will be kept at one time.
 */
- (void)monitorReceivedRemoteNotification:(CDVInvokedUrlCommand*)command;

@end
