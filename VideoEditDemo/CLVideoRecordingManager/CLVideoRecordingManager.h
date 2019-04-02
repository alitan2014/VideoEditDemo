//
//  CLVideoRecordingManager.h
//  VideoEditDemo
//
//  Created by 谭春林 on 2019/3/28.
//  Copyright © 2019 谭春林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol CLVideoRecordingManagerDelegate <NSObject>
@optional
/**
 开始录制视频代理方法

 @param output 文件输出对象
 @param fileURL 文件输出路径
 @param connections 持有视频连接
 */
- (void)cl_captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections;

/**
 结束录制视频代理方法

 @param output 文件输出对象
 @param outputFileURL 文件输出路径
 @param connections 持有连接
 @param error 错误信息
 */
- (void)cl_captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error;
@end
@interface CLVideoRecordingManager : NSObject
@property (nonatomic ,weak) id<CLVideoRecordingManagerDelegate>delegate;
+(CLVideoRecordingManager *)shareRecordingManager;
-(void)showRecordingView:(UIView *)view;
/**
 开始录制
 */
-(void)startRecording;

/**
 结束录制
 */
-(void)stopRecording;

/**
 切换相机
 */
-(void)changeCamera;

/**
 获取相机权限

 @param authorizationBlock success YES 表示获取相机权限成功 NO表示获取相机权限失败
 */
-(void)authorizationStatus:(void(^)(BOOL success))authorizationBlock;
@end

NS_ASSUME_NONNULL_END
