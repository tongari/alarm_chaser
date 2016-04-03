//
//  ShakeViewController.m
//  AlarmChaser
//
//  Created by as on 2015/05/15.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "ShakeViewController.h"
#import "UserDefalutManager.h"
#import "AppDelegate.h"
#import "AlarmManager.h"
#import <iAd/iAd.h>


@interface ShakeViewController ()<UIAlertViewDelegate>

@property(strong,nonatomic)CMMotionManager *motionManager;
@property(assign,nonatomic)int shakeCount;
@property(assign,nonatomic)double shakeCountStackValue;

@property(assign,nonatomic)float updateLimitBarValue;
@property(assign,nonatomic)float stackUpdateLimitBarValue;
@property(assign,nonatomic)BOOL isAnimShake;

@property(strong,nonatomic)AVAudioPlayer *sucessSE;

@property (weak, nonatomic) IBOutlet UIView *limitBar;
@property (weak, nonatomic) IBOutlet UIImageView *icoShake;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icoShakePosY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *limitMeterRightMargin;

@end

const float kShakeCountMax = 100.0f;

@implementation ShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *pathSucessSE = [[NSBundle mainBundle] pathForResource:@"answer_02" ofType:@"caf"];
    NSURL *urlSucessSE = [NSURL fileURLWithPath:pathSucessSE];
    self.sucessSE = [[AVAudioPlayer alloc] initWithContentsOfURL:urlSucessSE error:nil];
    [self.sucessSE prepareToPlay];
    
    self.shakeCountStackValue = 3.5f;
    self.shakeCount = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    [self setCustomEventNotification];
    [[UserDefalutManager sharedManager] setDisplayedAwakeAlarmView:YES];
    
    self.canDisplayBannerAds = YES;
}


-(void)viewDidAppear:(BOOL)animated{
    
    //更新時に増加するリミットバーの値を算出
    self.updateLimitBarValue = [[UIScreen mainScreen]bounds].size.width * (1/kShakeCountMax);
    [self initLimitBar];
    
    [self setupAccelerometer];
    
    self.isAnimShake = YES;
    [self doAnimaIcoShake];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.motionManager stopAccelerometerUpdates];
    [self removeCustomEventNotification];
    [[UserDefalutManager sharedManager] setDisplayedAwakeAlarmView:NO];
    
    self.isAnimShake = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self setupAccelerometer];
}


/**
 *  バックグラウンドへ移動した際のイベントハンドラ
 */
-(void)onCustomNotificationDidEnterBackGround{
    
    [self.motionManager stopAccelerometerUpdates];
}

/**
 *  加速度センサーを設定
 */
- (void)setupAccelerometer{
    if (self.motionManager.accelerometerAvailable){
        // センサーの更新間隔の指定、10Hz
        self.motionManager.accelerometerUpdateInterval = 1/10;
        
        // ハンドラを設定
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error){
            
            // 加速度センサー
            double xac = data.acceleration.x;
            double yac = data.acceleration.y;
            double zac = data.acceleration.z;
            
            //ある程度の強度を超えたらカウントを加算
            if(xac >self.shakeCountStackValue || yac > self.shakeCountStackValue || zac > self.shakeCountStackValue){
                self.shakeCount++;
                [self updateLimitBar];
            }
            
            if(self.shakeCount >= 100){
                
                //加速度センサー停止
                [self.motionManager stopAccelerometerUpdates];
                self.isAnimShake = NO;
                
                
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
                    
                    if(!av.isHidden)[av show];
                }
            }
            
        };
        
        // 加速度の取得開始
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

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
 *  リミットバーを初期化
 */
-(void)initLimitBar{
    
    
    self.stackUpdateLimitBarValue = 0;
    self.limitMeterRightMargin.constant = [[UIScreen mainScreen] bounds].size.width;    
}


/**
 *  リミットバーを更新
 */
-(void)updateLimitBar{
    
    CGFloat maxWidth = [[UIScreen mainScreen] bounds].size.width;
    self.stackUpdateLimitBarValue = self.updateLimitBarValue*self.shakeCount;
    self.limitMeterRightMargin.constant = maxWidth - self.stackUpdateLimitBarValue;
}


/**
 *  アイコンをアニメーション
 */
-(void)doAnimaIcoShake{
    
    
    [self.icoShake setNeedsUpdateConstraints];
    self.icoShakePosY.constant = 50;
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.icoShake layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [self.icoShake setNeedsUpdateConstraints];
        self.icoShakePosY.constant = -50;
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self.icoShake layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            if(self.isAnimShake)[self doAnimaIcoShake];
        }];
        
        
    }];
    
}


@end
