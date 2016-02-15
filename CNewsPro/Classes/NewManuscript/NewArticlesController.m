//
//  NewArticlesController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewArticlesController.h"
#import "ManuscriptsDB.h"
#import "Manuscripts.h"
#import "AccessoriesDB.h"
#import "VideoGrid.h"
#import "PBJVision.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ManuscriptTemplateDB.h"
#import "Utility.h"
#import "ManuscriptTemplate.h"
#import "Accessories.h"
#import "AppDelegate.h"
#import "NewTagDetailViewController.h"
#import "AttachDetailController.h"
#import "UIView+FirstResponder.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RecordVoiceController.h"
#import "EditingScriptController.h"
//#import <iflyMSC/IFlyRecognizerView.h>
//#import <iflyMSC/IFlyRecognizerViewDelegate.h>
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"

static const NSInteger kButtonWidth = 95.0f;
static const NSInteger kButtonHeight = 95.0f;
//定义的归档的关键字
static NSString *kTemporaryTemplateDataKey = @"temporaryData";
static NSString *kAutoSaveTime = @"kAutoSaveTime";

@interface NewArticlesController () <UIActionSheetDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PBJVisionDelegate,IFlyRecognizerViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UITextView *tvContent;
@property (nonatomic,strong) UITextView *titleField;
@property (nonatomic,strong) UIButton *saveBtn;
@property (nonatomic,strong) UIButton *locationBtn;
@property (nonatomic,strong) UIButton *addAttachBtn;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,strong) UILabel *title_static;
@property (nonatomic,strong) UIScrollView *scrollView1;
@property (nonatomic,copy) NSMutableArray *imageArray;
@property (nonatomic,copy) NSMutableArray *videoArray;
@property (nonatomic,copy) NSMutableArray *voiceArray;
@property (nonatomic,strong) UIButton *keyboardButton;
@property (nonatomic,strong) NSTimer *timer;//自动保存定时器
@property (nonatomic,copy)  NSMutableArray *accessoriesArry;//附件列表
@property (nonatomic,strong) ManuscriptsDB *manuscriptsdb;
@property (nonatomic,assign) BOOL keyboardHide;
@property (nonatomic,strong) Manuscripts *mcripts;
@property (nonatomic,strong) AccessoriesDB *accessoriesdb;
@property (nonatomic,assign) NSInteger keyboardHeight;
@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,assign) NSInteger selectAccessoryIndex;
@property (nonatomic,strong) UIButton *selectAccessorySender;
@property (nonatomic,strong) VideoGrid *addGrid;
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic,strong) UIView *previewVideo;//自定义摄像头画面
@property (nonatomic,strong) UIButton *startBtn;
@property (nonatomic,strong) UIButton *cancelCaptureBtn;
@property (nonatomic,assign) BOOL btnTag;
@property (nonatomic,assign) BOOL isCamera;
@property (nonatomic,strong) UIButton *btnifly;
@property (nonatomic,copy)  NSString *currentVideoPath;
@property (nonatomic,strong) PBJVision *pbvision;
@property (nonatomic,assign) NSInteger videoSecond;
@property (nonatomic,strong) UILabel *videoTimeLb;
@property (nonatomic,strong) NSTimer *videoTimer;
@property (nonatomic,copy) NSMutableArray *gridArray;
@property (nonatomic,copy) NSMutableArray *audioInfoArray;
@property(nonatomic,strong) IFlyRecognizerView *iflyRecognizerView;

@end

