//
//  AppDelegate.m
//  AlarmChaser
//
//  Created by as on 2015/05/12.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "AppDelegate.h"
#import "UserDefalutManager.h"
#import "AlarmManager.h"
#import "Router.h"

static NSString *DID_ENTER_BACKGROUND = @"CustomNotificationApplicationDidEnterBackground";
static NSString *DID_BECOME_ACTIVE = @"CustomNotificationApplicationDidBecomeActive";
static NSString *DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE = @"CustomNotificationDidReceiveLocalNotificationInActive";
static NSString *DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE = @"CustomNotificationDidReceiveLocalNotificationStateActive";
static NSString *DID_FINISH_LAUNCHING_WITH_OPTIONS = @"CustomNotificationDidFinishLaunchingWithOptions";


@interface AppDelegate ()

@end

@implementation AppDelegate


+(NSString *)CUSTOM_NOTIFICATION_DID_ENTER_BACKGROUND{
    return DID_ENTER_BACKGROUND;
}

+(NSString *)CUSTOM_NOTIFICATION_DID_BECOME_ACTIVE{
    return DID_BECOME_ACTIVE;
}

+(NSString *)CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE{
    return DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE;
}

+(NSString *)CUSTOM_NOTIFICATION_DID_FINISH_LAUNCHING_WITH_OPTIONS{
    return DID_FINISH_LAUNCHING_WITH_OPTIONS;
}

+(NSString *)CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE{
    return DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    UIImage *imageNormal = [[UIImage imageNamed:@"transparent"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,10,10)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:imageNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        
        // iOS8.0
        UIUserNotificationType types =
        UIUserNotificationTypeBadge|
        UIUserNotificationTypeSound|
        UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [application registerUserNotificationSettings:mySettings];
    }
    
    
                
    [[AlarmManager sharedManager]setBgm];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter]
     postNotification:[NSNotification notificationWithName:DID_ENTER_BACKGROUND
                                                    object:self]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter]
     postNotification:[NSNotification notificationWithName:DID_BECOME_ACTIVE
                                                    object:self]];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.        
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    
    // アプリ起動中(フォアグラウンド)に通知が届いた場合
    if(application.applicationState == UIApplicationStateActive) {
        
        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE
                                                        object:self]];
        
    }
    
    // アプリがバックグラウンドにある状態で通知が届いた場合
    if(application.applicationState == UIApplicationStateInactive) {
        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE
                                                        object:self]];
    }
    
}

@end
