//
//  NewImageController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewImageController.h"
#import "Manuscripts.h"
#import "ManuscriptsDB.h"
#import "AccessoriesDB.h"
#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"
#import "VideoGrid.h"
#import "Accessories.h"
#import "NewTagDetailViewController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import <CoreLocation/CoreLocation.h>
#import "AttachDetailController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FixedToolbar.h"
#import "NewArticlesToolbarDelegate.h"

@interface NewImageController () <UIActionSheetDelegate,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewArticlesToolbarDelegate>

@property (strong,nonatomic) UITextField *titleField;
@property (strong,nonatomic) UILabel *static_title;
@property (strong,nonatomic) Manuscripts *mcripts;
@property (strong,nonatomic) ManuscriptsDB *manuscriptsdb;
@property (strong,nonatomic) AccessoriesDB *accessoriesdb;
@property (strong,nonatomic) NSMutableArray *accessoriesArry;
@property (strong,nonatomic) UIScrollView *imageListScrollView;
@property (strong,nonatomic) NSMutableArray *gridArray;
@property (strong,nonatomic) VideoGrid *imageGrid;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSMutableArray *audioInfoArray;
@property (nonatomic,assign) NSInteger selectAccessoryIndex;
@property (nonatomic,strong) UIButton *selectAccessorySender;
@property (nonatomic,assign) BOOL isCamera;
@property (nonatomic,strong) FixedToolbar *toolbar;
@property (nonatomic,copy) NSString *locationStr;

@end

@implementation NewImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpToolbar];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)setUpToolbar {
    self.toolbar = [FixedToolbar  fixedToolbar];
    NSMutableArray *subItems = [self.toolbar.items mutableCopy];
    NSRange range = NSMakeRange(0, 2);
    [subItems removeObjectsInRange:range];
    [self.toolbar setItems:subItems];
    self.toolbar.frame = CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH, 49);
    self.toolbar.toobarDelegate = self;
    [self.view addSubview:self.toolbar];
}

