//
//  CLVideoRecordingManager.m
//  VideoEditDemo
//
//  Created by 谭春林 on 2019/3/28.
//  Copyright © 2019 谭春林. All rights reserved.
//

#import "CLVideoRecordingManager.h"
#import "CLRecordingViewController.h"
@interface CLVideoRecordingManager()<AVCaptureFileOutputRecordingDelegate>

/**
 音频  硬件采集
 */
@property (nonatomic ,strong) AVCaptureDevice *audioCaptureDevice;
/**
 视频 硬件采集
 */
@property (nonatomic ,strong) AVCaptureDevice *videoCaptureDevice;

/**
 视频 输入 后置摄像头
 */
@property (nonatomic ,strong) AVCaptureDeviceInput * videoCaptureDeviceInput;


/**
 前置摄像头
 */
@property (nonatomic ,strong) AVCaptureDeviceInput * prepositionDeviceInput;

/**
 音频  输入
 */
@property (nonatomic ,strong) AVCaptureDeviceInput * audioCaptureDeviceInput;
/**
 音频 视频 输出
 */
@property (nonatomic ,strong) AVCaptureMovieFileOutput *fileOutput;

/**
 音频 视频 会话持有者
 */
@property (nonatomic ,strong) AVCaptureSession *captureSession;

/**
 画面录制页
 */
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;
@end
@implementation CLVideoRecordingManager
+(CLVideoRecordingManager *)shareRecordingManager{
    static CLVideoRecordingManager *recordingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordingManager = [[CLVideoRecordingManager alloc]init];
    });
    return recordingManager;
}
-(id)init{
    self = [super init];
    if (self) {
        [self initDeflautConfig];
    }
    return self;
}
-(void)initDeflautConfig{
    //创建视频采集
    _videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建音频采集
    _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

    
    NSError *videoInputError = nil;
    //创建视频输入
    _videoCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:_videoCaptureDevice error:&videoInputError];
    if (videoInputError) {
        return;
    }
    
    NSError *audioInputError = nil;
    //创建音频输入
    _audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:_audioCaptureDevice error:&audioInputError];
    if (audioInputError) {
        return;
    }
    //音视频输出
    _fileOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    //获取前置摄像头
    AVCaptureDevice *preDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:(AVCaptureDevicePositionFront)];
    //前置摄像头
    NSError *preError = nil;
    _prepositionDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:preDevice error:&preError];
   

    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession beginConfiguration];
    if ([_captureSession canAddInput:_audioCaptureDeviceInput]) {
         [_captureSession addInput:_audioCaptureDeviceInput];
    }
    if ([_captureSession canAddInput:_videoCaptureDeviceInput]) {
         [_captureSession addInput:_videoCaptureDeviceInput];
    }
    if ([_captureSession canAddOutput:_fileOutput]) {
         [_captureSession addOutput:_fileOutput];
    }
   
    [_captureSession commitConfiguration];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
}
-(void)layoutFrame:(CGRect)frame showInView:(nonnull UIView *)view{
    _previewLayer.frame = frame;
    [view.layer addSublayer:_previewLayer];
    [_captureSession startRunning];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentPath = [documentPath stringByAppendingPathComponent:@"video.mp4"];
    NSURL *url = [NSURL fileURLWithPath:documentPath];
    [_fileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}
-(void)showRecordingView:(UIView *)view{
    CLRecordingViewController *recording = [[CLRecordingViewController alloc]init];
    if (view) {
        [recording.view addSubview:view];
        _previewLayer.frame = view.bounds;
        [view.layer addSublayer:_previewLayer];
        [_captureSession startRunning];
        for (UIView * subView in view.subviews) {
            [view bringSubviewToFront:subView];
        }
    }else{
        _previewLayer.frame = recording.view.bounds;
        [recording.view.layer addSublayer:_previewLayer];
        [_captureSession startRunning];
        for (UIView * subView in recording.view.subviews) {
            [recording.view bringSubviewToFront:subView];
        }
    }
    
    UIViewController *controller = [self getCurrentViewController];
    [controller presentViewController:recording animated:YES completion:nil];
    
}
-(UIViewController *)getCurrentViewController{
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self getCurrentVCFromRootVC:controller];
}
-(UIViewController *)getCurrentVCFromRootVC:(UIViewController *)rootVC{
    UIViewController *currentVC = nil;
    if ([rootVC presentedViewController]) {
        currentVC = rootVC;
    }
    if ([rootVC isKindOfClass: [UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)rootVC;
        currentVC = [self getCurrentVCFromRootVC:tab.selectedViewController];
    }else if ([rootVC isKindOfClass: [UINavigationController class]]){
        UINavigationController *nav = (UINavigationController *)rootVC;
        currentVC = [self getCurrentVCFromRootVC:nav.visibleViewController];
    }else{
        currentVC = rootVC;
    }
    return currentVC;
}

/**
 开始录制
 */
- (void)startRecording{
    [_captureSession startRunning];
}

/**
 结束录制
 */
- (void)stopRecording{
    [_captureSession stopRunning];
    [_fileOutput stopRecording];
}

/**
 切换相机
 */
- (void)changeCamera{
    __weak __typeof(self)wself = self;
    [_captureSession.inputs enumerateObjectsUsingBlock:^(__kindof AVCaptureInput * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AVCaptureDeviceInput class]] ) {
            AVCaptureDeviceInput *input = (AVCaptureDeviceInput *)obj;
            if (input == wself.videoCaptureDeviceInput) {
                [wself.captureSession removeInput:input];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.captureSession addInput:wself.prepositionDeviceInput];
                });
                
            }else if (input == wself.prepositionDeviceInput){
                [wself.captureSession removeInput:input];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.captureSession addInput:wself.videoCaptureDeviceInput];
                });
                
            }
        }
    }];
}
/**
 获取相机授权

 @param authorizationBlock 授权回调
 */
-(void)authorizationStatus:(void(^)(BOOL success))authorizationBlock{
    
   AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized://授权成功
            authorizationBlock(YES);
            break;
        case AVAuthorizationStatusNotDetermined:{//用户暂时没有相关选择
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                authorizationBlock(granted);
            }];
            break;
        }
        default:
            authorizationBlock(NO);
            break;
    }
}
#pragma mark -- RecordingDelegate --  录制视频回调
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cl_captureOutput:didStartRecordingToOutputFileAtURL:fromConnections:)]) {
        [self.delegate cl_captureOutput:output didStartRecordingToOutputFileAtURL:fileURL fromConnections:connections];
        return;
    }
}
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cl_captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:)]) {
        [self.delegate cl_captureOutput:output didFinishRecordingToOutputFileAtURL:outputFileURL fromConnections:connections error:error];
        return;
    }
    //**获取视频时长**//
    AVURLAsset *avUrl = [AVURLAsset URLAssetWithURL:outputFileURL options:nil];
    CMTime time = [avUrl duration];
    NSInteger seconds = ceil(time.value/time.timescale);
    NSLog(@"录制了%ld秒",seconds);
}
@end
