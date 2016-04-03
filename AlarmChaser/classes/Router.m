//
//  Router.m
//  AlarmChaser
//
//  Created by as on 2015/05/15.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Router.h"
#import "UserDefalutManager.h"
#import "AlarmManager.h"


static Router *sharedManager;

@implementation Router

+ (Router *)sharedManager{
    
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
 *  アラーム解除ViewControllerへ遷移する
 */
-(void)gotoAwakeAlarmViewController:(BOOL)isAnimate{
    
    //通知がきたら
    if( [UIApplication sharedApplication].applicationIconBadgeNumber > 0 ){
        
        //アラーム解除画面を表示していない場合 かつ　広告が表示されていなければ
        if(![[UserDefalutManager sharedManager] getDisplayedAwakeAlarmView] && ![[AlarmManager sharedManager] isAdView]){
            
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *nextVC = [topController.storyboard instantiateViewControllerWithIdentifier:[sharedManager getGotoAwakeAlarmViewControllerID] ];
            
            [topController presentViewController:nextVC animated:isAnimate completion:nil];
        }
    }
}

/**
 *  遷移先のアラーム解除ViewControllerのIDを取得する
 *
 *  @return UIViewController
 */
-(NSString *)getGotoAwakeAlarmViewControllerID{
    
    NSArray *awakeVC = @[@"CalcViewController",@"ShakeViewController"];
    
    NSString *nextVCID = awakeVC[arc4random()%awakeVC.count];
    
    return nextVCID;
}


/**
 *  アラーム解除画面を表示
 */
-(void)displayAwakeAlarmView{
    [sharedManager gotoAwakeAlarmViewController:YES];    
}


@end