@implementation NewArticlesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentVideoPath = @"";
    self.btnTag=false;
    self.scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView)];
    
    self.scrollView1.userInteractionEnabled = YES;
    self.scrollView1.multipleTouchEnabled = YES;
    self.scrollView1.scrollEnabled = YES;
    self.scrollView1.bounces = NO;
    self.scrollView1.showsHorizontalScrollIndicator=NO;
    [self.scrollView1 setContentSize:CGSizeMake(self.view.bounds.size.width,self.view.frame.size.height+50)];
    self.title_static = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 52, 21)];
    self.title_static.font = [UIFont systemFontOfSize:17];
    self.title_static.textAlignment = NSTextAlignmentLeft;
    [self.scrollView1 addSubview:self.title_static];
    
    self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, self.scrollView1.frame.size.width-5, 21)];
    self.labelTitle.font = [UIFont systemFontOfSize:15];
    self.labelTitle.textAlignment = NSTextAlignmentLeft;
    [self.scrollView1 addSubview:self.labelTitle];
    
    self.titleField = [[UITextView alloc] initWithFrame:CGRectMake(54, 3, 257, 30)];
    [self.titleField becomeFirstResponder];
    self.titleField.font = [UIFont systemFontOfSize:15];
    self.titleField.textAlignment = NSTextAlignmentLeft;
    self.titleField.returnKeyType = UIReturnKeyDone;
    [self.scrollView1 addSubview:self.titleField];
    
    self.tvContent = [[UITextView alloc] initWithFrame:CGRectMake(11, self.title_static.frame.size.height+8+10-5, 297, self.scrollView1.frame.size.height-200)];
    self.tvContent.backgroundColor = [UIColor colorWithWhite:254.0/255.0 alpha:1.0];
    self.tvContent.font = [UIFont systemFontOfSize:15];
    self.tvContent.textAlignment = NSTextAlignmentLeft;
    self.tvContent.userInteractionEnabled = YES;
    self.tvContent.multipleTouchEnabled = YES;
    [self.scrollView1 addSubview:self.tvContent];
    
    self.btnifly = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/5.0-35./2., self.scrollView1.frame.size.height-100-50, 35, 35)];
    [self.btnifly setImage:[UIImage imageNamed:@"express_iflyButton"] forState:UIControlStateNormal];
    [self.btnifly addTarget:self action:@selector(onButtonRecognize) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView1 addSubview:self.btnifly];
    
    self.addAttachBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/5.0*2-35./2., self.scrollView1.frame.size.height-100-50, 35, 35)];
    [self.addAttachBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.addAttachBtn setImage:[UIImage imageNamed:@"manuscript_addaccessory.png"] forState:UIControlStateNormal];
    self.addAttachBtn.userInteractionEnabled = YES;
    [self.addAttachBtn addTarget:self action:@selector(addAttachment:) forControlEvents:UIControlEventTouchUpInside];
    [self.addAttachBtn setContentMode:UIViewContentModeCenter];
    [self.addAttachBtn setShowsTouchWhenHighlighted:YES];
    [self.scrollView1 addSubview:self.addAttachBtn];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/5.0*3-35./2., self.scrollView1.frame.size.height-100-50, 35, 35)];
    [self.locationBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.locationBtn setImage:[UIImage imageNamed:@"express_location"] forState:UIControlStateNormal];
    self.locationBtn.userInteractionEnabled = YES;
    [self.locationBtn addTarget:self action:@selector(attachLocationInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setContentMode:UIViewContentModeCenter];
    [self.locationBtn setShowsTouchWhenHighlighted:YES];
    [self.scrollView1 addSubview:self.locationBtn];
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/5.0*4-35./2., self.scrollView1.frame.size.height-100-50, 35, 35)];
    [self.saveBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.saveBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    self.saveBtn.userInteractionEnabled = YES;
    [self.saveBtn addTarget:self action:@selector(saveManuscriptAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn setContentMode:UIViewContentModeCenter];
    [self.saveBtn setShowsTouchWhenHighlighted:YES];
    [self.scrollView1 addSubview:self.saveBtn];
    
    UIButton *showDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, self.scrollView1.frame.size.height/2-55, 25, 60)];
    [showDetailBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [showDetailBtn setImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    showDetailBtn.userInteractionEnabled = YES;
    [showDetailBtn addTarget:self action:@selector(showTagDetailController:) forControlEvents:UIControlEventTouchUpInside];
    [showDetailBtn setContentMode:UIViewContentModeCenter];
    [showDetailBtn setShowsTouchWhenHighlighted:YES];
    [self.scrollView1 addSubview:showDetailBtn];
    
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(11, self.title_static.frame.size.height+8+5, SCREEN_WIDTH - 22, 1)];
    [topLine setImage:[UIImage imageNamed:@"TempleView_line.png"]];
    [self.scrollView1 addSubview:topLine];
    
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(12, self.scrollView1.frame.size.height-60-50, SCREEN_WIDTH - 22, 1)];
    [bottomLine setImage:[UIImage imageNamed:@"TempleView_line.png"]];
    [self.scrollView1 addSubview:bottomLine];
    
    self.scrollView1.hidden = NO;
    [self.view addSubview:self.scrollView1];
    
    [self initializeManusContent];
    
    [self initializeController];
    
    
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
    
    //屏幕预览底部视图遮盖
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 80)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:0.5f];
    
    //屏幕预览顶部视图遮盖
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [topView setBackgroundColor:[UIColor blackColor]];
    [topView setAlpha:0.5f];
    
    //视频录制按钮
    self.startBtn=[[UIButton alloc] initWithFrame:CGRectMake(120, self.view.frame.size.height-80, 80, 80)];
    [self.startBtn setImage:[UIImage imageNamed:@"RecordStart"] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startCapture:) forControlEvents:UIControlEventTouchUpInside];
    //视频录制取消按钮
    self.cancelCaptureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-80, 100, 80)];
    [self.cancelCaptureBtn setTitle:@"取 消" forState:UIControlStateNormal];
    [self.cancelCaptureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelCaptureBtn addTarget:self action:@selector(cancelCaptureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoTimeLb=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 35)];
    self.videoTimeLb.backgroundColor=[UIColor clearColor];
    self.videoTimeLb.textAlignment = NSTextAlignmentCenter;
    self.videoTimeLb.textColor=[UIColor whiteColor];
    self.videoTimeLb.font=[UIFont boldSystemFontOfSize:18];
    
    [previewLayer addSublayer:bottomView.layer];
    [previewLayer addSublayer:topView.layer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
}

- (void)returnToParentView:(UIButton *)button {
    //    用户点击“返回”图标时，首先判断当前稿件是否已经存在，即是新的稿件还是已保存的稿件。
    //    （1）如果是新稿件：判断标题、正文、附件是否为空：
    //      （1.1）全部为空，则直接返回；（这是对于用户点击新建稿件或快讯后没有进行任何操作，直接返回的情况）
    //      （1.2）标题为空，则提示用户输入标题；
    //      （1.3）标题不为空，则保存该稿件并返回。
    //    （2）如果是已有稿件：判断标题、正文、附件是否为空：(要区分当前是从在编稿件进入、查看、新建时保存过)
    //      //（2.1）全部为空，则删除当前稿件；
    //      （2.1）标题为空，则提示用户输入标题；
    //      （2.2）标题不为空，则更新该稿件并返回。
    
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])//新稿件
    {
        if (([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.titleField.text] isEqualToString:self.mcripts.mTemplate.defaultTitle])&&([[Utility trimBlankSpace:self.tvContent.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.tvContent.text] isEqualToString:self.mcripts.mTemplate.defaultContents])&&(self.accessoriesArry.count == 0))
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
        if( [self.operationType isEqualToString:@"detail"] )//查看时，直接返回
        {
            //直接返回上级视图
        }
        else //非查看时，如果标题不为空，则更新。进而判断是否从在编稿件中进入的，如果是，则回调刷新方法。
        {
            if( [[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""] )
            {
                [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"请输入稿件标题"];
                return;
            }
            else {
                //更新已有稿件
                [self updateManuscript:currentManuscriptId];
                //如果是在编稿件调用的本视图，则返回时要进行数据更新
                if(![self.manuscript_id isEqualToString:@""])
                {
                    if(self.delegate)
                    {

                        [self.delegate reloadCell:currentManuscriptId cellIndexPath:self.indexPath];

                    }
                }
                
            }
        }
    }
    
    [self.timer invalidate];
    
    //返回上级页面
    [self.navigationController popViewControllerAnimated:TRUE];
    

}

