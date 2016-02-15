//
//  NewVideoController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewVideoController.h"
#import "PBJVision.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Manuscripts.h"
#import "ManuscriptsDB.h"
#import "Accessories.h"
#import "AccessoriesDB.h"
#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"
#import "VideoGrid.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "NewTagDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AttachDetailController.h"

@interface NewVideoController () <CLLocationManagerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PBJVisionDelegate,UITextFieldDelegate>
@property (nonatomic,copy)  NSString *currentVideoPath;
@property (nonatomic,assign) BOOL btnTag;
@property (nonatomic,strong) UITextView *titleField;
@property (nonatomic,strong) UIScrollView *videoListScrollView;
@property (nonatomic,strong) UILabel *static_title;
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic,strong) UIView *previewVideo;
@property (nonatomic,strong) UIButton *startBtn;
@property (nonatomic,strong) UILabel *videoTimeLb;
@property (nonatomic,strong) Manuscripts *mcripts;
@property (nonatomic,strong) ManuscriptsDB *manuscriptsdb;
@property (nonatomic,strong) AccessoriesDB *accessoriesdb;
@property (nonatomic,copy) NSMutableArray *videoInfoArray;
@property (nonatomic,copy) NSMutableArray *gridArray;
@property (nonatomic,strong) VideoGrid *videoGrid;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSTimer *videoTimer;
@property (nonatomic,assign) NSInteger videoSecond;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,assign) BOOL isCamera;
@property (nonatomic,strong) PBJVision *pbvision;
@property (nonatomic,assign) NSInteger selectAccessoryIndex;
@property (nonatomic,strong) UIButton *selectAccessorySender;
@end

@implementation NewVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentVideoPath = @"";
    self.btnTag = FALSE;
    self.static_title = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+5.0, 52, 21)];
    self.static_title.font = [UIFont systemFontOfSize:16];
    self.static_title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.static_title];
    
    self.titleField = [[UITextView alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView-55, 30)];
    self.titleField.font = [UIFont systemFontOfSize:14];
    self.titleField.textAlignment = NSTextAlignmentLeft;
    self.titleField.returnKeyType = UIReturnKeyDone;
    // titleField.delegate = self;
    [self.view addSubview:self.titleField];
    
    self.videoListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 85, 300, self.view.frame.size.height-170)];
    self.videoListScrollView.userInteractionEnabled = YES;
    self.videoListScrollView.multipleTouchEnabled = YES;
    [self.view addSubview:self.videoListScrollView];
    
    UIButton *showDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25, self.view.frame.size.height/2-55, 25, 60)];
    [showDetailBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [showDetailBtn setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    showDetailBtn.userInteractionEnabled = YES;
    [showDetailBtn addTarget:self action:@selector(showTemplateView:) forControlEvents:UIControlEventTouchUpInside];
    [showDetailBtn setContentMode:UIViewContentModeCenter];
    [showDetailBtn setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:showDetailBtn];
    
    UIButton *addAttachBtn = [[UIButton alloc] initWithFrame:CGRectMake(58, self.view.frame.size.height-70+10, 35, 35)];
    [addAttachBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [addAttachBtn setImage:[UIImage imageNamed:@"express_location.png"] forState:UIControlStateNormal];
    addAttachBtn.userInteractionEnabled = YES;
    [addAttachBtn addTarget:self action:@selector(attachLocationInfo:) forControlEvents:UIControlEventTouchUpInside];
    [addAttachBtn setContentMode:UIViewContentModeCenter];
    [addAttachBtn setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:addAttachBtn];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(229, self.view.frame.size.height-70+10, 35, 35)];
    [saveBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@"express_save"] forState:UIControlStateNormal];
    saveBtn.userInteractionEnabled = YES;
    [saveBtn addTarget:self action:@selector(saveExpress:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setContentMode:UIViewContentModeCenter];
    [saveBtn setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:saveBtn];
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(10,  CGRectGetMaxY(self.static_title.frame)+5.0, self.widthOfMainView-20.0, 1)];
    //title_static.textColor=[UIColor blackColor];
    topLine.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:topLine];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-80+10, 300, 1)];
    //bottomLine.textColor=[UIColor blueColor];
    bottomLine.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:bottomLine];
    
    [self initializeController];

    //自定义摄像头
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    self.previewVideo = [[UIView alloc] initWithFrame:CGRectZero];
    self.previewVideo.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectZero;
    previewFrame.origin = CGPointMake(0,0);
    CGFloat previewWidth = self.view.frame.size.width;
    previewFrame.size = CGSizeMake(previewWidth, self.view.frame.size.height);
    self.previewVideo.frame = previewFrame;
    
    // add AV layer
    AVCaptureVideoPreviewLayer *previewLayer = [[PBJVision sharedInstance] previewLayer];
    CGRect previewBounds = self.previewVideo.layer.bounds;
    previewLayer.bounds = previewBounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.position = CGPointMake(CGRectGetMidX(previewBounds), CGRectGetMidY(previewBounds));
    [self.previewVideo.layer addSublayer:previewLayer];
    
    UIView *RecordView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 80)];
    [RecordView setBackgroundColor:[UIColor blackColor]];
    [RecordView setAlpha:0.5f];
    
    UIView *RecordView2=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    [RecordView2 setBackgroundColor:[UIColor blackColor]];
    [RecordView2 setAlpha:0.5f];
    
    //add AV btn
    self.startBtn=[[UIButton alloc] initWithFrame:CGRectMake(120, self.view.frame.size.height-80, 80, 80)];
    [self.startBtn setImage:[UIImage imageNamed:@"RecordStart"] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startCapture:) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoTimeLb = [[UILabel alloc] initWithFrame:CGRectMake(124, 4, 80, 25)];
    self.videoTimeLb.backgroundColor = [UIColor clearColor];
    self.videoTimeLb.textColor = [UIColor whiteColor];
    self.videoTimeLb.font = [UIFont boldSystemFontOfSize:18];
    
    // RecordView.userInteractionEnabled=YES
    [previewLayer addSublayer:RecordView.layer];
    [previewLayer addSublayer:RecordView2.layer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
}

