//
//  NewTextController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewTextController.h"
#import "Manuscripts.h"
#import "ManuscriptsDB.h"
#import <CoreLocation/CoreLocation.h>
#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"
#import "NewTagDetailViewController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "UIView+FirstResponder.h"
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"

@interface NewTextController () <CLLocationManagerDelegate,UITextFieldDelegate,IFlyRecognizerViewDelegate>

@property(strong, nonatomic) UITextView *bodyTextView;
@property(strong, nonatomic) UITextView *titleField;
@property(strong, nonatomic) UILabel *static_title;
@property(strong, nonatomic) UILabel *labelBottom;
@property(strong, nonatomic) UIButton *btnLocation;
@property(strong, nonatomic) UIButton *btnSave;
@property(strong, nonatomic) UIButton *keyboardButton;
@property(nonatomic,strong) UIButton *showDetailBtn;
@property(nonatomic,strong) UIButton *btnifly;//讯飞语音
@property(assign, nonatomic) BOOL keyboardHide;

@property(nonatomic,strong) Manuscripts *mcripts;
@property(nonatomic,strong) ManuscriptsDB *manuscriptsdb;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic, strong)  NSTimer *timer;//自动保存定时器
@property (nonatomic,copy) NSMutableArray *accessoriesArry;
@property(nonatomic,strong) IFlyRecognizerView *iflyRecognizerView;

@end

@implementation NewTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.static_title = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+5.0, 52, 21)];
    self.static_title.font = [UIFont systemFontOfSize:16];
    self.static_title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.static_title];
    
    self.titleField = [[UITextView alloc] initWithFrame:CGRectMake(53, CGRectGetMinY(self.static_title.frame)+5.0, 257, 21)];
    [self.titleField becomeFirstResponder];
    self.titleField.font = [UIFont systemFontOfSize:14];
    self.titleField.textAlignment = NSTextAlignmentLeft;
    self.titleField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.titleField];
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.static_title.frame)+5.0, 300, 1)];
    topLine.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:topLine];
    
    self.bodyTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+35.0, 290, self.view.frame.size.height-130-CGRectGetMaxY(self.titleLabelAndImage.frame))];
    self.bodyTextView.font = [UIFont systemFontOfSize:14];
    self.bodyTextView.userInteractionEnabled = YES;
    self.bodyTextView.multipleTouchEnabled = YES;
    self.bodyTextView.scrollEnabled=YES;
    [self.view addSubview:self.bodyTextView];
    
    self.showDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25, self.view.frame.size.height/2-55, 25, 60)];
    [self.showDetailBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.showDetailBtn setImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    self.showDetailBtn.userInteractionEnabled = YES;
    [self.showDetailBtn addTarget:self action:@selector(showTemplateView:) forControlEvents:UIControlEventTouchUpInside];
    [self.showDetailBtn setContentMode:UIViewContentModeCenter];
    [self.showDetailBtn setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.showDetailBtn];
    
    self.btnifly = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4.0-35./2., self.view.frame.size.height-70+10, 35, 35)];
    [self.btnifly setImage:[UIImage imageNamed:@"express_iflyButton"] forState:UIControlStateNormal];
    [self.btnifly addTarget:self action:@selector(onButtonRecognize) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnifly];
    
    self.btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4.0*2-35./2., self.view.frame.size.height-70+10, 35, 35)];
    [self.btnLocation setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnLocation setImage:[UIImage imageNamed:@"express_location.png"] forState:UIControlStateNormal];
    self.btnLocation.userInteractionEnabled = YES;
    [self.btnLocation addTarget:self action:@selector(attachLocationInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLocation setContentMode:UIViewContentModeCenter];
    [self.btnLocation setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.btnLocation];
    
    self.btnSave = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4.0*3-35./2. , self.view.frame.size.height-70+10, 35, 35)];
    [self.btnSave setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.btnSave setImage:[UIImage imageNamed:@"express_save.png"] forState:UIControlStateNormal];
    self.btnSave.userInteractionEnabled = YES;
    [self.btnSave addTarget:self action:@selector(saveExpress:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSave setContentMode:UIViewContentModeCenter];
    [self.btnSave setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.btnSave];
    
    self.labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-80+10, 300, 1)];
    //bottomLine.textColor=[UIColor blueColor];
    self.labelBottom.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:self.labelBottom];
    
    [self initializeController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [NOTIFICATION_CENTER removeObserver:self];
}