#pragma mark - 初始化方法
//页面首次进入时，初始化稿件内容
-(void)initializeManusContent
{
    //调用数据库函数
    self.manuscriptsdb = [[ManuscriptsDB alloc] init];
    self.accessoriesdb = [[AccessoriesDB alloc] init];
    
    //初始化数据实体对象.此处为对象属性，在本类中各个方法中都能访问。
    self.mcripts = [[Manuscripts alloc] init];
    // zc 去掉accessores属性，因为会有多个附件，共用这一个属性不易维护。改为在保存和删除附件的方法内部实例化该对象
    self.accessoriesArry = [[NSMutableArray alloc] initWithCapacity:0];
    
    //button队列 (附件队列)
    self.gridArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.addGrid = [[VideoGrid alloc] initWithFrame:CGRectMake(5, 250, kButtonWidth, kButtonHeight)];
    self.addGrid.btnDelete.hidden = YES;
    [self.addGrid.btnPic setTitle:@"添加" forState:UIControlStateNormal];
    [self.addGrid.btnPic addTarget:self action:@selector(showDetailAttachment:) forControlEvents:UIControlEventTouchUpInside];
    
    //判断其他视图进入本视图时是否传入了稿件id，即区分“新建”还是“编辑”
    if(![self.manuscript_id isEqualToString:@""])
    {
        [self.titleLabelAndImage setTitle:@"在编稿件" forState:UIControlStateNormal];
        
        //获取稿件信息
        self.mcripts = [self.manuscriptsdb getManuscriptById:self.manuscript_id];
    
        //绑定标题、正文
        self.tvContent.text = self.mcripts.contents;
        self.titleField.text = self.mcripts.title;
        
        //将稿签的标题和正文赋值为当前稿件的标题和正文
        self.mcripts.mTemplate.defaultTitle = self.mcripts.title;
        self.mcripts.mTemplate.defaultContents = self.mcripts.contents;
        
        //获取附件信息，并存入附件列表
        self.accessoriesArry = [self.accessoriesdb getAccessoriesListByMId:self.manuscript_id];
        //绑定附件列表
        for (int i = 0; i < [self.accessoriesArry count]; i++) {
            [self renderAccessoriesView:[self.accessoriesArry objectAtIndex:i]];
        }
    }
    else {
        [self.titleLabelAndImage setTitle:@"新建稿件" forState:UIControlStateNormal];
        
        NSString *bodyText = @"";
        NSString *titleText = @"";
        ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
        ManuscriptTemplate *demanuscriptTemplate = [mdb getDefaultManuscriptTemplate:MANUSCRIPT_TEMPLATE_TYPE loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
      
        //查看是否存在临时稿签，如存在即加载该稿签
        NSString *filePath = [Utility temporaryTemplateFilePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            //获得默认稿签模板,用来获得稿件的标题和正文
            ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
            ManuscriptTemplate *manuscriptTemplate = [mdb getDefaultManuscriptTemplate:MANUSCRIPT_TEMPLATE_TYPE loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
           
            bodyText = demanuscriptTemplate.defaultContents;//标题和正文还需要加载默认的标题和正文
            titleText = demanuscriptTemplate.defaultTitle;
            //加载临时稿签信息
            NSData *data = [[NSMutableData alloc]
                            initWithContentsOfFile:[Utility temporaryTemplateFilePath]];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            manuscriptTemplate = [unarchiver decodeObjectForKey:kTemporaryTemplateDataKey];
            [unarchiver finishDecoding];
            
            self.mcripts.mTemplate = manuscriptTemplate;
        }
        else {
            //获得默认稿签模板
            self.mcripts.mTemplate = demanuscriptTemplate;
            
            bodyText = self.mcripts.mTemplate.defaultContents;
            titleText = self.mcripts.mTemplate.defaultTitle;
        }
        self.tvContent.text = bodyText;
        self.titleField.text = titleText;
    }
    
    //页面第一次进入时，将传入的稿件id保存在缓存中。如果是“新建稿件”，则为@“”。
    [USERDEFAULTS setObject:self.manuscript_id forKey:CURRENT_MANUSCRIPTID_SESSIONId];
}

//页面控件初始化
-(void)initializeController
{
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"manuscript_logo.png"] forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    
    //zyq 静态标题二字
    self.title_static.text = @"标题";
    
    //判断当前页面是否为“查看”，并做出响应处理
    if( [self.operationType isEqualToString:@"detail"] )
    {
        self.btnifly.hidden = YES;
        self.saveBtn.hidden = YES;
        self.addAttachBtn.hidden = YES;
        self.locationBtn.hidden = YES;
        self.tvContent.editable = NO;
        self.titleField.hidden = YES;
        
        [self.titleLabelAndImage setTitle:@"查看稿件" forState:UIControlStateNormal];
        
        self.labelTitle.text = self.titleField.text;
        self.labelTitle.hidden = NO;
    }
    else {//不是“查看”，就是“新建”或“编辑”
        
        self.labelTitle.hidden = YES;
        
        //添加键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        //控制键盘按钮
        self.keyboardHide = TRUE;

        self.keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(10,self.scrollView1.frame.size.height/2,50,40)];
        [self.keyboardButton setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
        [self.keyboardButton addTarget:self action:@selector(controlkeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.keyboardButton];
        [self.keyboardButton setHidden:YES];
        
        //定时器初始化
        int autoSaveTime = 0;
        if([[NSUserDefaults standardUserDefaults] objectForKey:kAutoSaveTime])
        {
            autoSaveTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kAutoSaveTime] intValue];
        }
        
        if( autoSaveTime > 0 )
        {
            self.timer=[NSTimer scheduledTimerWithTimeInterval:autoSaveTime target:self selector:@selector(autoSaveManuscript) userInfo:nil repeats:YES];
        }
        //添加发送按钮
        self.rightButton.userInteractionEnabled = YES;
        [self.rightButton setImage:[UIImage imageNamed:@"express_send.png"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(sendManuScript:) forControlEvents:UIControlEventTouchUpInside];
    }
    
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
    
    self.tvContent.frame = CGRectMake(11, self.title_static.frame.size.height+8+10-5, 297, self.scrollView1.frame.size.height-kbSize.height-70);
    self.keyboardHeight = kbSize.height;
    self.keyboardButton.alpha = 1.0;
    self.keyboardButton.frame = CGRectMake(6,self.view.frame.size.height-self.keyboardHeight-36, 40,50);
    [UIView commitAnimations];
    self.keyboardHide=FALSE;
    [self.keyboardButton setHidden:FALSE];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    UIViewAnimationCurve animationCurve	= [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView beginAnimations:@"RS_hideKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    
    self.tvContent.frame = CGRectMake(11, self.title_static.frame.size.height+8+10-5, 297, self.scrollView1.frame.size.height-200);
    
    [UIView commitAnimations];
    self.keyboardHide=TRUE;
    [self.keyboardButton setHidden:TRUE];
}


#pragma mark - Private Method
//添加和绑定已有附件时，更新视图显示
-(void)renderAccessoriesView:(Accessories *)accessory
{
    UIImage *accessoryImage =[UIImage imageNamed:@"express_audioBtn.png"];
    if([accessory.type isEqualToString:@"PHOTO"])
    {
        accessoryImage =[UIImage imageWithContentsOfFile:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessory.originName]];
    
    }
    if([accessory.type isEqualToString:@"VIDEO"])
    {
        accessoryImage =[self getVideoImageByPath:[NSURL fileURLWithPath:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessory.originName]]];
    }
    if([accessory.type isEqualToString:@"AUDIO"])
    {
        accessoryImage =[UIImage imageNamed:@"express_audioBtn.png"];
    }
    
    //添加新Grid
    VideoGrid *newGrid = [[VideoGrid alloc] initWithFrame:self.addGrid.frame];
    [newGrid.btnPic addTarget:self action:@selector(showDetailAttachment:) forControlEvents:UIControlEventTouchUpInside];
    [self.gridArray insertObject:newGrid atIndex:[self.gridArray count]];
    //设置截图
    newGrid.btnPic.tag = [self.gridArray count] - 1;
    [newGrid.btnPic setImage:accessoryImage forState:UIControlStateNormal];
    //添加事件，记录tag值（index）
    newGrid.btnDelete.tag = [self.gridArray count] - 1;
    [newGrid.btnDelete addTarget:self action:@selector(deleteAttachment:) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.operationType isEqualToString:@"detail"])
    {
        newGrid.btnDelete.hidden = YES;
    }
    
    //插入队列
    NSUInteger add_grid_index = [self.gridArray count] - 1;
    
    //计算add按钮的新位置
    NSUInteger row = add_grid_index / 3;
    NSUInteger column = add_grid_index % 3;
    CGRect newAddGridFrame = CGRectMake(10+column*kButtonWidth+column*7, self.scrollView1.frame.size.height+row*kButtonHeight+row*7-100,kButtonWidth,kButtonHeight);
    
    NSUInteger scrollViewHeight = self.view.frame.size.height+row*105;
    [self.scrollView1 setContentSize:CGSizeMake(320,scrollViewHeight)];
    
    //处理动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    newGrid.frame = newAddGridFrame;
    [UIView commitAnimations];
    
    [self.scrollView1 addSubview:newGrid];
}