- (void)initializeController {
    //调用数据库函数
    self.manuscriptsdb = [[ManuscriptsDB alloc] init];
    self.accessoriesdb = [[AccessoriesDB alloc] init];
    
    //初始化数据实体对象.此处为对象属性，在本类中各个方法中都能访问。
    self.mcripts = [[Manuscripts alloc] init];
    self.videoInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //获得默认稿签模板
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    self.mcripts.mTemplate = [mdb getDefaultManuscriptTemplate:VIDEO_EXPRESS_TEMPLATE_TYPE loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    self.titleField.text = self.mcripts.mTemplate.defaultTitle;
    
    //页面第一次进入时，将传入的稿件id保存在缓存中。如果是“新建稿件”，则为@“”。
    [USERDEFAULTS setObject:self.manuscript_id forKey:CURRENT_MANUSCRIPTID_SESSIONId];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"express_video"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"视频快讯" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    
    //添加发送按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"express_send.png"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(sendExpress:) forControlEvents:UIControlEventTouchUpInside];
    
    //zyq 国际化
    self.static_title.text = @"标题";

    //表格视图
    self.gridArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *image =[UIImage imageNamed:@"express_videoBtnGray"];
    self.videoGrid = [[VideoGrid alloc] initWithFrame:CGRectMake(30, 20, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.videoGrid.btnDelete.hidden = YES;
    [self.videoGrid.btnPic setImage:image forState:UIControlStateNormal];
    [self.videoGrid.btnPic addTarget:self action:@selector(actionSheetAddVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.videoListScrollView addSubview:self.videoGrid];
    [self.gridArray addObject:self.videoGrid];
    //[videoGrid release];
    
    //定时器初始化
    int autoSaveTime = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:AUTO_SAVE_TIME])
    {
        autoSaveTime = [[[NSUserDefaults standardUserDefaults] objectForKey:AUTO_SAVE_TIME] intValue];
    }
    if(autoSaveTime > 0 )
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:autoSaveTime
                                                      target:self
                                                    selector:@selector(autoSaveManuscript)
                                                    userInfo:nil
                                                     repeats:YES];
    }

}

