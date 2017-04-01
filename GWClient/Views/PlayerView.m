//
//  HSTestPlayer.m
//  AVPlayerTest
//
//  Created by wxp on 16/8/19.
//  Copyright © 2016年 hejuan. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>



#define toMinX(relate,pix)       CGRectGetMinX(relate) + pix * KSCREEN_WIDTH / 1334
#define toMaxX(relate,pix)      CGRectGetMaxX(relate) + pix * KSCREEN_WIDTH / 1334
#define toMaxY(relate,pix)      CGRectGetMaxY(relate) + pix * KSCREEN_HEIGHT / 750
#define toMinY(relate)             CGRectGetMinY(relate)
#define toW(relate,pix)             CGRectGetWidth(relate) + pix * KSCREEN_WIDTH / 1334
#define toH(relate,pix)             CGRectGetHeight(relate) + pix * KSCREEN_HEIGHT / 750
#define myW(pix)                     pix * KSCREEN_WIDTH / 1334
#define myY(pix)                      pix * KSCREEN_HEIGHT / 750
#define myH(pix)                     pix * KSCREEN_HEIGHT / 750


#ifndef SET_BUTTON
#define SET_BUTTON
#define create_btn(button,sel,color,norTitle,selectTitle) [UIButton buttonWithType:UIButtonTypeCustom];\
             [ button addTarget:self action:@selector(sel) forControlEvents:UIControlEventTouchUpInside];\
             button.backgroundColor = color;\
             [button setTitle:norTitle forState:UIControlStateNormal];\
             [button setTitle:selectTitle forState:UIControlStateSelected];
#define btn_selectImg(button,imageName) [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
#define btn_norImg(button,imageName) [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
#endif

#define timeInterval 5

@implementation PlayerView{
    UIView *toolView;  // 遮罩层
    CGRect _frame;  // 尺寸
    NSTimer *timer;  // 计时器
    UILabel *currentTimeL;  // 当前播放时间标签
    UILabel *totalTimeL;  // 总时间标签
    UISlider *slider;  // 进度滑动条
    UIButton *playBtn;  // 播放按钮
    UILabel *titleLabel;  // 视频标题
    UIView *topDock;  // 顶部dock栏
    UIView *bottomDock;  // 底部dock栏
    UIButton *fullBtn;  // 全屏按钮
    NSInteger IncrementCount;  // 自增数
    NSInteger tempCount; // 临时数
    AVPlayerLayer *videoPlayer;  // 视频播放层
    UIActivityIndicatorView *juhua;  // 网络活动指示器
    BOOL isFullScreen;  // 当前是否是全屏
    float videoTotalTime;  // 视频总长度
    id playbackObserver;
    UITapGestureRecognizer *myTapGesture;
}

/**-----------初始化------------*/
- (instancetype)initWithFrame:(CGRect)frame playerUrl:(NSString *)playerUrl{
    if (self = [super initWithFrame:frame]) {
        _frame = frame;
        self.playerUrl = playerUrl;
        IncrementCount = 0;
        tempCount = 0;
        slider.value = 0.0;
        [self addGestureToSelf];
        [self createVideoPlayer];
        [self createUI];
        [self addNotificationObserver];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideOrShowTheBar) userInfo:nil repeats:YES];
    
    }
    return self;
}

/**-------------根据网址创建AVPlayerItem和player-------------*/

- (AVPlayer *)createPlayerItem{
     AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.playerUrl] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//#warning 此处导致不能进入dealloc
    self.player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    [self addObserverToPlayerItem];
    return self.player;
}

/**-------------创建视频播放层----------*/
- (void)createVideoPlayer{
    videoPlayer = [AVPlayerLayer playerLayerWithPlayer:[self createPlayerItem]];
    videoPlayer.frame = self.bounds;
    videoPlayer.backgroundColor = [UIColor blackColor].CGColor;
    videoPlayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:videoPlayer];
}


#pragma mark --------------- 视频相关通知 ----------------
-(void)addNotificationObserver{
    // 添加AVPlayerItem播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hsPlayBackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    // 监听屏幕方向变化
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hsOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // 监听程序退到后台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hsAppEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // 监听程序返回前台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hsAppWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

/**------------- 程序进入前台--------------*/
- (void)hsAppWillEnterForeground{
    [self play];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayWithCurrentTime:)]) {
        [self.delegate playerDidPlayWithCurrentTime:slider.value * videoTotalTime];
    }
}