//获取指定本地路径的视频的截图
-(UIImage*)getVideoImageByPath:(NSURL*)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];  // 初始化视频媒体文件
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(200, 200);
    NSError *error = nil;
    
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(1, 1) actualTime:NULL error:&error];
    if (error == nil)
    {
        UIImage *image = [[UIImage alloc] initWithCGImage:img];
        CGImageRelease(img);
        return image;
    }
    else {
        CGImageRelease(img);
        return nil;
    }
}

//保存稿件。不负责保存稿件的附件信息。附件信息在添加和删除附件时完成。
- (NSString *)saveManuscript
{
    NSString *logInfo = @"";
    
    //获取稿件id
    NSString *currentManuscriptId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
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
    self.mcripts.title = [Utility trimBlankSpace:self.titleField.text];
    
    self.mcripts.manuscriptsStatus = MANUSCRIPT_STATUS_EDITING;   //稿件状态。必填。
    //zyq,12/10,添加地理位置信息
    self.mcripts.location = @"0.0,0.0"; //定位信息
    
    self.mcripts.createTime = [Utility getLogTimeStamp];
    
    if ([self.manuscriptsdb addManuScript:self.mcripts] > 0) {
        return @"保存稿件成功";
    }
    else {
        return @"保存稿件失败";
    }
    
}

