//
//  RecordVoiceController.m
//  CNewsPro
//
//  Created by hooper on 2/3/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RecordVoiceController.h"
#import <AVFoundation/AVFoundation.h>
#import "ModalAlert.h"
#import "NewArticlesController.h"

static const NSInteger kProgressViewHeight = 9;
static const NSInteger kLabelHeight = 21;
static const NSInteger kXmax = 20;

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]
#define down  self.view.frame.size.height*0.65f
#define FILEPATH [FILE_PATH_IN_PHONE stringByAppendingPathComponent:[self dateString]]

@interface RecordVoiceController () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) UIProgressView *meter1;
@property (nonatomic,strong) UIProgressView *meter2;
@property (nonatomic,strong) AVAudioSession *session;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) AVAudioRecorder *recorder;
@end

@implementation RecordVoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.title = @"RecordVoice";
    
    if ([self startAudioSession])
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"录音", @selector(record));
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"返回", @selector(returnToParent));
        
    }
    else
        self.title = @"No Audio Input Available";
    
    //liying
    UILabel *labelAverage=[[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-kProgressViewHeight*2-kLabelHeight-5-45, 200, 21)];
    labelAverage.text=@"Average";
    labelAverage.font=[UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelAverage.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labelAverage];
    
    //liying
    UILabel *labelPeak=[[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-kProgressViewHeight-kLabelHeight-5, 200, 21)];
    labelPeak.text=@"Peak";
    labelPeak.font=[UIFont fontWithName:@"Helvetica Bold" size:17.0f];
    labelPeak.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labelPeak];
    
    //liying
    self.meter1=[[UIProgressView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-kProgressViewHeight*2-45, 280, kProgressViewHeight)];
    [self.view addSubview:self.meter1];
    
    
    //liying
    self.meter2=[[UIProgressView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-down-kProgressViewHeight, 280, kProgressViewHeight)];
    [self.view addSubview:self.meter2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (BOOL)startAudioSession
{
    // Prepare the audio session
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    
    if (![self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![self.session setActive:YES error:&error])
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    return self.session.inputIsAvailable;
}


- (NSString *)dateString
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (NSString *)formatTime: (int) num
{
    // return a formatted ellapsed time string
    int secs = num % 60;
    int min = num / 60;
    if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
    return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

#pragma mark - Action Method
- (BOOL)record
{
    NSError *error;
    self.timer= [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    // Recording settings
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; // mono
    [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // File URL
    NSURL *url = [NSURL fileURLWithPath:FILEPATH];
    
    // Create recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];//保存声音
    if (!self.recorder)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize degate, metering, etc.
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    self.meter1.progress = 0.0f;
    self.meter2.progress = 0.0f;
    self.title = @"0:00";
    
    if (![self.recorder prepareToRecord])
    {
        NSLog(@"Error: Prepare to record failed");
        [ModalAlert say:@"Error while preparing recording"];
        return NO;
    }
    
    if (![self.recorder record])
    {
        NSLog(@"Error: Record failed");
        [ModalAlert say:@"Error while attempting to record audio"];
        return NO;
    }

    // Update the navigation bar
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"完成", @selector(stopRecording));
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));
    
    return YES;
}


- (void)returnToParent
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)updateMeters
{
    // Show the current power levels
    [self.recorder updateMeters];
    float avg = [self.recorder averagePowerForChannel:0];
    float peak = [self.recorder peakPowerForChannel:0];
    self.meter1.progress = (kXmax + avg) / kXmax;
    self.meter2.progress = (kXmax + peak) / kXmax;
    
    // Update the current recording time
    self.title = [NSString stringWithFormat:@"%@", [self formatTime:self.recorder.currentTime]];
}

- (void)stopRecording
{
    // This causes the didFinishRecording delegate method to fire
    [self.recorder stop];
}

- (void)pauseRecording
{
    // pause an ongoing recording
    [self.recorder pause];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"继续", @selector(continueRecording));
    self.navigationItem.rightBarButtonItem = nil;
}


- (void)continueRecording
{
    // resume from a paused recording
    [self.recorder record];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"完成", @selector(stopRecording));
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    // Stop monitoring levels, time
    [self.timer invalidate];
    self.meter1.progress = 0.0f;
    self.meter1.hidden = YES;
    self.meter2.progress = 0.0f;
    self.meter2.hidden = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    //[ModalAlert say:@"文件已保存 %@", [[self.recorder.url path] lastPathComponent]];
    self.title = @"Playing back recording...";
    [self.delegate addVoice:self.recorder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // Prepare UI for recording
    self.title = nil;
    self.meter1.hidden = NO;
    self.meter2.hidden = NO;
    {
        // Return to play and record session
        NSError *error;
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
        {
            NSLog(@"Error: %@", [error localizedDescription]);
            return;
        }
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"录音", @selector(record));
    }
    
    // Delete the current recording
    [ModalAlert say:@"Deleting recording"];
    //[self.recorder deleteRecording]; <-- too flaky to use
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self.recorder.url path] error:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}



@end