/** -------------程序进入后台-----------*/
- (void)hsAppEnterBackground{
    [self pause];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}


/** ----- 监听屏幕方向发生变化并将视频切换为全屏/半屏 -----*/
- (void)hsOrientationChanged{
    
    NSInteger statusBarOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    switch (statusBarOrientation) {
        case 1:
            self.frame = _frame;
            isFullScreen = NO;
            self.frame = _frame;
            videoPlayer.frame = CGRectMake(0, 0, self.frame.size.width, 200);
            toolView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            topDock.frame = CGRectMake(0, 0, self.frame.size.width, 30);
            bottomDock.frame = CGRectMake(0, 160, self.frame.size.width, 40);
            slider.frame = CGRectMake(toMaxX(currentTimeL.frame, 20), 15, self.frame.size.width - (30 + 55) * 2 - 10, 10);
            totalTimeL.frame = CGRectMake(self.frame.size.width - 30 - 55, 13, 55, 14);
            fullBtn.frame = CGRectMake(self.frame.size.width - 30, 5, 30, 30);
            btn_norImg(fullBtn, @"CDPZoomIn");
            break;
        case 3:
        case 4:
            isFullScreen = YES;
            self.frame = CGRectMake(0, 0, 375, 667);
            videoPlayer.frame = CGRectMake(0, 0, 375, 667);
            toolView.frame = CGRectMake(0, 0, 375, 667);
            topDock.frame = CGRectMake(0, 0, 375, 30);
            bottomDock.frame = CGRectMake(0, 667 - 40, 375, 40);
            slider.frame = CGRectMake(toMaxX(currentTimeL.frame, 20), 15, 375 - (30 + 55) * 2 - 15, 10);
            totalTimeL.frame = CGRectMake(375 - 30 - 55, 13, 55, 14);
            fullBtn.frame = CGRectMake(375 - 30, 5, 30, 30);
            btn_norImg(fullBtn, @"CDPZoomOut");
            break;
            
        default:
            break;
    }
}

- (void)hsPlayBackFinished:(NSNotificationCenter *)notification{
    [self pause];
    [self.player seekToTime:CMTimeMake(1.0, 1.0) completionHandler:^(BOOL finished) {
        
    }];
    
}

#pragma mark --------------- KVO ----------------

- (void)addObserverToPlayerItem{
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    // 监听到可以播放
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        [juhua stopAnimating];
    }else if ([keyPath isEqualToString:@"status"]){
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:{
                videoTotalTime = CMTimeGetSeconds(self.player.currentItem.duration);
                NSString *totalTime = [self timeConvertWithNum:videoTotalTime];
                totalTimeL.text = totalTime;
                [self changeTimeAndSliderValue];
                break;
            }
            default:
                break;
        }
    }
}

/**---------改变时间和滑动条值-----------*/

- (void)changeTimeAndSliderValue{
    __weak typeof(currentTimeL)weakCurrentTime = currentTimeL;
    __weak typeof(slider)weakSlider= slider;
    __weak typeof(self)weakSelf = self;
        playbackObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            float videoCurrentTime = CMTimeGetSeconds(time);
            NSString *currentTime = [weakSelf timeConvertWithNum:videoCurrentTime];
            weakCurrentTime.text = currentTime;
            [weakSlider setValue:videoCurrentTime/videoTotalTime animated:YES];

        }];
}

/**--------------时间格式转换--------------*/

- (NSString *)timeConvertWithNum:(float)num{
    int seconds = (int)num % 60;
    int minutes = ((int)num / 60) % 60;
    int hours = (int)num / 3600;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    return timeStr;
}


/**--------------隐藏或显示bar----------*/

- (void)hideOrShowTheBar{
    IncrementCount ++ ;
    if (IncrementCount - tempCount >= timeInterval) {
        if (toolView.alpha == 1) {
            [self hideTheBar];
        }
    }
    
}

#pragma mark --------------- 添加手势 ----------------

- (void)addGestureToSelf{
    [self addTapGestureOnceToSelf];
    [self addPanGestureToSelf];
}

// 添加点击手势
- (void)addTapGestureOnceToSelf{
    UITapGestureRecognizer *tapR = [[UITapGestureRecognizer alloc]init];
    [tapR addTarget:self action:@selector(tapThePlayerOnce)];
    tapR.delegate = self;
    [self addGestureRecognizer:tapR];
}