//更新已存在的稿件
- (NSString*)updateManuscript:(NSString*)manuscriptId
{
    self.mcripts.title=[Utility trimBlankSpace:self.titleField.text];
    if ([self.manuscriptsdb updateManuscript:self.mcripts]) {
        return @"更新稿件成功";
    }
    else {
        return @"更新稿件失败";
    }
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

//更新附件列表。包括：1）判断附件类型；2）将附件存入数据库；3）更新视图显示
-(void)addAttach:(NSString *)url type:(NSInteger)type originName:(NSString *)originName imageInfo:(NSString *)imageInfo
{
    Accessories *accessory = [[Accessories alloc] init];
    //保存到数据库
    switch (type) {
        case FileNameTagsPhoto:
        {
            accessory.type=@"PHOTO";
            break;
        }
        case FileNameTagsAudio:
        {
            accessory.type=@"AUDIO";
            break;
        }
        case FileNameTagsVideo:
        {
            accessory.type=@"VIDEO";
            break;
        }
            
        default:
            break;
    }
    ////如果是图片，存图片的长宽;如果不是，暂时为空
    if([accessory.type isEqualToString: @"PHOTO"])
    {
        accessory.info = imageInfo;
    }
    else {
        accessory.info = @"非图片";
    }
    
    accessory.size= [NSString stringWithFormat: @"%ld", [Utility getFileLengthByPath:url]];
    accessory.createTime = [Utility getNowDateTime];
    
    NSInteger fileLength = [Utility getFileLengthByPath:url];
    accessory.size = [NSString stringWithFormat:@"%ld",fileLength];
    accessory.originName = originName;
    
    //依据缓存中的稿件稿件Id值，判断稿件是否已经保存。
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])
    {
        //说明该附件对应的稿件未保存，需要先保存稿件，然后根据稿件的m_id来添加附件
        [self saveManuscript];
        currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    }
    
    accessory.m_id = currentManuscriptId;

    //插入一条附件记录
    accessory.a_id = [Utility stringWithUUID];
    if(![self.accessoriesdb addAccessories:accessory])
        NSLog(@"附件插入失败%@",accessory.a_id);

    [self.accessoriesArry addObject:accessory];
    [self renderAccessoriesView:accessory];
    
    [self hideWaiting];

}

//在相册保存
-(void)albumThreadTask:(NSDictionary *)urlDic
{
    NSString *type=[urlDic objectForKey:@"filename"];

    if ([type isEqualToString:IMG_TYPE]) {
        UIImageWriteToSavedPhotosAlbum([urlDic objectForKey:@"content"], nil, nil, nil);
    }
    if ([type isEqualToString:MOV_TYPE]) {
        UISaveVideoAtPathToSavedPhotosAlbum([urlDic objectForKey:@"savefilepath"],nil,nil,nil);
    }

    [NSThread sleepForTimeInterval:1];//延时释放变量
    
    [self hideWaiting];
}

//添加声音，回掉函数
- (void)addVoice:(AVAudioRecorder *)recorder
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmss";
    NSString *originName = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],VOC_TYPE];//文件名称：当前时间＋.aif
    NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:originName];

    //保存到本地数组
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:originName,@"name",savefilepath,@"savefilepath",nil];
    [self.voiceArray insertObject:row1 atIndex:[self.voiceArray count]];
    NSData *movdata= [NSData dataWithContentsOfURL:recorder.url];
    
    //保存文件
    NSDictionary *filedic = [[NSDictionary alloc] initWithObjectsAndKeys:movdata,@"content",savefilepath,@"savefilepath",VOC_TYPE,@"filename", originName,@"OriginName",nil];
    [NSThread detachNewThreadSelector:@selector(saveAttachmentToDocument:) toTarget:self withObject:filedic];

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

#pragma mark - NewTagDetailViewController返回调用
//回传稿签数据
-(void)ReturnManuScriptTemplate:(ManuscriptTemplate *)manuscripttemplate
{
    if( [self.operationType isEqualToString:@"detail"] )
    {
        return;
    }
    else {
        self.mcripts.mTemplate = manuscripttemplate;
        //如果稿件已经被保存过，则将稿签信息更新至数据库
        NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
        if(![currentManuscriptId isEqualToString:@""])
        {
            [self saveManuscript];
        }
    }
}

#pragma mark - Target Action

// 转写 语音识别
- (void)onButtonRecognize
{
    //若键盘弹出则收回
    [self.view endEditing:YES];
    
//    NSString *initParam = [[NSString alloc] initWithFormat:
//                           @"server_url=%@,appid=%@",ENGINE_URL,APP_ID];
    
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
    self.tvContent.editable = NO;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.userInteractionEnabled = NO;
        }
    }

}

- (void)enableButton
{
    self.btnifly.enabled = YES;
    self.tvContent.editable = YES;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.userInteractionEnabled = YES;
        }
    }
}

