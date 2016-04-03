//
//  UserDefalutManager.h
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserDefalutManager : NSObject

+(UserDefalutManager *)sharedManager;

#define kAlarmTimeKey @"AlarmChaserUserDefalutAlarmTime"
#define kIsAlarmKey @"AlarmChaserUserDefalutAlarm"
#define kIsBgmPlayKey @"AlarmChaserUserDefalutBgmPlay"
#define kIsDisplayedAwakeAlarmViewKey @"AlarmChaserUserDefalutDisplayedAwakeAlarmView"
#define kAlarmTimerDateKey @"AlarmChaserUserDefalutAlarmTimerDate"

//extern const NSString *kAlarmTimeKey;

//アラームの時分を保持
-(NSMutableDictionary *)getDefaultAlarmTime;
-(void)setDefaultAlarmTime:(NSMutableDictionary *)element;

//アラームがONかOFFか
-(BOOL)getDefaultAlarm;
-(void)setDefaultAlarm:(BOOL)isAlarm;


//アラーム解除画面にいるか否か
-(BOOL)getDisplayedAwakeAlarmView;
-(void)setDisplayedAwakeAlarmView:(BOOL)isView;

//アラームタイマー（NSDate値）の保持
-(NSDate *)getAlarmTimerDate;
-(void)setAlarmTimerDate:(NSDate *)alarmTimerDate;

@end