-(void)returnToParentView:(id)sender
{
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])//新稿件
    {
        if (([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.titleField.text] isEqualToString:self.mcripts.mTemplate.defaultTitle])&&(self.videoInfoArray.count == 0))
        {
            //直接返回上级视图
        }
        else {
            if( [[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""] )
            {
                [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"请输入稿件标题"];
                return;
            }
            else {
                //保存新稿件
                //第一次保存  生成稿件编号
                currentManuscriptId  = [Utility stringWithUUID];
                [self insertNewManuscript:currentManuscriptId];
            }
        }
    }
    else {
        if( [[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""] )
        {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"请输入稿件标题"];
            return;
        }
        else {
            //更新已有稿件
            [self updateManuscript:currentManuscriptId];
        }
    }
    
    [self.timer invalidate];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]  animated:YES];
}


//回传稿签数据
-(void)returnManuscriptTemplate:(ManuscriptTemplate *)manuscripttemplate
{
    self.mcripts.mTemplate = manuscripttemplate;
    
    //稿签信息修改后，将信息保存至数据库。
    //如果稿件已经被保存过，则将稿签信息更新至数据库
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if(![currentManuscriptId isEqualToString:@""])
    {
        [self saveManuscript];
    }
}

-(void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private Method
//第一次保存，即插入一条新的稿件
- (NSString*)insertNewManuscript:(NSString*)manuscriptId
{
    self.mcripts.m_id = manuscriptId;//必填。
    if([self.mcripts.mTemplate.loginName isEqualToString:@""])
    {
        self.mcripts.mTemplate.loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    }
    if( [self.mcripts.mTemplate.loginName isEqualToString:@""] )
    {
        return @"当前登录名为空，未保存";
    }
    self.mcripts.title=[Utility trimBlankSpace:self.titleField.text];
    
    self.mcripts.manuscriptsStatus = MANUSCRIPT_STATUS_EDITING;   //稿件状态。必填。
    //zyq,12/10,添加地理位置信息
    self.mcripts.location = @"0.0,0.0"; //定位信息
    
    self.mcripts.createTime = [Utility getLogTimeStamp];
    
    if ([self.manuscriptsdb addManuScript:self.mcripts]>0) {
        return @"保存稿件成功";
    }
    else {
        return @"保存稿件失败";
    }
    
}

//更新已存在的稿件
- (NSString*)updateManuscript:(NSString*)manuscriptId
{
    self.mcripts.title = [Utility trimBlankSpace:self.titleField.text];
    if ([self.manuscriptsdb updateManuscript:self.mcripts]) {
        return @"保存稿件成功";
    }
    else {
        return @"保存稿件失败";
    }
}


//保存稿件。不负责保存稿件的附件信息。附件信息在添加和删除附件时完成。
-(NSString *)saveManuscript
{
    NSString *logInfo = @"";
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])
    {
        //第一次保存  生成稿件编号并存入缓存
        currentManuscriptId  = [Utility stringWithUUID];
        [[NSUserDefaults standardUserDefaults] setObject:currentManuscriptId forKey:CURRENT_MANUSCRIPTID_SESSIONId];
        
        logInfo = [self insertNewManuscript:currentManuscriptId];
    }
    else {
        logInfo = [self updateManuscript:currentManuscriptId];
    }
    return logInfo;
}