//添加附件
- (void)addAttachment:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *actSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍摄照片",@"拍摄视频",@"媒体库",@"录音",nil];
    [actSheet showInView:self.view];
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

//视图上的保存按钮点击事件处理方法
- (void)saveManuscriptAction:(id)sender
{
    [self.view endEditing:YES];
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

//稿签编辑页
-(void)showTagDetailController:(id)sender
{
    NewTagDetailViewController *tagController = [[NewTagDetailViewController alloc] init];
    if ([self.operationType isEqualToString:@"detail"]) {
        tagController.templateType = TemplateTypeCheckAble;
    }
    else {
        tagController.templateType = TemplateTypeEditAble;
    }
    self.mcripts.mTemplate.defaultTitle = self.titleField.text;
    self.mcripts.mTemplate.defaultContents = self.tvContent.text;
    
    tagController.manuscriptTemplate = self.mcripts.mTemplate;
    tagController.superViewKeyboardShow = !self.keyboardHide;
    tagController.delegate = self;
    [self.navigationController pushViewController:tagController animated:YES];
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
        self.currentVideoPath = originName;
#warning PBJVision开始捕获
        //[[PBJVision sharedInstance] startVideoCapture:originName];
        
    }else
    {
        [self.videoTimer invalidate];
        self.videoSecond=0;
        self.videoTimeLb.text=@"00:00:00";
        AudioServicesPlaySystemSound(1117);
        [self.startBtn setImage:[UIImage imageNamed:@"RecordStart"] forState:UIControlStateNormal];
        self.btnTag=false;
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

//视频捕获取消按钮事件
- (void)cancelCaptureBtnAction:(id)sender {
    if (self.btnTag) {
        [self.videoTimer invalidate];
        self.videoSecond=0;
        self.videoTimeLb.text=@"00:00:00";
        AudioServicesPlaySystemSound(1117);
        self.btnTag=false;
        [self.startBtn setImage:[UIImage imageNamed:@"RecordStart"] forState:UIControlStateNormal];
    }
    
    [[PBJVision sharedInstance] stopPreview];
    [[PBJVision sharedInstance] endVideoCapture];
    self.pbvision.delegate = nil;
    [self.previewVideo removeFromSuperview];
    [self.startBtn removeFromSuperview];
    [self.cancelCaptureBtn removeFromSuperview];
    [self.videoTimeLb removeFromSuperview];
}

//设置相机配置
#warning 重置PBJVision,需要自定义方法？
- (void)resetCapture
{
//    NSInteger codeBit = [[USERDEFAULTS objectForKey:CODE_BIT] intValue];
//    NSString *resolution = [USERDEFAULTS objectForKey:RESOLUTION];
//    [[PBJVision sharedInstance] startPreviewWithMALV:codeBit];
//    self.pbvision = [PBJVision sharedInstance];
//    self.pbvision.delegate = self;
//    if ([resolution isEqualToString:@"352*288"]) {
//        pbvision.fenbianlv =AVCaptureSessionPreset352x288;
//    }
//    if ([resolution isEqualToString:@"640*480"]) {
//        pbvision.fenbianlv =AVCaptureSessionPreset640x480;
//    }
//    if ([resolution isEqualToString:@"1280*720"]) {
//        pbvision.fenbianlv =AVCaptureSessionPreset1280x720;
//    }
//    pbvision.pinzhen = 30;
//    [pbvision setCameraMode:PBJCameraModeVideo];    //设置📷模式
//    [pbvision setCameraDevice:PBJCameraDeviceBack];   //设置📷设备
//    [pbvision setCameraOrientation:PBJCameraOrientationPortrait]; //设置📷其方向
//    [pbvision setFocusMode:PBJFocusModeAutoFocus];
//    
}

//稿件详情页
-(void)showDetailAttachment:(id)sender
{
    Accessories *selectAudioInfo = [self.audioInfoArray objectAtIndex:[sender tag]];
    AttachDetailController *attachDetailController = [[AttachDetailController alloc] init];
    attachDetailController.filetype = selectAudioInfo.type;
    attachDetailController.filepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:selectAudioInfo.originName];
    attachDetailController.accessory = selectAudioInfo;
    [self.navigationController pushViewController:attachDetailController animated:YES];
}

//控制键盘弹出和隐藏
-(void)controlkeyboard:(id)sender
{
    if (self.keyboardHide) {
        [self.tvContent becomeFirstResponder];
    }
    else {
        [[self.view findFirstResponder] resignFirstResponder];//隐藏键盘
    }
}

//自动保存稿件
//标题为空时，也要求可以自动保存，标题默认加上<无标题>
-(void)autoSaveManuscript
{
    //1、对于“编辑”，则当前稿件的正文和标题属性是有值的，且初始情况下与视图的两个对应控件的值相同；
    //2、对于“新建”，则当前稿件的正文和标题属性在初始情况下没有值，但视图的两个对应控件有值。
    //由1和2可知，判断当前稿件的正文和标题属性与视图控件的值是否相同，可以判断出当前视图的标题和正文是否被修改且还未保存。
    //如果不相同，则需要保存当前稿件（保存的方法内部会区分是“新建”还是“编辑”）；否则不需要保存（因为稿件的附件和稿签属性会在修改时直接保存）
    if( (![self.mcripts.title isEqualToString:[Utility trimBlankSpace:self.titleField.text]])
       ||(![self.mcripts.contents isEqualToString:[Utility trimBlankSpace:self.tvContent.text]]))
    {
        
        if([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
        {
            self.mcripts.title=@"<无标题>";
        }
        NSString *message = [self saveManuscript];
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:message];
    }
}

-(void)sendManuScript:(id)sender
{
    //如果键盘处于打开状态，则关闭
    [self.titleField resignFirstResponder];//隐藏键盘
    [self.tvContent resignFirstResponder];
    
    if(![[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])//&&![[Utility trimBlankSpace:tvContent.text] isEqualToString:@""]
    {
        //异步加载等待对话框，完成发送前的准备工作后予以关闭
        [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
       
        //保存稿件到在编稿库
        [self saveManuscript];
        
        //检测网络是否可用、服务器地址是否可用、版本是否符合发稿要求，以及稿件的稿签是否符合要求
        NSString *serialCheck = [Utility serialCheckBeforeSendManu:self.mcripts];
        if( ![serialCheck isEqualToString:@""] )
        {
            [self hideWaiting];
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:serialCheck];
            return;
        }
        
        //保存临时稿签
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                     initForWritingWithMutableData:data];
        [archiver encodeObject:self.mcripts.mTemplate forKey:kTemporaryTemplateDataKey];
        [archiver finishEncoding];
        [data writeToFile:[Utility temporaryTemplateFilePath] atomically:YES];
        
        //拆分稿件
        NSMutableArray *manuArray = [Utility prepareToSendManuscript:self.mcripts accessories:self.accessoriesArry userInfoFromServer:[Utility sharedSingleton].userInfo];
        
        //轮询发送已拆分稿件
        for(int i = 0;i<[manuArray count];i++)
        {
            if ([self.accessoriesArry count]>0) {
                [Utility xmlPackage:[manuArray objectAtIndex:i] accessories:[self.accessoriesArry objectAtIndex:i]];
            }
            else {
                [Utility xmlPackage:[manuArray objectAtIndex:i] accessories:nil];
            }
        }
        
        if( [manuArray count]>0 ){
            [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"请到待发稿件中查看发送进程"];
        }
        //返回上级页面
        [self.timer invalidate];
        [self hideWaiting];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                              animated:YES];
    }
    else {
        [self hideWaiting];
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"标题不能为空"];
    }
    
}