- (void)tapThePlayerOnce{

    if (toolView.alpha == 1) {
        [self hideTheBar];
        tempCount = IncrementCount;
    }else{
        [self showTheBar];
        tempCount = IncrementCount;
    }
}


- (void)addPanGestureToSelf{
    UIPanGestureRecognizer *panR = [[UIPanGestureRecognizer alloc]init];
    [panR addTarget:self action:@selector(panThePlayer:)];
    panR.delegate = self;
    [self addGestureRecognizer:panR];
}

- (void)panThePlayer:(UIPanGestureRecognizer *)sender{
    if(sender.numberOfTouches > 1) {
        return;
    }
    
    __block NSInteger timePoint = 0;
    
    CGPoint translationPoint=[sender translationInView:self];
    [sender setTranslation:CGPointZero inView:self];
    CGFloat x = translationPoint.x;
    CGFloat y = translationPoint.y;
    
    if ((y == 0 && fabs(x) >= 5) || fabs(x) / fabs(y) >= 3) {
        if (videoTotalTime == 0.0) {
            return;
        }
        
        slider.value += x / self.frame.size.width;
        [self.player seekToTime:CMTimeMake(slider.value * videoTotalTime, 1) completionHandler:^(BOOL finished) {
            
        }];
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self pause];
        playBtn.selected = NO;
        [playBtn setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateSelected];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPause)]) {
            [self.delegate playerDidPause];
        }
    }
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        timePoint = slider.value * videoTotalTime;
        tempCount = IncrementCount;
        [self play];
      
        
        // 拖动手势结束后传递当前时间点出去
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayWithCurrentTime:)]) {
            [self.delegate playerDidPlayWithCurrentTime:timePoint];
        }
    }
    
    
}

/**-----开始播放-----*/
- (void)play{
    [self.player play];
    playBtn.selected = YES;
    [playBtn setImage:[UIImage imageNamed:@"CDPPause"] forState:UIControlStateSelected];
}


/**-----停止播放-----*/
- (void)pause{
    [self.player pause];
    playBtn.selected = NO;
    [playBtn setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal];
    
}

/**-----隐藏工具条-----*/
- (void)hideTheBar{
    [UIView animateWithDuration:0.3 animations:^{
        toolView.alpha = 0;
    }];
}

/**-----显示工具条-----*/
- (void)showTheBar{
    [UIView animateWithDuration:0.3 animations:^{
        toolView.alpha = 1;
    }];
}

#pragma mark --------------- 创建界面 ----------------
- (void)createUI{

    topDock = [[UIView alloc]init];
    topDock.frame = CGRectMake(0, 0, self.frame.size.width, 30);
    topDock.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    
    UIButton *backBtn = create_btn(backBtn, backBtnClicked, nil, nil,nil)
     btn_norImg(backBtn, @"CDPBack")
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [topDock addSubview:backBtn];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(toMaxX(backBtn.frame, 0), 5, self.frame.size.width - CGRectGetMaxX(backBtn.frame), 20)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"未知";
    [topDock addSubview:titleLabel];
    

    bottomDock = [[UIView alloc]init];
    bottomDock.frame = CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40);
    bottomDock.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    
    playBtn = create_btn(playBtn, playBtnClicked:, nil, nil,nil);
    playBtn.frame = CGRectMake(0, 5, 30, 30);
    [playBtn setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal];
    [bottomDock addSubview:playBtn];
    
    currentTimeL = [[UILabel alloc]init];
    currentTimeL.textColor = [UIColor whiteColor];
    currentTimeL.font = [UIFont systemFontOfSize:12];
    currentTimeL.text = @"00:00:00";
    currentTimeL.frame = CGRectMake(toMaxX(playBtn.frame, 0), 13, 55, 14);
    [bottomDock addSubview:currentTimeL];
    
    slider = [[UISlider alloc]init];
    slider.frame = CGRectMake(toMaxX(currentTimeL.frame, 20), 15, self.frame.size.width - (15 + 55) * 2 - 10, 10);
    [slider setThumbImage:[UIImage imageNamed:@"CDPSlider"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTouchOut:) forControlEvents:UIControlEventTouchUpInside];
    myTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    [slider addGestureRecognizer:myTapGesture];
    [bottomDock addSubview:slider];
    
    totalTimeL = [[UILabel alloc]init];
    totalTimeL.textColor = [UIColor whiteColor];
    totalTimeL.font = [UIFont systemFontOfSize:12];
    totalTimeL.text = @"00:00:00";
    totalTimeL.frame = CGRectMake(self.frame.size.width - 55, 13, 55, 14);
    [bottomDock addSubview:totalTimeL];
    
    
