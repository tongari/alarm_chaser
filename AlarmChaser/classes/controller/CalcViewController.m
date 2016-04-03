//
//  CalcViewController.m
//  AlarmChaser
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "CalcViewController.h"
#import "AlarmManager.h"
#import "UserDefalutManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <iAd/iAd.h>


//SystemSoundID errorSE;
//SystemSoundID sucessSE;

@interface CalcViewController ()<UIAlertViewDelegate>


@property(strong,nonatomic)NSMutableString *anserStr;

@property(assign,nonatomic)int questionA;
@property(assign,nonatomic)int questionB;

@property(assign,nonatomic)float updateLimitBarValue;
@property(assign,nonatomic)float stackUpdateLimitBarValue;

@property(strong,nonatomic)NSTimer *limitTimer;
@property(strong,nonatomic)NSTimer *tickerTimer;

@property (weak, nonatomic) IBOutlet UIView *limitBar;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property(assign,nonatomic)NSInteger curCalcKeyTagID;

@property(strong,nonatomic)AVAudioPlayer *errorSE;
@property(strong,nonatomic)AVAudioPlayer *sucessSE;


- (IBAction)onTapCalcKey:(UIButton *)sender;
- (IBAction)deleteBackKey:(UIButton *)sender;
- (IBAction)onTapAnserButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitMeterRightMargin;

@end

//制限時間 3sec
const float kLimitTime = 3.0f;

@implementation CalcViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // サウンドの準備
    NSString *pathErrorSE = [[NSBundle mainBundle] pathForResource:@"error_02" ofType:@"caf"];
    NSURL *urlErrorSE = [NSURL fileURLWithPath:pathErrorSE];
    self.errorSE = [[AVAudioPlayer alloc] initWithContentsOfURL:urlErrorSE error:nil];
    [self.errorSE prepareToPlay];
    
    NSString *pathSucessSE = [[NSBundle mainBundle] pathForResource:@"answer_02" ofType:@"caf"];
    NSURL *urlSucessSE = [NSURL fileURLWithPath:pathSucessSE];
    self.sucessSE = [[AVAudioPlayer alloc] initWithContentsOfURL:urlSucessSE error:nil];
    [self.sucessSE prepareToPlay];
        
    self.canDisplayBannerAds = YES;
    
    [[UserDefalutManager sharedManager] setDisplayedAwakeAlarmView:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //更新時に増加するリミットバーの値を算出
    self.updateLimitBarValue = [[UIScreen mainScreen]bounds].size.width / kLimitTime * 0.01;
    
    [self setQustion];
    [self createLimitbar];
    
    [self setCustomEventNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self destoryLimitbar];
    [self removeCustomEventNotification];
    
    [[UserDefalutManager sharedManager] setDisplayedAwakeAlarmView:NO];
}


/**
 *  カスタムイベント通知の設定
 */
-(void)setCustomEventNotification{
    
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
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_BECOME_ACTIVE] object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[AppDelegate CUSTOM_NOTIFICATION_DID_ENTER_BACKGROUND] object:nil];
}

/**
 *  フォアグランド復帰のイベントハンドラ
 */
-(void)onCustomNotificationDidBecomeActive{
    
    [self createLimitbar];
}


/**
 *  バックグラウンドへ移動した際のイベントハンドラ
 */
-(void)onCustomNotificationDidEnterBackGround{
    
    [self destoryLimitbar];
}


/**
 *  計算機のキーが押された
 *
 *  @param sender
 */
- (IBAction)onTapCalcKey:(UIButton *)sender {
    
    AudioServicesPlaySystemSound(1104);
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    sender.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    
    [UIView animateWithDuration:0.1f delay:0.1f options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         sender.backgroundColor = [UIColor whiteColor];
                     } completion:nil];
    
    
    //4文字以上なら入力不可
    if(self.anserStr.length > 4){
        return;
    }
    
    NSString *tapStr = [NSString stringWithFormat:@"%ld",sender.tag];
    
    self.anserStr = [NSMutableString stringWithFormat:@"%@%@",self.anserStr,tapStr];
    
    NSString *combine = [NSString stringWithFormat:@"%d+%d=",self.questionA,self.questionB];
    
    self.questionLabel.text = [NSString stringWithFormat:@"%@%@",combine,self.anserStr];
    
}

/**
 *  削除キーが押された
 *
 *  @param sender
 */