//删除附件
-(void)deleteAttachment:(UIButton*)sender
{
    self.selectAccessoryIndex = [sender tag];
    self.selectAccessorySender = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确认删除该附件吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定删除",nil];
    [alert show];
}

- (void)saveAttachmentToDocument:(NSDictionary *)filedic
{
    //保存图片
    if ([[filedic objectForKey:@"filename"] isEqualToString:IMG_TYPE] )
    {
        [[filedic objectForKey:@"content"] writeToFile:[filedic objectForKey:@"savefilepath"] atomically:YES];
        [self addAttach:[filedic objectForKey:@"savefilepath"]
                   type:FileNameTagsPhoto
             originName:[filedic objectForKey:@"OriginName"]
              imageInfo:[filedic objectForKey:@"ImageInfo"]];
        
    }
    
    //保存视频
    if ([[filedic objectForKey:@"filename"] isEqualToString:MOV_TYPE]){
        
        [[filedic objectForKey:@"content"] writeToFile:[filedic objectForKey:@"savefilepath"] atomically:YES];
        [self addAttach:[filedic objectForKey:@"savefilepath"]
                   type:FileNameTagsVideo
             originName:[filedic
                         objectForKey:@"OriginName"]
              imageInfo:@""];
    }
    
    //保存音频  (音频在录制音频的类里面已经保存)
    if ([[filedic objectForKey:@"filename"] isEqualToString:VOC_TYPE])
    {
        if (! [[filedic objectForKey:@"content"] writeToFile:[filedic objectForKey:@"savefilepath"] atomically:YES]) {
            return;
        }
        else
        {
            [self addAttach:[filedic objectForKey:@"savefilepath"]
                       type:FileNameTagsAudio
                 originName:[filedic objectForKey:@"OriginName"]
                  imageInfo:@""];
        }
        
        
    }
    [self hideWaiting];
}

#pragma mark - PBJVisionDelegate
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
    
    [self hideWaiting];
    [self.pbvision stopPreview];
    self.pbvision.delegate = nil;

    if (!error) {
        // NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    [self addAttach:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:self.currentVideoPath]
               type:FileNameTagsVideo
         originName:self.currentVideoPath
          imageInfo:@""];
    
    NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",
                              [FILE_PATH_IN_PHONE stringByAppendingPathComponent:self.currentVideoPath],
                              @"savefilepath",MOV_TYPE,@"filename",nil];
    
    [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];

}

#pragma mark - IFlyRecognizeControlDelegate
//	识别结束回调
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {

    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    self.tvContent.text = [NSString stringWithFormat:@"%@%@",self.tvContent.text,result];
}

- (void)onError:(IFlySpeechError *)error {
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    NSLog(@"%@",error.errorDesc);
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    [self enableButton];
}


