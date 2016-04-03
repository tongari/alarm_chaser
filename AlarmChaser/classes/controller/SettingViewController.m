//
//  SettingViewController.m
//  AlarmChaser
//
//  Created by as on 2015/05/12.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "SettingViewController.h"
#import "UserDefalutManager.h"
#import "TimeManager.h"
#import "AlarmManager.h"
#import <iAd/iAd.h>
#import "Router.h"


@interface SettingViewController ()<ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *alarmTimeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *alarmDatePicker;
@property (weak, nonatomic) IBOutlet UISwitch *alarmTimeSwitch;

@property (strong,nonatomic) UserDefalutManager *userDef;
@property (strong,nonatomic) TimeManager *timeManager;

- (IBAction)onChangeDatePicker:(UIDatePicker *)sender;
- (IBAction)onAlarmSwitch:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *icoChaser;
@property (weak, nonatomic) IBOutlet UIImageView *icoAlarm;

@property(strong,nonatomic)ADBannerView *adView;

@end

@implementation SettingViewController

#pragma mark - functional contoroller method
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.title = @"アラーム設定";
    
    self.userDef = [UserDefalutManager sharedManager];
    self.timeManager = [TimeManager sharedManager];
    
    
    self.adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    self.adView.hidden = YES;
    self.adView.alpha = 0;
    self.adView.delegate = self;
    [self.view addSubview:self.adView];
    CGFloat bannerPosY = self.view.frame.size.height - self.adView.frame.size.height;
    self.adView.frame = CGRectMake(0, bannerPosY, self.adView.frame.size.width, self.adView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //UsefDefaultの値をみてアラームスイッチのトグルを設定
    self.alarmTimeSwitch.on = [self.userDef getDefaultAlarm];
    [self setStateIcoAlarm];
    
    //UsefDefaultの値をみてDatePickerの値を設定
    NSMutableDictionary *alarmTime = [self.userDef getDefaultAlarmTime];
    NSDate *createDate = [self.timeManager createDateFromHM:alarmTime[@"hour"] assginMinute:alarmTime[@"minute"]];
    [self.alarmDatePicker setDate:createDate];
        
    [self displayAlarmTimeToLabel];
    
//    //遷移元をチェック
//    NSArray *controllers = [self.navigationController viewControllers];
//    UIViewController *caller = [controllers objectAtIndex:[controllers count]-2];
//    
//    
//    if([caller isMemberOfClass:[ClockViewController class]]){
//        NSLog(@"ClockViewController");
//    }
//    
//    else if ([caller isMemberOfClass:[CalcViewController class]]) {
//        
//        NSLog(@"CalcViewController");
////        self.interstitialPresentationPolicy =  ADInterstitialPresentationPolicyManual;
////        //意図したタイミングで
////        [self requestInterstitialAdPresentation];
//    }
//    else if([caller isMemberOfClass:[ShakeViewController class]]){
//        NSLog(@"ShakeViewController");
//    }
    
}


/**
 *  datePickerの値のチェンジイベントを補足
 *
 *  @param sender
 */
- (IBAction)onChangeDatePicker:(UIDatePicker *)sender {
    if(self.alarmTimeSwitch.on){

        //アラームの時間を保存
        [self saveAlarmTime];
        [self displayAlarmTimeToLabel];
        
        //タイマー生成
        [self clearAlarmTimer ];
        [self createAlarmTimer];
    }
    
}

/**
 *  アラームスイッチのイベントを補足
 *
 *  @param sender sender description
 */
- (IBAction)onAlarmSwitch:(UISwitch *)sender {
    if(sender.on){
        
        //アラームの時間を保存
        [self saveAlarmTime];
        [self displayAlarmTimeToLabel];
        
        //タイマー生成
        [self clearAlarmTimer ];
        [self createAlarmTimer];
        [self.userDef setDefaultAlarm:YES];
        
        [self confirmNotificationAlert];
        
    } else {

         //タイマー削除
        [self clearAlarmTimer];
        [self.userDef setDefaultAlarm:NO];
        [self.userDef setDisplayedAwakeAlarmView:NO];
    }
    
    [self setStateIcoAlarm];
}

/**
 *  アラームタイマーを生成
 */
-(void)createAlarmTimer{
    
    NSDate *trimDate = [self.timeManager createTrimDateFromNSDate:self.alarmDatePicker.date];
    
    AlarmManager *alarmManager = [AlarmManager sharedManager];
    [alarmManager setLocalNotification:[self.timeManager convertAlarmDate:trimDate]];    
}

/**
 *  アラームタイマーを削除
 */
-(void)clearAlarmTimer{
    
    AlarmManager *alarmManager = [AlarmManager sharedManager];
    
    [alarmManager clearLocalNotification ];
}


/**
 *  アラーム時刻を保存
 */
- (void)saveAlarmTime{
    NSMutableDictionary *dict = [self.timeManager getAssignDate:self.alarmDatePicker.date];
    
    [ self.userDef setDefaultAlarmTime:[@{@"hour":dict[@"hour"],@"minute":dict[@"minute"]}mutableCopy] ];
}



#pragma mark - functonal view method

/**
 *  ラベルにアラームを表示させる
 */
-(void)displayAlarmTimeToLabel{
    //ユーザデフォルトで保持してるものからひっぱる。
    NSDictionary *alarmTimeObj = [self.userDef getDefaultAlarmTime];
    NSString *setStr = [NSString stringWithFormat:@"%@:%@",alarmTimeObj[@"hour"],alarmTimeObj[@"minute"]];
    
    self.alarmTimeLabel.text = setStr;
}

-(void)confirmNotificationAlert{
    
    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1){
        return;
    }
    
    UIUserNotificationSettings *currentSettings = [[UIApplication
                                                    sharedApplication] currentUserNotificationSettings];
    
    if(currentSettings.types == UIUserNotificationTypeNone){
        
        // コントローラを生成
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"通知の設定"
                                                                     message:@"通知の設定が許可されていません。\nアラームが鳴らない場合があります。\n通知の設定を有効にしてください。"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        // OK用のアクションを生成
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // ボタンタップ時の処理
                                                              //NSLog(@"OK button tapped.");
                                                          }];
        // コントローラにアクションを追加
        [ac addAction:okAction];
        
        // アラート表示処理
        [self presentViewController:ac animated:YES completion:nil];
    }
}

/**
 *  アラームアイコンの設定
 */
-(void)setStateIcoAlarm{
    if([[UserDefalutManager sharedManager] getDefaultAlarm]){
        self.icoChaser.hidden = NO;
        self.icoAlarm.hidden = YES;
        
    } else {
        
        self.icoChaser.hidden = YES;
        self.icoAlarm.hidden = NO;
    }
}


#pragma mark - ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    self.adView.hidden = NO;
    self.adView.alpha = 1;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    
    [[AlarmManager sharedManager] setAdView:YES];
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{

    [[AlarmManager sharedManager] setAdView:NO];
    [[Router sharedManager] gotoAwakeAlarmViewController:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {

    self.adView.hidden = YES;
    self.adView.alpha = 0;
}


@end