-(void)sendManuScript
{
    if ([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]) {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"标题不能为空"];
        return;
    }
    
    //异步加载等待对话框，完成发送前的准备工作后予以关闭
    [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    
    //保存到在编稿件
    [self saveManuscript];
    
    //检测网络是否可用、服务器地址是否可用、版本是否符合发稿要求，以及稿件的稿签是否符合要求
    NSString *serialCheck = [Utility serialCheckBeforeSendManu:self.mcripts];
    if( ![serialCheck isEqualToString:@""] )
    {
        [self hideWaiting];
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:serialCheck];
        return;
    }
    
    //将稿件信息保存并根据附件个数进行拆条
    NSMutableArray *manuArray = [Utility prepareToSendManuscript:self.mcripts accessories:self.videoInfoArray userInfoFromServer:[Utility sharedSingleton].userInfo];
    
    for(int i = 0;i<[manuArray count];i++)
    {
        [Utility xmlPackage:[manuArray objectAtIndex:i] accessories:[self.videoInfoArray objectAtIndex:i]];
    }
    
    if( [manuArray count]>0 ){
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"请到待发稿件中查看发送进程"];
    }

    //返回上级页面
    [self.timer invalidate];
    [self hideWaiting];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (NSString *)changeSecondToStr:(NSInteger)second
{
    NSString *resultStr = nil;
    if (second<60) {
        resultStr = [NSString stringWithFormat:@"00:00:%02ld",second];
    }
    else if(second<3600)
    {
        resultStr = [NSString stringWithFormat:@"00:%02ld:%02ld",second/60,second%60];
    }
    else
    {
        resultStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",second/3600,(second%3600)/60,(second%3600)%60];
    }
    return resultStr;
}

//设置相机配置
- (void)resetCapture
{
    NSInteger codeBit = [[USERDEFAULTS objectForKey:CODE_BIT] intValue];
    NSString *resolution=[USERDEFAULTS objectForKey:RESOLUTION];
//    [[PBJVision sharedInstance] startPreviewWithMALV:codeBit];
    self.pbvision = [PBJVision sharedInstance];
    self.pbvision.delegate = self;
    if ([resolution isEqualToString:@"352*288"]) {
//        self.pbvision.fenbianlv =AVCaptureSessionPreset352x288;
    }
    if ([resolution isEqualToString:@"640*480"]) {
//        self.pbvision.fenbianlv =AVCaptureSessionPreset640x480;
    }
    if ([resolution isEqualToString:@"1280*720"]) {
//        self.pbvision.fenbianlv =AVCaptureSessionPreset1280x720;
    }
//    self.pbvision.pinzhen = 30;
    [self.pbvision setCameraMode:PBJCameraModeVideo];    //设置📷模式
    [self.pbvision setCameraDevice:PBJCameraDeviceBack];   //设置📷设备
    [self.pbvision setCameraOrientation:PBJCameraOrientationPortrait]; //设置📷其方向
    [self.pbvision setFocusMode:PBJFocusModeAutoFocus];
    
}

-(void)addAttach:(NSString *)url type:(NSInteger)type originName:(NSString *)originName{
    
    Accessories *newVideoInfo = [[Accessories alloc] init];
    
    //保存到数据库
    switch (type) {
        case FileNameTagsPhoto:
        {
            newVideoInfo.type = @"PHOTO";
            break;
        }
        case FileNameTagsAudio:
        {
            newVideoInfo.type = @"AUDIO";
            break;
        }
        case FileNameTagsVideo:
        {
            newVideoInfo.type = @"VIDEO";
            break;
        }
            
        default:
            break;
    }
    
    newVideoInfo.createTime = [Utility getNowDateTime];
    newVideoInfo.info = @"视频";
    
    NSInteger fileLength = [Utility getFileLengthByPath:url];
    newVideoInfo.size=[NSString stringWithFormat:@"%ld",fileLength];
    newVideoInfo.originName = originName;
    
    //依据缓存中的稿件稿件Id值，判断稿件是否已经保存。
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])
    {
        //说明该附件对应的稿件未保存，需要先保存稿件，然后根据稿件的m_id来添加附件
        [self saveManuscript];
        currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    }
 
    newVideoInfo.m_id = currentManuscriptId;
    //插入一条附件记录
    newVideoInfo.a_id = [Utility stringWithUUID];
    if(![self.accessoriesdb addAccessories:newVideoInfo])
        NSLog(@"附件插入失败%@",newVideoInfo.a_id);
    
    
    [self.videoInfoArray insertObject:newVideoInfo atIndex:[self.videoInfoArray count]];
}