-(void)returnToParentView:(id)sender
{
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])//新稿件
    {
        if (([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.titleField.text] isEqualToString:self.mcripts.mTemplate.defaultTitle])&&([[Utility trimBlankSpace:self.bodyTextView.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.bodyTextView.text] isEqualToString:self.mcripts.mTemplate.defaultContents]))
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
    //返回上级页面
    [self.navigationController popViewControllerAnimated:TRUE];
    
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    UIViewAnimationCurve animationCurve	= [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView beginAnimations:@"RS_showKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.labelBottom.frame = CGRectMake(10, self.view.frame.size.height-kbSize.height-36-3, 300, 1);
    self.btnifly.frame = CGRectMake(self.view.frame.size.width/4.0-35./2., self.view.frame.size.height-kbSize.height-36, 35, 35);
    self.btnLocation.frame = CGRectMake(self.view.frame.size.width/4.0*2-35./2., self.view.frame.size.height-kbSize.height-36, 35, 35);
    self.btnSave.frame = CGRectMake(self.view.frame.size.width/4.0*3-35./2., self.view.frame.size.height-kbSize.height-36, 35, 35);
    //设置textview的高度，以保证用户可以看到全部的内容，不受键盘遮挡
    self.bodyTextView.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+35.0, 290, self.view.frame.size.height-kbSize.height-50-30-CGRectGetMaxY(self.titleLabelAndImage.frame));
    self.showDetailBtn.frame = CGRectMake(self.view.frame.size.width-25, self.view.frame.size.height-kbSize.height-60-35-20, 25, 60);
    self.keyboardButton.alpha = 1.0;
    self.keyboardButton.frame = CGRectMake(6, self.view.frame.size.height-kbSize.height-36, 40, 50);
    [UIView commitAnimations];
    self.keyboardHide=FALSE;
    [self.keyboardButton setHidden:FALSE];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    self.labelBottom.frame = CGRectMake(10, self.view.frame.size.height-80, 300, 1);
    self.btnifly.frame = CGRectMake(self.view.frame.size.width/4.0-35./2., self.view.frame.size.height-70, 35, 35);
    self.btnLocation.frame = CGRectMake(self.view.frame.size.width/4.0*2-35./2., self.view.frame.size.height-70, 35, 35);
    self.btnSave.frame = CGRectMake(self.view.frame.size.width/4.0*3-35./2. , self.view.frame.size.height-70, 35, 35);
    //设置textview的高度，以保证用户可以看到全部的内容，不受键盘遮挡
    self.bodyTextView.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+35.0, 290, self.view.frame.size.height-130-CGRectGetMaxY(self.titleLabelAndImage.frame));
    
    self.showDetailBtn.frame = CGRectMake(self.view.frame.size.width-25, self.view.frame.size.height/2-55, 25, 60);
    [UIView commitAnimations];
    self.keyboardHide=TRUE;
    self.keyboardButton.alpha = 0.0;
    [self.keyboardButton setHidden:TRUE];
    
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyDefault;
    [self.bodyTextView becomeFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyDone;
    return YES;
}