//    fullBtn = create_btn(fullBtn, fullBtnClicked:, nil, nil,nil);
//    btn_norImg(fullBtn, @"CDPZoomIn")
//    fullBtn.frame = CGRectMake(playerWidth - 30, 5, 30, 30);
//    [bottomDock addSubview:fullBtn];
    
    toolView = [[UIView alloc]init];
    toolView.backgroundColor = [UIColor clearColor];
    toolView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [toolView addSubview:topDock];
    [toolView addSubview:bottomDock];
    
    juhua = [[UIActivityIndicatorView alloc]init];
    juhua.frame = CGRectMake(0, 0, 30, 30);
    juhua.center = toolView.center;
    [juhua startAnimating];
    [toolView addSubview:juhua];
    
    [self addSubview:toolView];
}

- (void)setVideoTitle:(NSString *)videoTitle{
    titleLabel.text = videoTitle;
}

#pragma mark --------------- 获取/控制进度 ----------------
/**获取当前播放时间*/
- (NSArray *)gainCurrentPlayTime{
    CMTime time = _player.currentTime;
    float videoCurrentTime = CMTimeGetSeconds(time);
    return @[@((NSUInteger)videoCurrentTime),@((NSInteger)self.player.rate)];
}

/**播放器从指定时间播放*/
- (void)playerSeekToTime:(NSInteger)time{
    [self.player.currentItem seekToTime:CMTimeMake(time, 1)];
    [self play];
}

#pragma mark --------------- 事件响应 ----------------

- (void)backBtnClicked{
   
    if (isFullScreen) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        
    }
    else{
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem cancelPendingSeeks];  //取消挂起的寻求
        [self.player.currentItem.asset cancelLoading];
        [self.player cancelPendingPrerolls];
        [self.player removeTimeObserver:playbackObserver];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        
        self.player = nil;
        [videoPlayer removeFromSuperlayer];
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerBackBtnClicked:)]) {
            [self.delegate playerBackBtnClicked:nil];
        }
        
        [self removeFromSuperview];
    }
    
}

- (void)sliderTouchOut:(UISlider *)aSlider{
    [self play];
    myTapGesture.enabled = YES;
    NSInteger timePoint = aSlider.value *videoTotalTime;

    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayWithCurrentTime:)]) {
        [self.delegate playerDidPlayWithCurrentTime:timePoint];
    }
}


- (void)sliderChanged:(UISlider *)aSlider{
    [self pause];
    myTapGesture.enabled = NO;
    tempCount = IncrementCount;
    
    CGFloat sliderValue = aSlider.value;
    CGFloat totalDuration = CMTimeGetSeconds(self.player.currentItem.duration);
   
     [self.player seekToTime:CMTimeMake(sliderValue *totalDuration, 1) completionHandler:^(BOOL finished) {
         
    }];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:slider];
    CGFloat value = (slider.maximumValue - slider.minimumValue) * (touchPoint.x / slider.frame.size.width );
    [slider setValue:value animated:YES];
    CGFloat totalDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.player seekToTime:CMTimeMake(value *totalDuration, 1) completionHandler:^(BOOL finished) {
        
    }];
    
    [self play];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayWithCurrentTime:)]) {
        [self.delegate playerDidPlayWithCurrentTime:slider.value * videoTotalTime];
    }
}

/**----------点击全屏按钮------------*/
- (void)fullBtnClicked:(UIButton *)sender{
    
//    sender.selected = !sender.selected;
//    
//    if (sender.selected) {
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//    }else{
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
//    }
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(fullScreenBtnClicked:)]) {
//        [self.delegate fullScreenBtnClicked:sender];
//    }
    
}

/**----------点击播放按钮------------*/
- (void)playBtnClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    tempCount = IncrementCount;
    if (sender.selected) {
        [self play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayWithCurrentTime:)]) {
            [self.delegate playerDidPlayWithCurrentTime:slider.value * videoTotalTime];
        }
    }else{
        [self pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPause)]) {
            [self.delegate playerDidPause];
        }
      
    }

}

#pragma mark --------------- 手势识别区域判定 ----------------

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:bottomDock] || [touch.view isDescendantOfView:topDock]) {
        
        return NO;
    }
    
    return YES;
}

- (void)dealloc{
    NSLog(@"player dealloc");
}

@end