- (IBAction)deleteBackKey:(UIButton *)sender {
    
    AudioServicesPlaySystemSound(1105);
    
    sender.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    
    [UIView animateWithDuration:0.1f delay:0.1f options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         sender.backgroundColor = [UIColor whiteColor];
                     } completion:nil];
    
    if(self.anserStr.length > 0){
        NSInteger startIndex = self.anserStr.length-1;
        [self.anserStr deleteCharactersInRange:NSMakeRange(startIndex, 1)];
        
        NSString *combine = [NSString stringWithFormat:@"%d+%d=",self.questionA,self.questionB];
        
        self.questionLabel.text = [NSString stringWithFormat:@"%@%@",combine,self.anserStr];
    }
    
}

/**
 *  解答キーが押された
 *
 *  @param sender
 */
- (IBAction)onTapAnserButton:(UIButton *)sender {
    
    int anser = [self.anserStr intValue];
    int question = self.questionA + self.questionB;
    
    //正解なら
    if(anser == question){
        
        [self destoryLimitbar];

        
        //アラーム解除
        AlarmManager *alarmManager = [AlarmManager sharedManager];
        [alarmManager clearLocalNotification ];
        
        //UserDefaultに保存されているアラームフラグをOFF
        [[UserDefalutManager sharedManager] setDefaultAlarm:NO];
        
        [self.sucessSE play];
        
        //IOS8
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            
            // コントローラを生成
            UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"アラーム追跡"
                                                                         message:@"解除完了!!"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            // OK用のアクションを生成
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  // ボタンタップ時の処理
                                                                  //現状のviewcontrollerから離脱
                                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                              }];
            // コントローラにアクションを追加
            [ac addAction:okAction];
            
            // アラート表示処理
            [self presentViewController:ac animated:YES completion:nil];
            
        } else{
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"アラーム追跡" message:@"解除完了!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [av show];
        }
        
    } else {
        
        [self.errorSE play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        self.anserStr = [NSMutableString string];
        
        NSString *combine = [NSString stringWithFormat:@"%d+%d=",self.questionA,self.questionB];
        
        self.questionLabel.text = [NSString stringWithFormat:@"%@%@",combine,self.anserStr];
    }
};


// アラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //１番目のボタンが押されたときの処理を記述する
            //現状のviewcontrollerから離脱
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
    
}



/**
 *  リミットタイマー
 */
-(void)setLimitTimer{
    
    self.limitTimer = [NSTimer scheduledTimerWithTimeInterval:kLimitTime target:self selector:@selector(onCompleteLimitTimer:) userInfo:nil repeats:NO];
}

/**
 *  リミットタイマー完了ハンドラー
 *
 *  @param timer
 */
-(void)onCompleteLimitTimer:(NSTimer *)timer{

    [self destoryLimitbar];
    
    [self setQustion];
    [self createLimitbar];
}

/**
 *  ティッカー（画面更新用）タイマーを設定 0.01sec
 */
-(void)setTickerTimer{
    self.tickerTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(onCompleteTickerTimer:) userInfo:nil repeats:YES];
}

/**
 *  ティッカータイマーの完了ハンドラ
 *
 *  @param timer
 */
-(void)onCompleteTickerTimer:(NSTimer *)timer{
    [self updateLimitBar];
}



#pragma mark - functional view method

/**
 *  問題開始
 */
-(void)setQustion{
    
    self.anserStr = [NSMutableString string];
    
    self.questionA = arc4random()%10;
    self.questionB = arc4random()%20;
    
    self.questionLabel.text = [NSString stringWithFormat:@"%d+%d=?",self.questionA,self.questionB];
}


/**
 *  リミットバーを初期化
 */
-(void)initLimitBar{
    
    self.limitMeterRightMargin.constant = [[UIScreen mainScreen] bounds].size.width;
    self.stackUpdateLimitBarValue = 0;
}


/**
 *  リミットバーを更新
 */
-(void)updateLimitBar{
    
    
    CGFloat maxWidth = [[UIScreen mainScreen] bounds].size.width;
    self.stackUpdateLimitBarValue += self.updateLimitBarValue;
    self.limitMeterRightMargin.constant = maxWidth - self.stackUpdateLimitBarValue;    
}

-(void)createLimitbar{
    [self initLimitBar];
    [self setLimitTimer];
    [self setTickerTimer];
}

-(void)destoryLimitbar{
    [self.tickerTimer invalidate];
    [self.limitTimer invalidate];
}



@end