- (void)returnToParentView:(UIButton *)button {
    //获取稿件id
    NSString *currentManuscriptId = [USERDEFAULTS objectForKey:CURRENT_MANUSCRIPTID_SESSIONId];
    if([currentManuscriptId isEqualToString:@""])//新稿件
    {
        if (([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]||[[Utility trimBlankSpace:self.titleField.text] isEqualToString:self.mcripts.mTemplate.defaultTitle])&&(self.accessoriesArry.count == 0))
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
    [self.navigationController popViewControllerAnimated:TRUE];

}

//页面初始化
-(void)initializeController
{
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView-55, 30)];
    self.titleField.font = [UIFont systemFontOfSize:14];
    self.titleField.textAlignment = NSTextAlignmentLeft;
    self.titleField.returnKeyType = UIReturnKeyDone;
    self.titleField.delegate = self;
    [self.view addSubview:self.titleField];
    
    self.static_title = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+5.0, 52, 21)];
    self.static_title.font = [UIFont systemFontOfSize:16];
    self.static_title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.static_title];
    
    
    //调用数据库函数
    self.manuscriptsdb = [[ManuscriptsDB alloc] init];
    self.accessoriesdb = [[AccessoriesDB alloc] init];
    
    //初始化数据实体对象.此处为对象属性，在本类中各个方法中都能访问。
    self.mcripts=[[Manuscripts alloc] init];
    self.accessoriesArry=[[NSMutableArray alloc] initWithCapacity:0];
    
    //判断其他视图进入本视图时是否传入了稿件id，即区分“新建”还是“编辑”
    if(![self.manuscript_id isEqualToString:@""])
    {
        //获取稿件信息
        self.mcripts = [self.manuscriptsdb getManuscriptById:self.manuscript_id];
        //绑定标题
        self.titleField.text = self.mcripts.title;
        
        //获取附件信息，并存入附件列表
        self.accessoriesArry = [self.accessoriesdb getAccessoriesListByMId:self.manuscript_id];
        //绑定附件列表
        for (int i = 0; i<[self.accessoriesArry count]; i++) {
            [self renderAccessoriesView:[self.accessoriesArry objectAtIndex:i]];
        }
    }
    else {
        //获得默认稿签模板
        ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
        self.mcripts.mTemplate = [mdb getDefaultManuscriptTemplate:PICTURE_EXPRESS_TEMPLATE_TYPE loginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
        self.titleField.text = self.mcripts.mTemplate.defaultTitle;
    }
    
    //页面第一次进入时，将传入的稿件id保存在缓存中。如果是“新建稿件”，则为@“”。
    [USERDEFAULTS setObject:self.manuscript_id forKey:CURRENT_MANUSCRIPTID_SESSIONId];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"express_photo"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"图片快讯" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = RGB(60, 90, 154);
    
    //添加发送按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"express_send.png"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(sendExpress:) forControlEvents:UIControlEventTouchUpInside];
    
    //zyq 国际化
    self.static_title.text = @"标题";
    [self.static_title setTextColor:[UIColor lightGrayColor]];
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(10,  CGRectGetMaxY(self.static_title.frame)+5.0, self.widthOfMainView-20.0, 1)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topLine];
    
    //表格视图
    self.imageListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(topLine.frame)+44, self.widthOfMainView-20, self.heightOfMainView-34.0-70)];
    self.imageListScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageListScrollView];
    
    self.gridArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIImage *image =[UIImage imageNamed:@"express_photoBtnGray"];
    self.imageGrid = [[VideoGrid alloc] initWithFrame:CGRectMake(30, 20, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.imageGrid.btnDelete.hidden = YES;
    [self.imageGrid.btnPic setImage:image forState:UIControlStateNormal];
    [self.imageGrid.btnPic addTarget:self action:@selector(actionSheetAddImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageListScrollView addSubview:self.imageGrid];
    [self.gridArray addObject:self.imageGrid];
    
    //定时器初始化
    int autoSaveTime = 0;
    if([USERDEFAULTS objectForKey:AUTO_SAVE_TIME])
    {
        autoSaveTime = [[USERDEFAULTS objectForKey:AUTO_SAVE_TIME] intValue];
    }
    if(autoSaveTime > 0 )
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:autoSaveTime target:self selector:@selector(autoSaveManuscript) userInfo:nil repeats:YES];
    }
    
    
    UIView *templeView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabelAndImage.frame)+35.0, SCREEN_WIDTH - 22, 44)];
    [self.view addSubview:templeView];
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, templeView.bounds.size.height)];
    [infoButton setImage:[UIImage imageNamed:@"quill_with_ink"] forState:UIControlStateNormal];
    
    [infoButton setTitle:@"编辑稿签" forState:UIControlStateNormal];
    [infoButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [infoButton setTitleColor:RGB(60, 90, 154) forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(showTemplateView:) forControlEvents:UIControlEventTouchUpInside];
    [templeView addSubview:infoButton];
    
    UIButton *showTemple = [[UIButton alloc] initWithFrame:CGRectMake(templeView.bounds.size.width - 50, 0,50, templeView.bounds.size.height)];
    [showTemple setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [showTemple addTarget:self action:@selector(showTemplateView:) forControlEvents:UIControlEventTouchUpInside];
    [templeView addSubview:showTemple];

}

- (void)initializeLocationService {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Private
//添加和绑定已有附件时，更新视图显示
- (void)renderAccessoriesView:(Accessories *)accessory
{
    UIImage *image =[UIImage imageNamed:@"bigpicholder.png"];
    if([accessory.type isEqualToString:@"PHOTO"])
    {
        image = [UIImage imageWithContentsOfFile:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessory.originName]];
    }
    
    //添加新Grid，替换add按钮的位置
    VideoGrid *newGrid = [[VideoGrid alloc] initWithFrame:self.imageGrid.frame];
    newGrid.alpha = 0.0f;
    //设置截图
    newGrid.btnPic.tag = [self.gridArray count] - 1;
    [newGrid.btnPic setImage:image forState:UIControlStateNormal];
    [newGrid.btnPic addTarget:self action:@selector(showDetailAttachment:) forControlEvents:UIControlEventTouchUpInside];
    //添加事件，记录tag值（index）
    newGrid.btnDelete.tag = [self.gridArray count] - 1;
    [newGrid.btnDelete addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    newGrid.alpha = 1.0f;
    //插入队列
    [self.gridArray insertObject:newGrid atIndex:[self.gridArray count]-1];
    [self.imageListScrollView addSubview:newGrid];
    
    //add按钮移动
    NSUInteger add_grid_index = [self.gridArray count] - 1;
    //计算add按钮的新位置
    NSUInteger row = add_grid_index / 2;
    NSUInteger column = add_grid_index % 2;
    CGRect newAddGridFrame = CGRectMake(30+column*BUTTON_WIDTH+column*40,
                                        20+row*BUTTON_HEIGHT+row*20,
                                        BUTTON_WIDTH,
                                        BUTTON_HEIGHT);
    
    self.imageListScrollView.contentSize = CGSizeMake(290, (BUTTON_HEIGHT+20)*(row+2)+100);//modify by liuwei
    
    //处理动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    
    self.imageGrid.frame = newAddGridFrame;
    [UIView commitAnimations];
    
    //将add按钮滚动到可见位置
    [self.imageListScrollView scrollRectToVisible:newAddGridFrame animated:NO];
}

- (void)sendManuScript
{
    
    if ([[Utility trimBlankSpace:self.titleField.text] isEqualToString:@""]) {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"标题不能为空"];
        return;
    }
    //异步加载等待对话框，完成发送前的准备工作后予以关闭
//    [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    [self showWait];

    
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
    NSMutableArray *manuArray = [Utility prepareToSendManuscript:self.mcripts
                                                     accessories:self.accessoriesArry
                                              userInfoFromServer:[Utility sharedSingleton].userInfo];
    
    for(int i = 0;i<[manuArray count];i++)
    {
        [Utility xmlPackage:[manuArray objectAtIndex:i] accessories:[self.accessoriesArry objectAtIndex:i]];
    }
    
    if( [manuArray count]>0 ){
        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"请到待发稿件中查看发送进程"];
    }
    
    //返回上级页面
    [self.timer invalidate];
    [self hideWaiting];
    [self.navigationController popViewControllerAnimated:TRUE];
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

//第一次保存，即插入一条新的稿件
- (NSString*)insertNewManuscript:(NSString*)manuscriptId
{
    self.mcripts.m_id = manuscriptId;//必填。
    if([self.mcripts.mTemplate.loginName isEqualToString:@""])
    {
        self.mcripts.mTemplate.loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    }
    if([self.mcripts.mTemplate.loginName isEqualToString:@""] )
    {
        return @"当前登录名为空，未保存";
    }
    self.mcripts.title=[Utility trimBlankSpace:self.titleField.text];
    
    self.mcripts.manuscriptsStatus = MANUSCRIPT_STATUS_EDITING;   //稿件状态。必填。
    //zyq,12/10,添加地理位置信息
    if (self.locationStr.length > 0) {
        self.mcripts.location = self.locationStr;
    } else {
        self.mcripts.location = @"0.0,0.0"; //定位信息
    }
    
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
        return @"更新稿件成功";
    }
    else {
        return @"更新稿件失败";
    }
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

- (void)sendExpress:(id)sender
{
    //如果键盘处于打开状态，则关闭
    [self.titleField resignFirstResponder];//隐藏键盘
    
    if ([self.accessoriesArry count]>0) {
        [self sendManuScript];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"无图片，系统拒绝发送"];
    }
}