#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    if (newLocation!=nil) {
        [self.locationManager stopUpdatingLocation];
        NSString *latitudeStr=[[NSString alloc] initWithFormat:@"%f",newLocation.coordinate.latitude];
        NSString *longitudeStr=[[NSString alloc] initWithFormat:@"%f",newLocation.coordinate.longitude];
        
        self.mcripts.location = [NSString stringWithFormat:@"%@,%@",latitudeStr,longitudeStr];
        
        [self saveManuscript];
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:self.mcripts.location];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"当前定位不可用！"];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        int index = (int)self.selectAccessoryIndex;
        [self.selectAccessorySender.superview removeFromSuperview];
        [self.gridArray removeObjectAtIndex:index];
        //删除物理文件
        Accessories *accessory = [self.accessoriesArry objectAtIndex:index];
        if (![[NSFileManager defaultManager] removeItemAtPath:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessory.originName] error:nil])
        {
            NSLog(@"%@",@"删除成功");
        }
        //删除数据库
        [self.accessoriesdb deleteAccessoriesByID:accessory.a_id];
        
        //从AccessoryArray中删除
        [self.accessoriesArry  removeObjectAtIndex:index];
        
        //调整删除后剩余grid的位置
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        for (int i=index; i<[self.gridArray count]; i++) {
            
            NSUInteger row = i / 3;
            NSUInteger column = i % 3;
            CGRect newGridFrame = CGRectMake(10+column*kButtonWidth+column*7, self.scrollView1.frame.size.height+row*kButtonHeight+row*7-100, kButtonWidth,kButtonHeight);
            VideoGrid *grid = [self.gridArray objectAtIndex:i];
            grid.btnDelete.tag = i;
            grid.btnPic.tag = i;
            grid.frame = newGridFrame;
        }
        [UIView commitAnimations];
    }

}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
            //用户拍摄
        case 0:
        {
            self.isCamera = TRUE;
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
                [imagePicker setAllowsEditing:NO];
                imagePicker.delegate = self;
                [self presentViewController:imagePicker animated:YES completion:nil];
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
        case 1:
        {
            self.isCamera = TRUE;
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                [self.view addSubview:self.startBtn];
                [self.view addSubview:self.cancelCaptureBtn];
                [self.view addSubview:self.videoTimeLb];
                [self.view addSubview:self.previewVideo];
                [self.view bringSubviewToFront:self.startBtn];
                [self.view bringSubviewToFront:self.cancelCaptureBtn];
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
            //用户相册
        case 2:
        {
            self.isCamera = FALSE;
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                [imagePicker setAllowsEditing:NO];
                imagePicker.delegate = self;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                             message:@"摄像头不可用"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
                [alert show];
            }
            break;
            
        }
            //录音
        case 3:
        {
            RecordVoiceController *rvController = [[RecordVoiceController alloc] init];
            [self.navigationController pushViewController:rvController animated:YES];
            rvController.delegate = self;
            break;
        }
        default:
            break;
    }

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.dateFormat = @"ddMMYY_hhmmsss";
    //switch action by type
    if ([mediaType isEqualToString:@"public.image"])
    {
        [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *metaDic = [info objectForKey:UIImagePickerControllerMediaMetadata];
        //获取图片的长、宽、分辨率
        NSString *height = [NSString stringWithFormat:@"%d",(int)roundf(image.size.height)];
        NSString *width = [NSString stringWithFormat:@"%d",(int)roundf(image.size.width)];
        NSString *infoTemp = [NSString stringWithFormat:@"Width=%@,Height=%@",width,height];
        NSData *imageData = UIImageJPEGRepresentation(image,1);
        NSString *originName = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],IMG_TYPE];//文件名称
        NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:originName];//保存路径
        //写到数组
        NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:originName,@"name",savefilepath,@"savefilepath",nil];
        [self.imageArray insertObject:row1 atIndex:[self.imageArray count]];
        
        //保存文件
        NSDictionary *filedic = [[NSDictionary alloc] initWithObjectsAndKeys:imageData,@"content",savefilepath,@"savefilepath",IMG_TYPE,@"filename", originName,@"OriginName",infoTemp,@"ImageInfo",metaDic,@"metaDic",nil];
        
        [NSThread detachNewThreadSelector:@selector(saveAttachmentToDocument:) toTarget:self withObject:filedic];
        
        //保存到媒体库
        if (self.isCamera) {
            NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:image,@"content",savefilepath,@"savefilepath",IMG_TYPE,@"filename",nil];
            [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
        }
        
        picker.delegate=nil;
     
    }
    else if([mediaType isEqualToString:@"public.movie"])
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSURL *videoURL=[info objectForKey:UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        ;
        //保存路径
        NSString *originName = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],MOV_TYPE];//文件名称
        NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:originName];//保存路径
        [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
        
        NSString *compress = [USERDEFAULTS objectForKey:COMPRESS];
        
        //视频压缩
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        AVAssetExportSession *exportSession;
        if ([compress isEqual:@"高"])
        {
            //保存文件
            NSDictionary *filedic=[[NSDictionary alloc] initWithObjectsAndKeys:videoData,@"content",savefilepath,@"savefilepath",MOV_TYPE,@"filename",originName,@"OriginName",nil];
            [NSThread detachNewThreadSelector:@selector(saveAttachmentToDocument:) toTarget:self withObject:filedic];
            if (self.isCamera) {
                NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",[videoURL path],@"savefilepath",MOV_TYPE,@"filename",nil];
  
                [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
            }
    
            picker.delegate=nil;
  
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
                    
                    [self addAttach:savefilepath type:FileNameTagsVideo originName:originName imageInfo:@""];
                    if (self.isCamera) {
                        NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"content",[videoURL path],@"savefilepath",MOV_TYPE,@"filename",nil];
 
                        [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
                    }
                    [self hideWaiting];
                    
                    break;
                default:
                    break;
            }

        }];
        
    }
    
    picker.delegate = nil;

}


#pragma mark - UITestFiedDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyDefault;
    [self.tvContent becomeFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyDone;
    return YES;
}

-(void)textFieldDoneEditing:(id)sender
{
    [self.tvContent becomeFirstResponder];
}









@end
