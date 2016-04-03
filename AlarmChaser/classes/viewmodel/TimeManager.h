//
//  TimeManager.h
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeManager : NSObject

+(TimeManager *)sharedManager;

-(NSMutableDictionary *)getNowDate;
-(NSMutableDictionary *)getAssignDate:(NSDate *)assginDate;

-(NSDate *)createDateFromHM:(NSString *)hour assginMinute:(NSString *)minute;
-(NSDate *)createTrimDateFromNSDate:(NSDate *)assginDate;


-(NSDate *)convertAlarmDate:(NSDate *)assginDate;

@end
