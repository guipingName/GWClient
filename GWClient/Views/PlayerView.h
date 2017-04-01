//
//  HSTestPlayer.h
//  AVPlayerTest
//
//  Created by wxp on 16/8/19.
//  Copyright © 2016年 hejuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 * 交互委托
 */
@protocol HSTestPlayerDelegate <NSObject>

@optional
/**
 * @brief 全屏按钮被点击的代理方法.
 *
 * @param  sender 被点击的全屏按钮.
 */
- (void)fullScreenBtnClicked:(UIButton *)sender;

- (void)playerBackBtnClicked:(UIButton *)sender;

- (void)playerDidPlayWithCurrentTime:(NSInteger)timePoint;

- (void)playerDidPause;

@end


@interface PlayerView : UIView<UIGestureRecognizerDelegate>

// 播放链接
@property(nonatomic, copy)NSString *playerUrl;

// 播放器
@property(nonatomic, strong)AVPlayer *player;

// 视频名（播放器标题）
@property(nonatomic,copy)NSString *videoTitle;

// 播放器协议
@property(nonatomic,weak)id<HSTestPlayerDelegate>delegate;

/**
 * @brief player的初始化方法.
 *
 * @param  frame 显示在视图上的尺寸位置.
 * @param  playerUrl 播放器视频链接.
 * @return 当前类的实例
 */
- (instancetype)initWithFrame:(CGRect)frame playerUrl:(NSString *)playerUrl;


- (void)play;


- (void)pause;

- (NSArray *)gainCurrentPlayTime;


- (void)playerSeekToTime:(NSInteger)time;

@end
