//
//  TimeManager.m
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "TimeManager.h"

static TimeManager *sharedManager;

@implementation TimeManager

+ (TimeManager *)sharedManager{
    
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

#pragma mark - functional


/**
 *  現在時刻を返す
 *
 *  @return NSMutableDictionary {year,month,day,hour,minute,monthStr}
 */
-(NSMutableDictionary *)getNowDate{
    
    NSMutableDictionary *resultDate = [[NSMutableDictionary alloc]init];

    NSDate *nowDate                 = [NSDate new];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    
    NSUInteger flags                = NSYearCalendarUnit
                                        | NSMonthCalendarUnit
                                        | NSDayCalendarUnit
                                        | NSHourCalendarUnit
                                        | NSMinuteCalendarUnit
                                        | NSSecondCalendarUnit;

    NSDateComponents *comps         = [calendar components:flags fromDate:nowDate];

    NSDateFormatter* dataformat     = [[NSDateFormatter alloc] init];
    dataformat.locale               = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    
    NSString* monthStr              = dataformat.shortMonthSymbols[comps.month-1];
    
    resultDate[@"year"]             = [NSString stringWithFormat:@"%ld",comps.year];
    resultDate[@"month"]            = [NSString stringWithFormat:@"%02ld",comps.month];
    resultDate[@"day"]              = [NSString stringWithFormat:@"%02ld",comps.day];
    resultDate[@"hour"]             = [NSString stringWithFormat:@"%02ld",comps.hour];
    resultDate[@"minute"]           = [NSString stringWithFormat:@"%02ld",comps.minute];
    resultDate[@"second"]           = [NSString stringWithFormat:@"%02ld",comps.second];
    resultDate[@"monthStr"]         = monthStr;
    
    return resultDate;
}


/**
 *  引数で指定したNSDateから時間と分数を返却する
 *
 *  @param assginDate
 *
 *  @return NSMutableDictionary {hour,minute}
 */
-(NSMutableDictionary *)getAssignDate:(NSDate *)assginDate{
    NSMutableDictionary *resultDate = [[NSMutableDictionary alloc]init];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    
    NSUInteger flags                = NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDateComponents *comps         = [calendar components:flags fromDate:assginDate];
    
    resultDate[@"hour"]             = [NSString stringWithFormat:@"%02ld",comps.hour];
    resultDate[@"minute"]           = [NSString stringWithFormat:@"%02ld",comps.minute];
    
    return resultDate;
}

/**
 *  時間と分数より今日日付のNSDateを作成する
 *
 *  @return NSDate
 */
-(NSDate *)createDateFromHM:(NSString *)hour assginMinute:(NSString *)minute{
    
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;

    // 時間を取得
    flags                        = NSYearCalendarUnit
                                    | NSMonthCalendarUnit
                                    | NSDayCalendarUnit
                                    | NSHourCalendarUnit
                                    | NSMinuteCalendarUnit;
    
    comps                        = [calendar components:flags fromDate:[NSDate new]];

    // NSDateComponents を作成して、そこに作成したい情報をセットします。
    NSDateComponents* components = [[NSDateComponents alloc] init];

    components.year              = comps.year;
    components.month             = comps.month;
    components.day               = comps.day;
    components.hour              = [hour intValue];
    components.minute            = [minute intValue];
    components.second            = 0;

    NSDate *resultDate           = [calendar dateFromComponents:components];
   

    return resultDate;
}


/**
 *  指定したNSDateから整形したNSDateを作成する（０秒のもので起算）
 *
 *  @param assginDate
 *
 *  @return NSDate
 */
-(NSDate *)createTrimDateFromNSDate:(NSDate *)assginDate{
    
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;

    // 時間を取得
    flags                        = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    comps                        = [calendar components:flags fromDate:assginDate];

    // NSDateComponents を作成して、そこに作成したい情報をセットします。
    NSDateComponents* components = [[NSDateComponents alloc] init];

    components.year              = comps.year;
    components.month             = comps.month;
    components.day               = comps.day;
    components.hour              = comps.hour;
    components.minute            = comps.minute;
    components.second            = 0;

    // NSCalendar を使って、NSDateComponents を NSDate に変換します。
    NSDate *adjustDate           = [calendar dateFromComponents:components];
    
    return adjustDate;
}


/**
 *  アラームデータに変換
 *
 *  @param assginDate
 *
 *  @return NSDate
 */
-(NSDate *)convertAlarmDate:(NSDate *)assginDate{
    
    NSTimeInterval nowDate = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval checkDate = [assginDate timeIntervalSince1970];
    
    
    //指定された日付が現在時刻より過去であれば、明日日付にして返却
    if(checkDate <= nowDate){
        
        NSCalendar *calendar         = [NSCalendar currentCalendar];
        NSUInteger flags;
        NSDateComponents *comps;
        
        // 時間を取得
        flags                        = NSYearCalendarUnit
        | NSMonthCalendarUnit
        | NSDayCalendarUnit
        | NSHourCalendarUnit
        | NSMinuteCalendarUnit;
        
        comps                        = [calendar components:flags fromDate:assginDate];
        
        // NSDateComponents を作成して、そこに作成したい情報をセットします。
        NSDateComponents* components = [[NSDateComponents alloc] init];
        
        components.year              = comps.year;
        components.month             = comps.month;
        components.day               = comps.day + 1;
        components.hour              = comps.hour;
        components.minute            = comps.minute;
        components.second            = 0;
        
        NSDate *resultDate           = [calendar dateFromComponents:components];
        
        return resultDate;
        
        
    }else{
        
        return assginDate;
    }
    
    
}


@end
