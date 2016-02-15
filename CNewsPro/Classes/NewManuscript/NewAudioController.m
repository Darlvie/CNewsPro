//
//  NewAudioController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewAudioController.h"
#import "Manuscripts.h"
#import "ManuscriptsDB.h"
#import "Accessories.h"
#import "AccessoriesDB.h"
#import "ManuscriptTemplate.h"
#import "ManuscriptTemplateDB.h"
#import "VideoGrid.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "NewTagDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "RecordVoiceController.h"
#import <AVFoundation/AVFoundation.h>
#import "AttachDetailController.h"

@interface NewAudioController () <CLLocationManagerDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UILabel *static_title;
@property (strong, nonatomic) UITextView *titleField;
@property (strong, nonatomic) UIScrollView *audioListScrollView;
@property (strong, nonatomic) Manuscripts *mcripts;
@property (strong, nonatomic) ManuscriptsDB *manuscriptsdb;
@property (strong, nonatomic) AccessoriesDB *accessoriesdb;
@property (copy, nonatomic) NSMutableArray *audioInfoArray;
@property (copy, nonatomic) NSMutableArray *gridArray;
@property (strong, nonatomic) VideoGrid *audioGrid;
@property (nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,assign) NSInteger selectAccessoryIndex;
@property (nonatomic,strong) UIButton *selectAccessorySender;
@end

@implementation NewAudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.static_title = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+5.0, 52, 21)];
    self.static_title.font = [UIFont systemFontOfSize:16];
    self.static_title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.static_title];
    
    self.titleField = [[UITextView alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView-55, 30)];
    self.titleField.font = [UIFont systemFontOfSize:14];
    self.titleField.textAlignment = NSTextAlignmentLeft;
    self.titleField.returnKeyType = UIReturnKeyDone;
    //titleField.delegate = self;
    [self.view addSubview:self.titleField];
    
    self.audioListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 85, 300, self.view.frame.size.height-170)];
    self.audioListScrollView.userInteractionEnabled = YES;
    self.audioListScrollView.multipleTouchEnabled = YES;
    [self.view addSubview:self.audioListScrollView];
    
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
    topLine.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:topLine];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-80+10, 300, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:174.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    [self.view addSubview:bottomLine];
    
    [self initializeController];
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
    self.audioInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //获得默认稿签模板
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    self.mcripts.mTemplate = [mdb getDefaultManuscriptTemplate:AUDIO_EXPRESS_TEMPLATE_TYPE loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    self.titleField.text = self.mcripts.mTemplate.defaultTitle;
    
    //页面第一次进入时，将传入的稿件id保存在缓存中。如果是“新建稿件”，则为@“”。
    [USERDEFAULTS setObject:self.manuscript_id forKey:CURRENT_MANUSCRIPTID_SESSIONId];
    
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"express_audio"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"音频快讯" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    
    //添加发送按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"express_send.png"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(sendExpress:) forControlEvents:UIControlEventTouchUpInside];
    
    //zyq 国际化
    self.static_title.text = @"标题";
    
    //表格视图
    self.gridArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *image =[UIImage imageNamed:@"express_audioBtnGray"];
    self.audioGrid = [[VideoGrid alloc] initWithFrame:CGRectMake(30, 20, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.audioGrid.btnDelete.hidden = YES;
    [self.audioGrid.btnPic setImage:image forState:UIControlStateNormal];
    [self.audioGrid.btnPic addTarget:self action:@selector(btnAddClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.audioListScrollView addSubview:self.audioGrid];
    [self.gridArray addObject:self.audioGrid];
    
    //定时器初始化
    int autoSaveTime = 0;
    if([USERDEFAULTS objectForKey:AUTO_SAVE_TIME])
    {
        autoSaveTime = [[USERDEFAULTS objectForKey:AUTO_SAVE_TIME] intValue];
    }
    if( autoSaveTime > 0 )
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:autoSaveTime target:self selector:@selector(autoSaveManuscript) userInfo:nil repeats:YES];
    }
}

- (void)returnToParentView:(id)sender
{
    //    用户点击“返回”图标时，首先判断当前稿件是否已经存在，即是新的稿件还是已保存的稿件。
    //    （1）如果是新稿件：判断标题、正文、附件是否为空：
    //      （1.1）全部为空，则直接返回；（这是对于用户点击新建稿件或快讯后没有进行任何操作，直接返回的情况）
    //      （1.2）标题为空，则提示用户输入标题；
    //      （1.3）标题不为空，则保存该稿件并返回。
    //    （2）如果是已有稿件：判断标题、正文、附件是否为空：
    //      //（2.1）全部为空，则删除当前稿件；
    //      （2.1）标题为空，则提示用户输入标题；
    //      （2.2）标题不为空，则更新该稿件并返回。
    
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])//新稿件
    {
        if (([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.titleField.text] isEqualToString:self.mcripts.mTemplate.defaultTitle])&&(self.audioInfoArray.count == 0))
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

