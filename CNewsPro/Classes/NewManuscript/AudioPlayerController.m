//
//  AudioPlayerController.m
//  CNewsPro
//
//  Created by hooper on 2/14/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AudioPlayerController.h"
#import <AVFoundation/AVFoundation.h>

static const NSInteger kProgressViewUpHeight = 9;
static const NSInteger kProgressViewDownHeight = 9;
static const NSInteger kSliderUpHeight = 22;
static const NSInteger kSliderDownHeight = 22;
static const NSInteger kLabelHeight = 21;
static const NSInteger kXmax = 30;

#define down  self.view.frame.size.height*0.3f


@interface AudioPlayerController () <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *avaPlayer;
@property (nonatomic,strong) UIButton *btnPlay;
@property (nonatomic,strong) UIButton *btnPause;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UIProgressView *meter1;
@property (nonatomic,strong) UIProgressView *meter2;
@property (nonatomic,strong) UISlider *scrubber;
@property (nonatomic,strong) UISlider *volumeSlider;
@property (nonatomic,strong) UILabel *nowPlaying;
@end

@implementation AudioPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"express_audio"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"音频播放" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=RGB(60, 90, 154);
    
    //添加暂停按钮
    self.btnPause=[[UIButton alloc] initWithFrame:self.rightButton.frame];
    [self.btnPause setImage:[UIImage imageNamed:@"audio_pause"] forState:UIControlStateNormal];
    [self.btnPause addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnPause];
    
    //添加播放按钮
    self.btnPlay=[[UIButton alloc] initWithFrame:self.rightButton.frame];
    [self.btnPlay setImage:[UIImage imageNamed:@"audio_Start"] forState:UIControlStateNormal];
    [self.btnPlay addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPlay.hidden = YES;
    [self.view addSubview:self.btnPlay];
 
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [self pauseTimer];
    
    [self prepAudio];
   
    
    //liying
    self.meter1=[[UIProgressView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-44-51-45-kProgressViewUpHeight-kProgressViewDownHeight-kSliderUpHeight-kSliderDownHeight, SCREEN_WIDTH-40, kProgressViewUpHeight)];
    [self.view addSubview:self.meter1];
    
    //liying
    self.meter2=[[UIProgressView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-44-51-kProgressViewDownHeight-kSliderUpHeight-kSliderDownHeight, SCREEN_WIDTH-40, kProgressViewUpHeight)];
    [self.view addSubview:self.meter2];
    
    //liying
    self.scrubber=[[UISlider alloc]initWithFrame:CGRectMake(19, self.view.frame.size.height-down-44-kSliderUpHeight-kSliderDownHeight, SCREEN_WIDTH-40, 22)];
    self.scrubber.minimumValue=0;
    self.scrubber.maximumValue=1;
    [self.scrubber addTarget:self action:@selector(setTimeIndex:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.scrubber];
    
    //liying
    self.volumeSlider=[[UISlider alloc]initWithFrame:CGRectMake(19, self.view.frame.size.height-down-kSliderDownHeight, SCREEN_WIDTH-40, 22)];
    self.volumeSlider.minimumValue=0;
    self.volumeSlider.maximumValue=1;
    self.volumeSlider.value = self.volumeSlider.maximumValue;
    [self.volumeSlider addTarget:self action:@selector(setVolume:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.volumeSlider];
    
    //liying
    UILabel *labelAverage=[[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-44-51-45-kProgressViewUpHeight-kProgressViewDownHeight-kSliderUpHeight-kSliderDownHeight-kLabelHeight-5, 200, 21)];
    labelAverage.text = @"Average";
    labelAverage.font = [UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelAverage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:labelAverage];

    //liying
    UILabel *labelPeak=[[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-44-51-5-kProgressViewDownHeight-kSliderUpHeight-kSliderDownHeight-kLabelHeight, 200, 21)];
    labelPeak.text = @"Peak";
    labelPeak.font=[UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelPeak.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labelPeak];  
    
    //liying
    UILabel *labelScrubber = [[UILabel alloc]initWithFrame:CGRectMake(122, self.view.frame.size.height-down-44-5-kSliderUpHeight-kSliderDownHeight-kLabelHeight, 200, 21)];
    labelScrubber.text = @"Scrubber";
    labelScrubber.font = [UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelScrubber.backgroundColor = [UIColor clearColor];
    labelScrubber.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelScrubber]; 
    
    //liying
    UILabel *labelVolume=[[UILabel alloc]initWithFrame:CGRectMake(122, self.view.frame.size.height-down-5-kSliderDownHeight-kLabelHeight, 200, 21)];
    labelVolume.text = @"Volume";
    labelVolume.font = [UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelVolume.backgroundColor=[UIColor clearColor];
    labelVolume.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelVolume];
    
    //liying
    self.nowPlaying=[[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-kLabelHeight-140, 110, 21)];
    self.nowPlaying.text = @"Now Playing";
    self.nowPlaying.font = [UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    self.nowPlaying.backgroundColor = [UIColor clearColor];
    self.nowPlaying.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.nowPlaying];
    self.nowPlaying.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnToParentView:(id)sender
{
    [self.timer invalidate];
    [super returnToParentView:sender];
}

#pragma mark - Private Method
- (void)pauseTimer{
    if (![self.timer isValid]) {
        return ;
    }
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (BOOL)prepAudio
{
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) return NO;
    
    self.avaPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.path] error:&error];
    if (!self.avaPlayer)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    [self.avaPlayer prepareToPlay];
    self.avaPlayer.meteringEnabled = YES;
    self.meter1.progress = 0.0f;
    self.meter2.progress = 0.0f;
    
    self.avaPlayer.delegate = self;
    
    self.scrubber.enabled = NO;
    [self play];
    return YES;
}

- (void)play
{
    self.btnPause.hidden = NO;
    self.btnPlay.hidden = YES;
    [self resumeTimer];
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    if (self.avaPlayer) [self.avaPlayer play];
    self.volumeSlider.value = self.avaPlayer.volume;
    self.volumeSlider.enabled = YES;
   
    self.scrubber.enabled = YES;
}

- (void)resumeTimer{
    if (![self.timer isValid]) {
        return ;
    }
    //[self setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [self.timer setFireDate:[NSDate date]];
}

- (NSString *)formatTime:(int)num
{
    int secs = num % 60;
    int min = num / 60;
    if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
    return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

#pragma mark - Action Method
- (void)play:(id)sender
{
    [self play];
}

- (void)pause:(id) sender
{
    self.btnPause.hidden = YES;
    self.btnPlay.hidden = NO;
    
    if (self.avaPlayer) [self.avaPlayer pause];
    
    self.meter1.progress = 0.0f;
    self.meter2.progress = 0.0f;
    [self pauseTimer];
   
}

- (void)updateMeters
{
    [self.avaPlayer updateMeters];
    float avg = -1.0f * [self.avaPlayer averagePowerForChannel:0];
    float peak = -1.0f * [self.avaPlayer peakPowerForChannel:0];
    self.meter1.progress = (kXmax - avg) / kXmax;
    self.meter2.progress = (kXmax - peak) / kXmax;
    self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:self.avaPlayer.currentTime],
                  [self formatTime:self.avaPlayer.duration]];
    self.scrubber.value = (self.avaPlayer.currentTime / self.avaPlayer.duration);
}

- (void) setVolume: (id) sender
{
    if (self.avaPlayer) self.avaPlayer.volume = self.volumeSlider.value;
}

-(void) setTimeIndex : (id)sender
{
    if (self.avaPlayer) self.avaPlayer.currentTime = self.scrubber.value*self.avaPlayer.duration;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.btnPause.hidden = YES;
    self.btnPlay.hidden = NO;
}



@end