//添加附件
- (void)actionSheetAddImage:(id)sender
{
    UIActionSheet *actSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍摄照片",@"媒体库",nil];
    actSheet.delegate = self;
    [actSheet showInView:self.view];
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

-(void)attachLocationInfo:(id)sender
{
    //检测网络状况，如果未连接网络，不发送。
    if (![Utility testConnection] ) {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"当前网络不可用，请稍后再试!"];
    }
    else {
        if ([CLLocationManager locationServicesEnabled]) {
            [self initializeLocationService];
        } else {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"请开启定位功能"];
        }
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

//稿件附件详情页
- (void)showDetailAttachment:(id)sender
{
    Accessories *selectaccessories = [self.accessoriesArry objectAtIndex:[sender tag]];
    AttachDetailController *attachDetailController=[[AttachDetailController alloc] init];
    attachDetailController.filetype = selectaccessories.type;
    attachDetailController.filepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:selectaccessories.originName];
    attachDetailController.accessory = selectaccessories;
    [self.navigationController pushViewController:attachDetailController animated:YES];
}

//删除单个图片
-(void)deleteImage:(UIButton*)sender
{
    self.selectAccessoryIndex = [sender tag];
    self.selectAccessorySender = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确认删除该附件吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定删除", nil];
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
    
    [NSThread sleepForTimeInterval:0.1];//延时释放变量
}

