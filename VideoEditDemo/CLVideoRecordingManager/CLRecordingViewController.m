//
//  CLRecordingViewController.m
//  VideoEditDemo
//
//  Created by 谭春林 on 2019/4/1.
//  Copyright © 2019 谭春林. All rights reserved.
//
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define bottomSafearea ((kHeight>=812.0) ? 34.0 : 0.0)
#import "CLRecordingViewController.h"
#import "CLVideoRecordingManager.h"
@interface CLRecordingViewController ()
@property (nonatomic ,strong) UIButton *chageButton;//切换相机
@property (nonatomic ,strong) UIButton *recoringButton;//录制按钮
@property (nonatomic ,strong) UIButton *closeButton;//退出页面按钮
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,assign) CGFloat progress;
@property (nonatomic ,strong) CAShapeLayer *progressLayer;
@end

@implementation CLRecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[CLVideoRecordingManager shareRecordingManager] authorizationStatus:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configurationUI];
            });
            
        }else{
            self.view.backgroundColor = UIColor.whiteColor;
            UILabel *label = [[UILabel alloc]init];
            label.text = @"请打开相机权限";
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(0, 0, 200, 30);
            label.center = self.view.center;
            [self.view addSubview:label];
        }
    }];
   
}
-(void)configurationUI{
    
    //关闭按钮
    self.closeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.closeButton setTitle:@"关闭" forState:(UIControlStateNormal)];
    self.closeButton.backgroundColor = UIColor.orangeColor;
    self.closeButton.frame = CGRectMake(15, statusBarHeight+20, 70, 30);
    [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.closeButton];
    
    //切换相机按钮
    self.chageButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.chageButton setTitle:@"切换" forState:(UIControlStateNormal)];
    self.chageButton.frame = CGRectMake(kWidth-85, statusBarHeight+20, 70, 30);
    [self.chageButton addTarget:self action:@selector(changeAction) forControlEvents:(UIControlEventTouchUpInside)];
    self.chageButton.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:self.chageButton];
    
    //录制按钮
    self.recoringButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.recoringButton.frame = CGRectMake((kWidth-60)/2, (kHeight-60.0-bottomSafearea-60.0), 60, 60);
//    self.recoringButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:self.recoringButton];
    [self updateLayout:0];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.recoringButton addGestureRecognizer:longPress];
}

-(void)closeAction{
    if (self.presentingViewController) {
        [[CLVideoRecordingManager shareRecordingManager] stopRecording];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)recordingAction{
    
}
-(void)changeAction{
    [[CLVideoRecordingManager shareRecordingManager] changeCamera];
}
-(void)updateLayout:(CGFloat)progress{
//    for (CALayer *layer in self.recoringButton.layer.sublayers) {
//        [layer removeFromSuperlayer];
//    }
    //背景
    CAShapeLayer *shaperLayer = [[CAShapeLayer alloc]init];
    shaperLayer.lineWidth = 5;
    shaperLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    shaperLayer.fillColor = UIColor.orangeColor.CGColor;
    shaperLayer.lineCap = kCALineCapRound;
    shaperLayer.strokeStart = 0;
    CGFloat radius = 30- 2.5;
    
    //进度
    CAShapeLayer *proLayout = [[CAShapeLayer alloc]init];
    proLayout.lineWidth = 5;
    proLayout.strokeColor = UIColor.redColor.CGColor;
    proLayout.fillColor = UIColor.clearColor.CGColor;
    proLayout.lineCap = kCALineCapRound;
    proLayout.strokeStart = 0;
    proLayout.strokeEnd = 0;
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(30, 30) radius:radius startAngle:(-0.5f*M_PI) endAngle:1.5f*M_PI clockwise:YES];
    shaperLayer.path = [path CGPath];
    proLayout.path = [path CGPath];
    self.progressLayer = proLayout;
    [self.recoringButton.layer addSublayer:shaperLayer];
    [self.recoringButton.layer addSublayer:proLayout];
}
-(void)longPress:(UILongPressGestureRecognizer *)press{
    if (press.state == UIGestureRecognizerStateBegan) {
        self.progress = 0;
        _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }else if (press.state == UIGestureRecognizerStateEnded){
        //长按结束需要添加逻辑操作
        [_timer invalidate];
        _timer = nil;
        self.progress = 0;
    }
}
-(void)update{
    if (self.progress >= 15) {
        [_timer invalidate];
        _timer = nil;
        //加逻辑判断
    }
    self.progress += 0.1;
    CGFloat progress = self.progress/15.0;
    _progressLayer.strokeEnd = progress;
    
}
- (void)dealloc{
    NSLog(@"CLRecordingViewController 销毁了");
}

@end
