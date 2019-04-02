//
//  ViewController.m
//  VideoEditDemo
//
//  Created by 谭春林 on 2019/3/28.
//  Copyright © 2019 谭春林. All rights reserved.
//

#import "ViewController.h"
#import "CLVideoRecordingManager.h"
@interface ViewController ()
@property (nonatomic ,strong) UIButton *makeVideo;
@property (nonatomic ,strong) UIButton *stopRecording;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *makeVideo = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [makeVideo setTitle:@"拍摄视频" forState:(UIControlStateNormal)];
    makeVideo.frame = CGRectMake(0, 0, 100, 35);
    makeVideo.center = self.view.center;
    [makeVideo addTarget:self action:@selector(takeVideo) forControlEvents:(UIControlEventTouchUpInside)];
    makeVideo.backgroundColor = UIColor.orangeColor;
    _makeVideo = makeVideo;
    [self.view addSubview:makeVideo];
    
    _stopRecording = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [_stopRecording setTitle:@"完成" forState:(UIControlStateNormal)];
    _stopRecording.frame = CGRectMake(100, 100, 100, 30);
    [_stopRecording addTarget:self action:@selector(stopRecord) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_stopRecording];
}

-(void)takeVideo{
    CLVideoRecordingManager *manager = [CLVideoRecordingManager shareRecordingManager];
    [manager showRecordingView:nil];
}
-(void)stopRecord{
    [[CLVideoRecordingManager shareRecordingManager] stopRecording];
}
@end