- (void)addGridView:(NSString *)videoUrl
{
    UIImage *image = [self getVideoImageByPath:[NSURL fileURLWithPath:videoUrl]];
    
    
    //添加新Grid，替换add按钮的位置
    VideoGrid *newGrid = [[VideoGrid alloc] initWithFrame:self.videoGrid.frame];
    newGrid.alpha = 0.0f;
    //设置截图
    newGrid.btnPic.tag = [self.gridArray count] - 1;
    [newGrid.btnPic setImage:image forState:UIControlStateNormal];
    [newGrid.btnPic addTarget:self action:@selector(showDetailAttachment:) forControlEvents:UIControlEventTouchUpInside];
    //添加事件，记录tag值（index）
    newGrid.btnDelete.tag = [self.gridArray count] - 1;
    [newGrid.btnDelete addTarget:self action:@selector(deleteGrid:) forControlEvents:UIControlEventTouchUpInside];
    //插入队列
    [self.gridArray insertObject:newGrid atIndex:[self.gridArray count]-1];
    [self.videoListScrollView addSubview:newGrid];
 
    //add按钮移动
    NSUInteger add_grid_index = [self.gridArray count] - 1;
    //计算add按钮的新位置
    NSUInteger row = add_grid_index / 2;
    NSUInteger column = add_grid_index % 2;
    CGRect newAddGridFrame = CGRectMake(30+column*BUTTON_WIDTH+column*40,
                                        20+row*BUTTON_HEIGHT+row*20,
                                        BUTTON_WIDTH,
                                        BUTTON_HEIGHT);
    
    //根据内容大小设置contentsize
    self.videoListScrollView.contentSize = CGSizeMake(300, (BUTTON_HEIGHT+20)*(row+2)+20);
    
    //处理动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    newGrid.alpha = 1.0f;
    self.videoGrid.frame = newAddGridFrame;
    [UIView commitAnimations];
    
    //将add按钮滚动到可见位置
    [self.videoListScrollView scrollRectToVisible:newAddGridFrame animated:NO];
}

//获取指定本地路径的视频的截图
- (UIImage*)getVideoImageByPath:(NSURL*)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];  // 初始化视频媒体文件
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(200, 200);
    NSError *error = nil;
    
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(1, 60) actualTime:NULL error:&error];
    if (error == nil)
    {
        UIImage *image = [[UIImage alloc] initWithCGImage:img];
        CGImageRelease(img);
        return image;
    }
    else{
        CGImageRelease(img);
        return nil;
    }
    
}

#pragma mark - Action Method
//稿签
-(void)showTemplateView:(id)sender
{
    NewTagDetailViewController *tagController = [[NewTagDetailViewController alloc] init];
    tagController.manuscriptTemplate = self.mcripts.mTemplate;
    tagController.templateType = TemplateTypeEditAble;
    tagController.delegate = self;
    [self.navigationController pushViewController:tagController animated:YES];
}

-(void)attachLocationInfo:(id)sender
{
    //检测网络状况，如果未连接网络，不发送。
    if (![Utility testConnection] ) {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"当前网络不可用，请稍后再试!"];
    }
    else {
        if (!self.locationManager) {
            //定位初始化
            self.locationManager=[[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [self.locationManager requestAlwaysAuthorization];
            }
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter  = 5.0f; // in meters
        }
        [self.locationManager startUpdatingLocation];
    }
}