#pragma mark - Private
//页面初始化
- (void)initializeController {
    //初始化数据库连接
    self.manuscriptsdb = [[ManuscriptsDB alloc] init];
    
    //初始化数据实体对象.此处为对象属性，在本类中各个方法中都能访问。
    self.mcripts = [[Manuscripts alloc] init];
    
    //判断其他视图进入本视图时是否传入了稿件id，即区分“新建”还是“编辑”
    if(![self.manuscript_id isEqualToString:@""])
    {
        //获取稿件信息
        self.mcripts = [self.manuscriptsdb getManuscriptById:self.manuscript_id];
  
        //绑定标题、正文
        self.bodyTextView.text = self.mcripts.contents;
        self.titleField.text = self.mcripts.title;
    }
    else {
        //获得默认稿签模板
        ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
        self.mcripts.mTemplate = [mdb getDefaultManuscriptTemplate:TEXT_EXPRESS_TEMPLATE_TYPE
                                                         loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
        self.bodyTextView.text = self.mcripts.mTemplate.defaultContents;
        self.titleField.text = self.mcripts.mTemplate.defaultTitle;
    }
    
    //页面第一次进入时，将传入的稿件id保存在缓存中。如果是“新建稿件”，则为@“”。
    [USERDEFAULTS setObject:self.manuscript_id forKey:CURRENT_MANUSCRIPTID_SESSIONId];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"express_text"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"文字快讯" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    
    //添加发送按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"express_send.png"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(sendExpress:) forControlEvents:UIControlEventTouchUpInside];
    
    //zyq 国际化
    self.static_title.text = @"标题";
    
    //控制键盘按钮
    self.keyboardHide = FALSE;
    self.keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(6,430,40,50)];
    [self.keyboardButton setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
    [self.keyboardButton addTarget:self action:@selector(controlkeyboard:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardButton.alpha = 0.0;
    [self.view addSubview:self.keyboardButton];
    
    //定时器初始化
    int autoSaveTime = 0;
    if([USERDEFAULTS objectForKey:AUTO_SAVE_TIME])
    {
        autoSaveTime = [[USERDEFAULTS objectForKey:AUTO_SAVE_TIME] intValue];
    }
    if( autoSaveTime > 0 )
    {
        self.timer=[NSTimer scheduledTimerWithTimeInterval:autoSaveTime target:self selector:@selector(autoSaveManuscript) userInfo:nil repeats:YES];
    }
}

- (void)sendManuscript
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
    
    //发送前的准备工作，将稿件信息保存并根据附件个数进行拆条
    NSMutableArray *manuArray = [Utility prepareToSendManuscript:self.mcripts accessories:nil userInfoFromServer:[Utility sharedSingleton].userInfo];
    if( [manuArray count]>0 ){
        [Utility xmlPackage:[manuArray objectAtIndex:0] accessories:nil];
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"请到待发稿件中查看发送进程"];
    }
    
    //返回上级页面
    [self.timer invalidate];
    [self hideWaiting];
    [self.navigationController popViewControllerAnimated:TRUE];
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

        [USERDEFAULTS setObject:currentManuscriptId forKey:CURRENT_MANUSCRIPTID_SESSIONId];
        
        logInfo = [self insertNewManuscript:currentManuscriptId];
    }
    else {
        logInfo = [self updateManuscript:currentManuscriptId];
    }
    return logInfo;
}

//第一次保存，即插入一条新的稿件
-(NSString*)insertNewManuscript:(NSString*)manuscriptId
{
    self.mcripts.m_id = manuscriptId;//必填。
    if([self.mcripts.mTemplate.loginName isEqualToString:@""])
    {
        self.mcripts.mTemplate.loginName = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_NAME];
    }
    if( [self.mcripts.mTemplate.loginName isEqualToString:@""] )
    {
        return @"当前登录名为空，未保存";
    }
    self.mcripts.title=[Utility trimBlankSpace:self.titleField.text];
    
    self.mcripts.contents=[Utility trimBlankSpace:self.bodyTextView.text];
    
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
-(NSString*)updateManuscript:(NSString*)manuscriptId
{
    self.mcripts.title = [Utility trimBlankSpace:self.titleField.text];
    self.mcripts.contents = [Utility trimBlankSpace:self.bodyTextView.text];
    if ([self.manuscriptsdb updateManuscript:self.mcripts]) {
        return @"保存稿件成功";
    }
    else {
        return @"保存稿件失败";
    }
}

