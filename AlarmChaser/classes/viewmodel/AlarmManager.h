//
//  AlarmManager.h
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmManager : NSObject

+(AlarmManager *)sharedManager;



-(void)setLocalNotification:(NSDate *)assginDate;
-(void)clearLocalNotification;

-(void)setBgm;
-(void)stopBgm;

-(BOOL)isAdView;
-(void)setAdView:(BOOL)isView;

@end
