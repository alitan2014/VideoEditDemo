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

@interface CLVideoRecordingManager : NSObject
+(CLVideoRecordingManager *)shareRecordingManager;
-(void)layoutFrame:(CGRect)frame showInView:(UIView *)view;
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

 @param authorizationBlock 回调
 */
-(void)authorizationStatus:(void(^)(BOOL success))authorizationBlock;
@end

NS_ASSUME_NONNULL_END
