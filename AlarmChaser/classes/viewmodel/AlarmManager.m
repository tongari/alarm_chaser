//
//  AlarmManager.m
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

#import "AlarmManager.h"
#import "AppDelegate.h"
#import "UserDefalutManager.h"
#import "Router.h"


@interface AlarmManager()

@property (strong,nonatomic) AVAudioPlayer *audio;
@property (strong,nonatomic) AVAudioSession *session;
@property (strong,nonatomic) NSTimer *alarmTimer;

@end


static AlarmManager *sharedManager;
static BOOL _isAdView;

@implementation AlarmManager

+ (AlarmManager *)sharedManager{
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        [[self alloc] init];        
    });
    
    return sharedManager;
    
}

+ (id)allocWithZone:(NSZone *)zone {
    
    __block id ret = nil;
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedManager = [super allocWithZone:zone];
        ret           = sharedManager;
    });
    
    return  ret;
    
}

- (id)copyWithZone:(NSZone *)zone{
    
    return self;
    
}


/**
 *  広告表示中か否か
 *
 *  @return
 */
-(BOOL)isAdView{
    
    return _isAdView;
}


/**
 *  広告表示中か否かを保存
 *
 *  @param isView
 */
-(void)setAdView:(BOOL)isView{
    
    _isAdView = isView;
}


#pragma mark - functional


/**
 *  BGMをセット
 */
-(void)setBgm{
    
    self.session             = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [self.session setActive:YES error:NULL];

    NSString *path           = [[NSBundle mainBundle] pathForResource:@"warning_04-high" ofType:@"mp3"];
    NSURL *url               = [NSURL fileURLWithPath:path];
    self.audio               = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audio.numberOfLoops = -1;
    [self.audio prepareToPlay];
    
    
    if([UIApplication sharedApplication].applicationIconBadgeNumber >0 ){
        
        [self.audio play];
    }
    
}

/**
 *  BGMをストップ
 */
-(void)stopBgm{
    
    [self.audio stop];
}

/**
 *  BGMを再生
 */
-(void)playBgm{
    
    [self.audio play];
    [[Router sharedManager] gotoAwakeAlarmViewController:YES];
}



/**
 *  ローカル通知を設定
 *
 *  @param assginDate NSDate
 */
-(void)setLocalNotification:(NSDate *)assginDate{
    
    
    UILocalNotification *notification       = [[UILocalNotification alloc] init];
    notification.fireDate                   = assginDate;
    notification.repeatCalendar             = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    notification.repeatInterval             = NSMinuteCalendarUnit;
    notification.timeZone                   = [NSTimeZone localTimeZone];
    notification.alertBody                  = @"追跡開始!";
    notification.soundName                  = @"warning_04-high.mp3";//UILocalNotificationDefaultSoundName;
    notification.alertAction                = @"アプリを起動";
    notification.applicationIconBadgeNumber = 1;
    
    // ローカル通知の登録
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //カスタム通知の登録
    [self setCustomEventNotification];
    
}


/**
 *  ローカル通知をクリア
 */
-(void)clearLocalNotification{
    
    
    //全ての通知をキャンセル
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //バッジも削除
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //カスタム通知の削除
    [self removeCustomEventNotification];
    
    [self stopBgm];
    
}

/**
 *  カスタムイベント通知の設定
 */
-(void)setCustomEventNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotificationInActive)
                                                 name:[AppDelegate CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotificationStateActive)
                                                 name:[AppDelegate CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotificationDidBecomeActive)
                                                 name:[AppDelegate CUSTOM_NOTIFICATION_DID_BECOME_ACTIVE]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotificationDidEnterBackGround)
                                                 name:[AppDelegate CUSTOM_NOTIFICATION_DID_ENTER_BACKGROUND]
                                               object:nil];
    
}

/**
 *  カスタムイベント通知を削除
 */
-(void)removeCustomEventNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_IN_ACTIVE] object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_RECEIVE_LOCAL_NOTIFICATION_STATE_ACTIVE] object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_BECOME_ACTIVE] object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_ENTER_BACKGROUND] object:nil];
}

/**
 *  バックグラウンドにて通知を受け取り通知領域をタップ後にアプリに復帰した際のイベントハンドラ
 */
-(void)onCustomNotificationInActive{

    [self playBgm];
}


/**
 *  フォアグランドにて通知を受け取った際のイベントハンドラ
 */
-(void)onCustomNotificationStateActive{    
    [self playBgm];
}


/**
 *  フォアグランド復帰のイベントハンドラ
 */
-(void)onCustomNotificationDidBecomeActive{
    
    if([UIApplication sharedApplication].applicationIconBadgeNumber >0 ){
        [self playBgm];
    }
    
}

/**
 *  バックグラウンドへ移動した際のイベントハンドラ
 */
-(void)onCustomNotificationDidEnterBackGround{
    [self stopBgm];
}


@end