- (void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
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
    //mcripts = [manuscriptsdb GetManuScriptById:manuscriptId];
    self.mcripts.title = [Utility trimBlankSpace:self.titleField.text];
    if ([self.manuscriptsdb updateManuscript:self.mcripts]) {
        return @"更新稿件成功";
    }
    else {
        return @"更新稿件失败";
    }
}

//保存稿件。不负责保存稿件的附件信息。附件信息在添加和删除附件时完成。
- (NSString *)saveManuscript
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

//自动保存稿件
- (void)autoSaveManuscript
{
    if( (![self.mcripts.title isEqualToString:[Utility trimBlankSpace:self.titleField.text]]))
    {
        if(![[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""])
            [self saveManuscript];
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
    
    //将稿件信息保存并根据附件个数进行拆条
    NSMutableArray *manuArray = [Utility prepareToSendManuscript:self.mcripts accessories:self.audioInfoArray userInfoFromServer:[Utility sharedSingleton].userInfo];
    
    for(int i = 0;i<[manuArray count];i++)
    {
        [Utility xmlPackage:[manuArray objectAtIndex:i] accessories:[self.audioInfoArray objectAtIndex:i]];
    }
    
    if( [manuArray count]>0 ){
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"请到待发稿件中查看发送进程"];
    }
    
    //返回上级页面
    [self.timer invalidate];
    [self hideWaiting];
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)addVoice:(AVAudioRecorder *)recorder
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmss";
    NSString *str = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],VOC_TYPE];//文件名称：当前时间＋.aif
    NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:str];
    
    //保存到本地数组
    //NSDictionary *row1=[[NSDictionary alloc] initWithObjectsAndKeys:str,@"name",savefilepath,@"savefilepath",nil];
    NSData *movdata= [NSData dataWithContentsOfURL:recorder.url];
    
    [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    
    //线程中，拷贝文件，更新数据库，刷新视图
    NSDictionary *filedic = [[NSDictionary alloc] initWithObjectsAndKeys:movdata,@"content",savefilepath,@"savefilepath",VOC_TYPE,@"filename", str,@"OriginName",nil];
    [NSThread detachNewThreadSelector:@selector(newThreadTask:) toTarget:self withObject:filedic];
    
    if (![[NSFileManager defaultManager] removeItemAtPath:[recorder.url path] error:nil])
    {
        
    }
}

-(void)addAttach:(NSString *)url type:(NSInteger)type originName:(NSString *)originName{
    
    Accessories *newAudioInfo = [[Accessories alloc] init];
    
    //保存到数据库
    switch (type) {
        case FileNameTagsPhoto:
        {
            newAudioInfo.type = @"PHOTO";
            break;
        }
        case FileNameTagsAudio:
        {
            newAudioInfo.type = @"AUDIO";
            break;
        }
        case FileNameTagsVideo:
        {
            newAudioInfo.type = @"VIDEO";
            break;
        }
            
        default:
            break;
    }
    
    newAudioInfo.createTime = [Utility getNowDateTime];
    newAudioInfo.info = @"音频";
    
    NSInteger fileLength = [Utility getFileLengthByPath:url];
    newAudioInfo.size = [NSString stringWithFormat:@"%ld",fileLength];
    newAudioInfo.originName = originName;
    
    //依据缓存中的稿件稿件Id值，判断稿件是否已经保存。
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])
    {
        //说明该附件对应的稿件未保存，需要先保存稿件，然后根据稿件的m_id来添加附件
        [self saveManuscript];
        currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    }
    newAudioInfo.m_id = currentManuscriptId;
    //插入一条附件记录
    newAudioInfo.a_id = [Utility stringWithUUID];
    if(![self.accessoriesdb addAccessories:newAudioInfo])
        NSLog(@"附件插入失败%@",newAudioInfo.a_id);
    
    [self.audioInfoArray insertObject:newAudioInfo atIndex:[self.audioInfoArray count]];
}

