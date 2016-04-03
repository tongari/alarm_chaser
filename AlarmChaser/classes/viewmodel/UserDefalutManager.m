//
//  UserDefalutManager.m
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "UserDefalutManager.h"

static UserDefalutManager *sharedManager;
static NSUserDefaults *ud;


@implementation UserDefalutManager

+ (UserDefalutManager *)sharedManager{
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        [[self alloc] init];
        
        [sharedManager initDefaultData];
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

#pragma mark - functional

-(void)initDefaultData{
    
    // NSUserDefaultsに初期値を登録する
    ud = [NSUserDefaults standardUserDefaults];  // 取得
    //初期値Dictonary
    NSMutableDictionary *element = [@{
                                      @"hour":@"07",@"minute":@"00"
                                    }mutableCopy];
    //登録Dictonary
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kAlarmTimeKey] = element;
    
    //既に同じキーが存在する場合は初期値をセットせず、キーが存在しない場合だけ値をセット。
    [ud registerDefaults:dict];
}

/**
 *  アラームの時間を返却する
 *
 *  @return NSMutableDictionary
 */
-(NSMutableDictionary *)getDefaultAlarmTime{
    
    NSMutableDictionary *result = [[ud objectForKey:kAlarmTimeKey]mutableCopy];
    return result;
}

/**
 *  アラームの時間を保存
 *
 *  @param element
 */
-(void)setDefaultAlarmTime:(NSMutableDictionary *)element{
    [ud setObject:element forKey:kAlarmTimeKey];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}


/**
 * アラーム有無の状態を返却する
 *
 *  @return bool
 */
-(BOOL)getDefaultAlarm{
    return [ud boolForKey:kIsAlarmKey];
}


/**
 * アラームの有無を保存
 *
 *  @param isAlarm
 */
-(void)setDefaultAlarm:(BOOL)isAlarm{

    [ud setBool:isAlarm forKey:kIsAlarmKey];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}

/**
 *  アラーム解除中の画面にいたか否かを返却
 *
 *  @return
 */
-(BOOL)getDisplayedAwakeAlarmView{
    
    return [ud boolForKey:kIsDisplayedAwakeAlarmViewKey];
}


/**
 *  アラーム解除中画面にいるか否かを保存
 *
 *  @param isView
 */
-(void)setDisplayedAwakeAlarmView:(BOOL)isView{
    
    [ud setBool:isView forKey:kIsDisplayedAwakeAlarmViewKey];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}


/**
 *  アラームタイマーNSDate値を取得
 *
 *  @return
 */
-(NSDate *)getAlarmTimerDate{
    
    return [ud objectForKey:kAlarmTimerDateKey];
}


/**
 *  アラームタイマーNSDate値を設定
 *
 *  @param alarmTimerInterval
 */
-(void)setAlarmTimerDate:(NSDate *)alarmTimerDate{
    [ud setObject:alarmTimerDate forKey:kAlarmTimerDateKey];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}

@end