-(void)saveExpress:(id)sender
{
    NSString *retInfo = @"";
    if ([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
    {
        retInfo = @"请输入快讯标题";
    }
    else {
        retInfo = [self saveManuscript];
    }
    
    [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:retInfo];
}

-(void)sendExpress:(id)sender
{
    //如果键盘处于打开状态，则关闭
    [self.titleField resignFirstResponder];//隐藏键盘
    
    if ([self.videoInfoArray count]>0) {
        [self sendManuScript];
        
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"无视频，系统拒绝发送"];
    }
}

- (void)actionSheetAddVideo:(id)sender
{
    UIActionSheet *actSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍摄",@"用户相册",nil];
    [actSheet showInView:self.view];
}

//自动保存稿件
-(void)autoSaveManuscript
{
    if( (![self.mcripts.title isEqualToString:[Utility trimBlankSpace:self.titleField.text]]))
    {
        if(![[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
            [self saveManuscript];
    }
}

//视频捕获按钮事件
-(void)startCapture:(id)sender
{
    if (!self.btnTag) {
        self.videoTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFunction:) userInfo:nil repeats:YES];
        AudioServicesPlaySystemSound(1117);
        [self.startBtn setImage:[UIImage imageNamed:@"RecordPause"] forState:UIControlStateNormal];
        self.btnTag=TRUE;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        formatter.dateFormat = @"ddMMYY_hhmmsss";
        NSString *originName = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],MOV_TYPE];//文件名称
        self.currentVideoPath=originName;
//        [[PBJVision sharedInstance] startVideoCapture:originName];
        
    }else
    {
        [self.videoTimer invalidate];
        self.videoSecond=0;
        self.videoTimeLb.text=@"00:00:00";
        AudioServicesPlaySystemSound(1117);
        [self.startBtn setImage:[UIImage imageNamed:@"RecordStart"] forState:UIControlStateNormal];
        self.btnTag = FALSE;
        [[PBJVision sharedInstance] endVideoCapture];
        [self.previewVideo removeFromSuperview];
        [self.startBtn removeFromSuperview];
        [self.videoTimeLb removeFromSuperview];
        [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    }
}

-(void)timerFunction:(id)sender
{
    self.videoSecond++;
    self.videoTimeLb.text = [self changeSecondToStr:self.videoSecond];
}

//稿件详情页
-(void)showDetailAttachment:(id)sender
{
    Accessories *selectVideoInfo = [self.videoInfoArray objectAtIndex:[sender tag]];
    AttachDetailController *attachDetailController = [[AttachDetailController alloc] init];
    attachDetailController.filetype  = selectVideoInfo.type;
    attachDetailController.filepath  = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:selectVideoInfo.originName];
    attachDetailController.accessory = selectVideoInfo;
    [self.navigationController pushViewController:attachDetailController animated:YES];
}

- (void)deleteGrid:(UIButton *)sender {
    self.selectAccessoryIndex = [sender tag];
    self.selectAccessorySender = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确认删除该附件吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认删除",nil];
    [alert show];
}

//在相册保存
-(void)albumThreadTask:(NSDictionary *)urlDic
{
    UISaveVideoAtPathToSavedPhotosAlbum([urlDic objectForKey:@"savefilepath"],nil,nil,nil);
    [NSThread sleepForTimeInterval:1];//延时释放变量
    [self hideWaiting];
}

-(void)newThreadTask:(NSDictionary *)filedic
{
    //保存视频
    [[filedic objectForKey:@"content"] writeToFile:[filedic objectForKey:@"savefilepath"] atomically:YES];
    
    //更新数据库
    [self addAttach:[filedic objectForKey:@"savefilepath"] type:FileNameTagsVideo originName:[filedic objectForKey:@"OriginName"]];
    
    
    //更新视图
    [self addGridView:[filedic objectForKey:@"savefilepath"]];
    
    [NSThread sleepForTimeInterval:0.1];//延时释放变量
    [self hideWaiting];
}