-(void)addGridView:(NSString *)videoUrl
{
    UIImage *image =[UIImage imageNamed:@"express_audioBtn"];
    
    //添加新Grid，替换add按钮的位置
    VideoGrid *newGrid = [[VideoGrid alloc] initWithFrame:self.audioGrid.frame];
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
    [self.audioListScrollView addSubview:newGrid];
    
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
    self.audioListScrollView.contentSize = CGSizeMake(300, (BUTTON_HEIGHT+20)*(row+2)+20);
    
    //处理动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    newGrid.alpha = 1.0f;
    self.audioGrid.frame = newAddGridFrame;
    [UIView commitAnimations];
    
    //将add按钮滚动到可见位置
    [self.audioListScrollView scrollRectToVisible:newAddGridFrame animated:YES];
    
}


#pragma mark - Action Method
- (void)showTemplateView:(id)sender
{
    NewTagDetailViewController *tagController = [[NewTagDetailViewController alloc] init];
    tagController.manuscriptTemplate = self.mcripts.mTemplate;
    tagController.templateType = TemplateTypeEditAble;
    tagController.delegate = self;
    [self.navigationController pushViewController:tagController animated:YES];
}

- (void)attachLocationInfo:(id)sender
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

- (void)saveExpress:(id)sender
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

- (void)sendExpress:(id)sender
{
    //如果键盘处于打开状态，则关闭
    [self.titleField resignFirstResponder];//隐藏键盘
    
    if ([self.audioInfoArray count]>0) {
        
        [self sendManuscript];
        
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"无音频，系统拒绝发送"];
    }
}

//添加附件
- (void)btnAddClick:(id)sender
{
    RecordVoiceController *rvController = [[RecordVoiceController alloc] init];
    [self.navigationController pushViewController:rvController animated:YES];
    rvController.delegate = self;
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

-(void)newThreadTask:(NSDictionary *)filedic
{
    //保存文件
    [[filedic objectForKey:@"content"] writeToFile:[filedic objectForKey:@"savefilepath"] atomically:YES];
    
    //更新数据库
    [self addAttach:[filedic objectForKey:@"savefilepath"] type:FileNameTagsAudio originName:[filedic objectForKey:@"OriginName"]];
    
    //更新视图
    [self addGridView:[filedic objectForKey:@"savefilepath"]];
    
    [NSThread sleepForTimeInterval:1];//延时释放变量
    [self hideWaiting];
}

//稿件详情页
- (void)showDetailAttachment:(id)sender
{
    Accessories *selectAudioInfo = [self.audioInfoArray objectAtIndex:[sender tag]];
    AttachDetailController *attachDetailController = [[AttachDetailController alloc] init];
    attachDetailController.filetype = selectAudioInfo.type;
    attachDetailController.filepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:selectAudioInfo.originName];
    attachDetailController.accessory = selectAudioInfo;
    [self.navigationController pushViewController:attachDetailController animated:YES];
}

- (void)deleteGrid:(UIButton *)sender {
    self.selectAccessoryIndex = [sender tag];
    self.selectAccessorySender = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确认删除该附件吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定删除",nil];
    [alert show];
}


#pragma mark CLLocationManager delegate
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        //删除
        NSInteger index = self.selectAccessoryIndex;

        [self.selectAccessorySender.superview removeFromSuperview];
        [self.gridArray removeObjectAtIndex:index];
        Accessories *delAudioInfo=[self.audioInfoArray objectAtIndex:index];
        
        //删除物理文件
        if (![[NSFileManager defaultManager] removeItemAtPath:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:delAudioInfo.originName] error:nil])
        {
            NSLog(@"%@",@"视频物理文件删除成功");
        }
        //删除数据库
        [self.accessoriesdb deleteAccessoriesByID:delAudioInfo.a_id];
        
        //从AccessoryArray中删除
        [self.audioInfoArray  removeObjectAtIndex:index];
        
        //更新视图
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        for (NSInteger i=index; i<[self.gridArray count]; i++) {
            
            NSUInteger row = i / 2;
            NSUInteger column = i % 2;
            CGRect newGridFrame = CGRectMake(30+column*BUTTON_WIDTH+column*40,
                                             20+row*BUTTON_HEIGHT+row*20,
                                             BUTTON_WIDTH,
                                             BUTTON_HEIGHT);
            VideoGrid *grid = [self.gridArray objectAtIndex:i];
            grid.btnDelete.tag = i;
            grid.btnPic.tag = i;
            grid.frame = newGridFrame;
        }
        [UIView commitAnimations];
        
        //根据内容大小设置contentsize
        int rowCount = ceil((float)[self.gridArray count]/2.0f);
        self.audioListScrollView.contentSize = CGSizeMake(300, (BUTTON_HEIGHT+20)*rowCount+20);
        
    }

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}




@end