//更新附件列表。包括：1）判断附件类型；2）将附件存入数据库；3）更新视图显示
-(void)addAttach:(NSString *)url type:(NSInteger)type originName:(NSString *)originName imageInfo:(NSString *)imageInfo
{
    Accessories *accessory=[[Accessories alloc] init];
    //保存到数据库
    switch (type) {
        case FileNameTagsPhoto:
        {
            accessory.type = @"PHOTO";
            break;
        }
        case FileNameTagsAudio:
        {
            accessory.type = @"AUDIO";
            break;
        }
        case FileNameTagsVideo:
        {
            accessory.type = @"VIDEO";
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
    
    accessory.createTime = [Utility getNowDateTime];
    
    NSInteger fileLength = [Utility getFileLengthByPath:url];
    accessory.size=[NSString stringWithFormat:@"%ld",fileLength];
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
    
}

#pragma mark CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
    if (locations.count > 0) {
        CLLocation *location = [locations firstObject];
        if (location) {
            NSString *latitudeStr = [[NSString alloc] initWithFormat:@"%f",location.coordinate.latitude];
            NSString *longitudeStr = [[NSString alloc] initWithFormat:@"%f",location.coordinate.longitude];
            
            self.locationStr = [NSString stringWithFormat:@"%@,%@",latitudeStr,longitudeStr];
            [self saveManuscript];
            
            [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:self.mcripts.location];
        }
    }
    
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"定位失败"];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    switch (buttonIndex) {
            //用户拍摄
        case 0:
        {
            [self captureImageWithCamrea];
           break;
        }
            //用户相册
        case 1:
        {
            [self pickerImageFromMediaLibrary];
            break;
            
        }
        default:
            break;
    }
    
}

- (void)captureImageWithCamrea {
    self.isCamera=TRUE;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
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
                                           cancelButtonTitle:@"确认"
                                           otherButtonTitles:nil];
        [alert show];
        
    }

}

- (void)pickerImageFromMediaLibrary {
    self.isCamera=false;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
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

}

#pragma mark  imagePickerController
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.dateFormat = @"ddMMYY_hhmmsss";
    
    //switch action by type
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        ///
        //获取图片的长、宽、分辨率
        NSString *height = [NSString stringWithFormat:@"%d",(int)roundf(image.size.height)];
        NSString *width = [NSString stringWithFormat:@"%d",(int)roundf(image.size.width)];
        NSString *infoTemp = [NSString stringWithFormat:@"Width=%@,Height=%@",width,height];
        
        NSData *imageData = UIImageJPEGRepresentation(image,1);
        NSString *originName = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],IMG_TYPE];//文件名称
        NSString *savefilepath = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:originName];//保存路径
        
        //保存文件
        NSDictionary *filedic=[[NSDictionary alloc] initWithObjectsAndKeys:imageData,@"content",savefilepath,@"savefilepath",IMG_TYPE,@"filename", originName,@"OriginName",infoTemp,@"ImageInfo",nil];
        [NSThread detachNewThreadSelector:@selector(saveAttachmentToDocument:) toTarget:self withObject:filedic];
        //保存到媒体库
        if (self.isCamera) {
            NSDictionary *albumsave = [[NSDictionary alloc] initWithObjectsAndKeys:image,@"content",savefilepath,@"savefilepath",IMG_TYPE,@"filename",nil];
            [NSThread detachNewThreadSelector:@selector(albumThreadTask:) toTarget:self withObject:albumsave];
        }
        
        //
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
    picker.delegate = nil;
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
        
        //更新视图
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        for (int i=index; i<[self.gridArray count]; i++) {
            
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
        self.imageListScrollView.contentSize = CGSizeMake(300, (BUTTON_HEIGHT+20)*rowCount+20);
    }

}


#pragma mark - NewTagDetailViewController返回调用
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.titleField resignFirstResponder];
    return YES;
}

#pragma mark - NewArticlesToolbarDelegate
- (void)newArticlesToolbar:(UIToolbar *)toolbar mediaLibraryButtonDidClicked:(id)button {
    [self.view endEditing:YES];
    [self pickerImageFromMediaLibrary];
}

- (void)newArticlesToolbar:(UIToolbar *)toolbar locationButtonDidClicked:(id)button {
    [self.view endEditing:YES];
    [self attachLocationInfo:nil];
}

- (void)newArticlesToolbar:(UIToolbar *)toolbar saveFileButtonDidClicked:(id)button {
    [self.view endEditing:YES];
    [self saveExpress:nil];
}





@end