- (void)initRecognizer {
    //单例模式，UI的实例
    if (self.iflyRecognizerView == nil) {
        //UI显示剧中
        self.iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
        
        [self.iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [self.iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        self.iflyRecognizerView.delegate = self;
        
        if (self.iflyRecognizerView != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            //设置最长录音时间
            [self.iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [self.iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [self.iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [self.iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [self.iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [self.iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [self.iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                //设置语言
                [self.iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [self.iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }
    
}

- (void)textFieldDoneEditing:(id)sender
{
    [self.bodyTextView becomeFirstResponder];
}

#pragma mark - Action Method
//稿签编辑页
- (void)showTemplateView:(id)sender
{
    NewTagDetailViewController *tagController = [[NewTagDetailViewController alloc] init];
    tagController.manuscriptTemplate = self.mcripts.mTemplate;
    tagController.templateType = TemplateTypeEditAble;
    tagController.delegate = self;
    [self.navigationController pushViewController:tagController animated:YES];

}

// 转写,语音识别
- (void)onButtonRecognize
{
    //若键盘弹出则收回
    [self.view endEditing:YES];
    
    // 识别控件
    if(self.iflyRecognizerView == nil)
    {
        [self initRecognizer];
    }
    
    //设置音频来源为麦克风
    [self.iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [self.iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    if([self.iflyRecognizerView start])
    {
        [self disableButton];
    }

}

- (void)disableButton
{
    self.btnifly.enabled = NO;
    self.bodyTextView.editable = NO;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.userInteractionEnabled = NO;
        }
    }
}

- (void)enableButton
{
    self.btnifly.enabled = YES;
    self.bodyTextView.editable = YES;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.userInteractionEnabled = YES;
        }
    }
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
            self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 5.0f; // in meters
        }
        [self.locationManager startUpdatingLocation];
    }
}

-(void)saveExpress:(id)sender
{
    NSString *retInfo = @"";
    if ([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
    {
        retInfo = @"请输入稿件标题";
    }
    else {
        retInfo = [self saveManuscript];
    }
    
    [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:retInfo];
}


-(void)sendExpress:(id)sender
{
    //如果键盘处于打开状态，则关闭
    if (!self.keyboardHide) {
        [self.titleField resignFirstResponder];//隐藏键盘
        [self.bodyTextView resignFirstResponder];
    }
    if((![[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]))
    {
        [self sendManuscript];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"标题不能为空"];
    }
}

//控制键盘弹出和隐藏
-(void)controlkeyboard:(id)sender
{
    if (self.keyboardHide) {
        [self.bodyTextView becomeFirstResponder];
    }
    else {
        [[self.view findFirstResponder] resignFirstResponder];;//隐藏键盘
    }
}

//自动保存稿件
-(void)autoSaveManuscript
{
    //1、对于“编辑”，则当前稿件的正文和标题属性是有值的，且初始情况下与视图的两个对应控件的值相同；
    //2、对于“新建”，则当前稿件的正文和标题属性在初始情况下没有值，但视图的两个对应控件有值。
    //由1和2可知，判断当前稿件的正文和标题属性与视图控件的值是否相同，可以判断出当前视图的标题和正文是否被修改且还未保存。
    //如果不相同，则需要保存当前稿件（保存的方法内部会区分是“新建”还是“编辑”）；否则不需要保存（因为稿件的附件和稿签属性会在修改时直接保存）
    if( (![self.mcripts.title isEqualToString:[Utility trimBlankSpace:self.titleField.text]])
       ||(![self.mcripts.contents isEqualToString:[Utility trimBlankSpace:self.bodyTextView.text]]))
    {
        if([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
        {
            self.mcripts.title = @"<无标题>";
        }
        NSString *message = [self saveManuscript];
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:message];
        
    }
}

#pragma mark - NewTagDetailViewController返回调用
//回传稿签数据
-(void)returnManuScriptTemplate:(ManuscriptTemplate *)manuscripttemplate
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



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    if (newLocation!=nil) {
        [self.locationManager stopUpdatingLocation];
        NSString *latitudeStr = [[NSString alloc] initWithFormat:@"%f",newLocation.coordinate.latitude];
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

#pragma mark - IFlyRecognizeControlDelegate
//	识别结束回调
//	识别结束回调
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    self.bodyTextView.text = [NSString stringWithFormat:@"%@%@",self.bodyTextView.text,result];
}

- (void)onError:(IFlySpeechError *)error {
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    NSLog(@"%@",error.errorDesc);
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    [self enableButton];
}


@end
