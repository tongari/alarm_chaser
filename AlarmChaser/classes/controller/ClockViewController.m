//
//  ClockViewController.m
//  AlarmChaser
//
//  Created by as on 2015/05/12.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "ClockViewController.h"
#import "TimeManager.h"
#import "UserDefalutManager.h"
#import "Router.h"

@interface ClockViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ymdLabel;
@property (weak, nonatomic) IBOutlet UILabel *hmLabel;
@property (weak, nonatomic) IBOutlet UIButton *alarmTimeButton;
@property (weak, nonatomic) IBOutlet UIView *alarmTimeButtonWrapper;

@property (weak, nonatomic) IBOutlet UIImageView *icoChaser;
@property (weak, nonatomic) IBOutlet UIImageView *icoAlarm;


@property (weak, nonatomic) IBOutlet UIImageView *toSettingButtonIco;
- (IBAction)onTapToSettingButton:(UIButton *)sender;

@end

@implementation ClockViewController

#pragma mark - functional controller method
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    [self setNowDate];
    
    self.icoAlarm.image = [self.icoAlarm.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.icoAlarm.tintColor = [UIColor whiteColor];
    
    self.icoChaser.image = [self.icoChaser.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.icoChaser.tintColor = [UIColor whiteColor];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self displayAlarmTimeToLabel];
    
    self.toSettingButtonIco.alpha = 1;
    self.icoChaser.alpha = 1;
    self.icoAlarm.alpha = 1;
    
    [self setStateIcoAlarm];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //アラーム解除画面を表示（条件にあっていれば）
    [[Router sharedManager] displayAwakeAlarmView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -functional view method

/**
 *  現在時刻をセット
 */
- (void)setNowDate{
    
    /**
     *  時間をラベルにセット（blocks）
     */
    void (^setLabel)(void) = ^(void){
        NSDictionary *nowObj = [[TimeManager sharedManager]getNowDate];
        
        self.ymdLabel.text = [NSString stringWithFormat:@"%@ .%@,%@",nowObj[@"monthStr"],nowObj[@"day"],nowObj[@"year"]];
//        self.hmLabel.text = [NSString stringWithFormat:@"%@:%@:%@",nowObj[@"hour"],nowObj[@"minute"],nowObj[@"second"]];
        self.hmLabel.text = [NSString stringWithFormat:@"%@:%@",nowObj[@"hour"],nowObj[@"minute"]];
    };
    
    setLabel();
    
    /**
     *  時間を更新
     */
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                  
        target:[NSBlockOperation blockOperationWithBlock:^{
        
                    setLabel();
                }]
                  
        selector:@selector(main)
        userInfo:nil
         repeats:YES
    ];
}

/**
 *  ラベルにアラームを表示させる
 */
-(void)displayAlarmTimeToLabel{
    
    //ユーザデフォルトからひっぱる。
    UserDefalutManager *userDef = [UserDefalutManager sharedManager];
    
    NSDictionary *alarmTimeObj = [userDef getDefaultAlarmTime];
    NSString *setStr = [NSString stringWithFormat:@"%@:%@",alarmTimeObj[@"hour"],alarmTimeObj[@"minute"]];
    
    [self.alarmTimeButton setTitle:setStr forState:UIControlStateNormal];
    
    if([userDef getDefaultAlarm]){
        
        self.alarmTimeButtonWrapper.backgroundColor = [UIColor colorWithRed:28.0f/255.0f green:28.0f/255.0f blue:28.0f/255.0f alpha:1.0f];
        
    } else {

        self.alarmTimeButtonWrapper.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
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


- (IBAction)onTapToSettingButton:(UIButton *)sender {
    self.toSettingButtonIco.alpha = 0.3;
    self.icoChaser.alpha = 0.3;
    self.icoAlarm.alpha = 0.3;
}
@end