#pragma mark - CLLocationDelegaate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    if (newLocation!=nil) {
        [self.locationManager stopUpdatingLocation];
        NSString *latitudeStr  = [[NSString alloc] initWithFormat:@"%f",newLocation.coordinate.latitude];
        NSString *longitudeStr = [[NSString alloc] initWithFormat:@"%f",newLocation.coordinate.longitude];
        
        self.mcripts.location = [NSString stringWithFormat:@"%@,%@",latitudeStr,longitudeStr];
        [self saveManuscript];
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:self.mcripts.location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"当前定位不可用！"];
}


#pragma mark - ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            //用户拍摄
        case 0:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                self.isCamera = TRUE;
                [self.view endEditing:YES];
//                UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
                
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    [self.view addSubview:self.startBtn];
                    [self.view addSubview:self.videoTimeLb];
                    [self.view addSubview:self.previewVideo];
                    [self.view bringSubviewToFront:self.startBtn];
                    [self.view bringSubviewToFront:self.videoTimeLb];
                    [self resetCapture];
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                                 message:@"摄像头不可用"
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
                    [alert show];
                }
                break;
      
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                             message:@"摄像头不可用"
                                                            delegate:self
                                                   cancelButtonTitle:@"关闭"
                                                   otherButtonTitles:nil];
                [alert show];
            }
            self.isCamera = TRUE;
            break;
        }
            //用户相册
        case 1:
        {
            UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,nil];
                [imagePicker setAllowsEditing:NO];
                imagePicker.delegate = self;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                             message:@"访问错误"
                                                            delegate:nil
                                                   cancelButtonTitle:@"关闭"
                                                   otherButtonTitles:nil];
                [alert show];
            }
            self.isCamera = FALSE;
            break;
            
        }
            
        default:
            break;
    }

}

#pragma mark - PBJVisionDelegate
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
    [self hideWaiting];
    self.pbvision.delegate=nil;
    if (!error) {
        // NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    [self addAttach:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:self.currentVideoPath] type:FileNameTagsVideo originName:self.currentVideoPath];
    [self addGridView:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:self.currentVideoPath] ];
    NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",[FILE_PATH_IN_PHONE stringByAppendingPathComponent:self.currentVideoPath],@"savefilepath",MOV_TYPE,@"filename",nil];
    [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.dateFormat = @"ddMMYY_hhmmsss";
    NSURL *videoURL=[info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    //保存路径
    NSString *str = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],MOV_TYPE];//文件名称
    NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:str];//保存路径
    //accessories.originName=str;
    //写到数组
//    NSDictionary *row1=[[NSDictionary alloc] initWithObjectsAndKeys:str,@"name",savefilepath,@"savefilepath",nil];
    [self showWait];
    NSString *compress= [[NSUserDefaults standardUserDefaults] objectForKey:COMPRESS];
    //视频压缩
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetExportSession *exportSession;
    if ([compress isEqual:@"高"])
    {
        NSDictionary *filedic=[[NSDictionary alloc] initWithObjectsAndKeys:videoData,@"content",savefilepath,@"savefilepath",MOV_TYPE,@"filename",str,@"OriginName",nil];
        [NSThread detachNewThreadSelector:@selector(newThreadTask:) toTarget:self withObject:filedic];
        picker.delegate = nil;
        
        //保存到媒体库
        if (self.isCamera) {
            NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",[videoURL path],@"savefilepath",MOV_TYPE,@"filename",nil];
            [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
        
    }else if([compress isEqual:@"中质量"])
    {
        exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                        presetName:AVAssetExportPresetMediumQuality];
    }
    else
    {
        exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                        presetName:AVAssetExportPresetLowQuality];
    }
    exportSession.outputURL = [NSURL fileURLWithPath: savefilepath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                [self addAttach:savefilepath type:FileNameTagsVideo originName:str];
                [self addGridView:savefilepath];
                [self hideWaiting];
                //保存到媒体库
                if (self.isCamera) {
                    NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",[videoURL path],@"savefilepath",MOV_TYPE,@"filename",nil];
                    [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
                }
                
                break;
            }
            default:
                break;
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate=nil;
}











@end
