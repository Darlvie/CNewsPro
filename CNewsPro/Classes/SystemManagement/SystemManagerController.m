//
//  SystemManagerController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "SystemManagerController.h"
#import <AdSupport/ASIdentifierManager.h>
#import <sys/sysctl.h>
#import "LoginViewController.h"
#import "Utility.h"
#import "UploadManager.h"
#import "ServerAddressDB.h"
#import "ServerAddress.h"
#import "UIDevice+IdentifierAddition.h"
#import "BasicInfoUtility.h"
#import "AppDelegate.h"
#import "Language.h"
#import "ProvideType.h"
#import "User.h"
#import "NewTagDetailViewController.h"

@interface SystemManagerController () <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@end

@implementation SystemManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sysTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStyleGrouped];
    self.sysTableView.backgroundView = nil;
    [self.sysTableView setBackgroundColor:[UIColor lightGrayColor]];
    self.sysTableView.delegate = self;
    self.sysTableView.dataSource = self;
    [self.view addSubview:self.sysTableView];
    
    //导航试图
    [self.titleLabelAndImage setTitle:@"系统设置" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:71.0f/255.0f green:67.0f/255.0f blue:66.0f/225.0f alpha:1.0f];
    
    //添加登出按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"Exit"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(LogOut:) forControlEvents:UIControlEventTouchUpInside];
    
    self.networkSettingItems = [[NSArray alloc]initWithObjects:@"当前账号",@"登录服务器",@"更新基础数据",@"系统版本",@"设备标识号",nil];
    self.localSettingItems = [[NSArray alloc]initWithObjects:@"传输文件分块大小",@"自动保存时间",@"自动重传次数",@"是否保存用户密码",@"视频质量",@"视频清晰度",@"帧率",nil];
    
    [self initializeFileBlockSelection];
    [self initializeAutoSaveTimeSelection];
    [self initializeReSendCount];
    [self initializeCompress];
    [self initializeResolutionArry];
    [self initializeCodeArray];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark view initialization
- (void)viewWillDisappear:(BOOL)animated
{
    
    if (self.actionSheet) {
        CGRect sheetFrame = self.actionSheet.frame;
        sheetFrame.origin.y += sheetFrame.size.height;
        sheetFrame.size.height = 1.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.actionSheet.frame = sheetFrame;
                         } completion:^(BOOL finished) {
                             //nop
                             [self.actionSheet removeFromSuperview];
                         }];
    }
}


-(void)initializeFileBlockSelection
{
    self.fileBlockArray = [[NSArray alloc]initWithObjects:@"256",@"512",@"1",@"2",@"4",nil];
    //传输文件分块大小初始化
    if ([USERDEFAULTS objectForKey:FILE_BLOCK]) {
        int i = [[USERDEFAULTS objectForKey:FILE_BLOCK] intValue];
        if (i<1024) {
            self.currentFileBlock = [[USERDEFAULTS objectForKey:FILE_BLOCK] stringByAppendingFormat:@"KB"];
        }
        else {
            i = i/1024;
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            self.currentFileBlock = [string stringByAppendingFormat:@"MB"];
        }
    }
    else {
        self.currentFileBlock = @"512KB";
        NSString *string = [[NSString alloc] initWithFormat:@"%d",512];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:string forKey:FILE_BLOCK];
        [defaults synchronize];
    }

}

-(void)initializeAutoSaveTimeSelection
{
    self.autoSaveTimeArray = [[NSArray alloc]initWithObjects:@"不自动保存",@"15s",@"30s",@"1min",@"2min",@"10min",@"30min",nil];
    //自动保存时间初始化
    if ([USERDEFAULTS objectForKey:AUTO_SAVE_TIME]) {
        int i = [[USERDEFAULTS objectForKey:AUTO_SAVE_TIME] intValue];
        if (i>30) {
            i = i/60;
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            self.currentAutoSaveTime = [string stringByAppendingFormat:@"分钟"];
        }
        else if (i == 0) {
            self.currentAutoSaveTime = @"不自动保存";
        }
        else {
            self.currentAutoSaveTime = [[USERDEFAULTS objectForKey:AUTO_SAVE_TIME] stringByAppendingFormat:@"s"];
        }
    }
    else {
        self.currentAutoSaveTime = @"不自动保存";
        NSString *string = [[NSString alloc] initWithFormat:@"%d",0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:string forKey:AUTO_SAVE_TIME];
        [defaults synchronize];
    }

}

-(void)initializeCompress
{
    self.compressLevel = [[NSArray alloc] initWithObjects:@"高",@"低",nil];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:COMPRESS]) {
        self.compress= [[NSUserDefaults standardUserDefaults] objectForKey:COMPRESS];
        
    }
    
}

-(void)initializeResolutionArry
{
    if ([[self getDeviceVersion]hasPrefix:@"iPhone4"] || [[self getDeviceVersion]hasPrefix:@"iPhone5"]) {
        self.resolutionArry = [[NSArray alloc] initWithObjects:@"标清480p",@"高清720p", nil];
    }
    else
        self.resolutionArry = [[NSArray alloc] initWithObjects:@"标清480p",@"高清720p",@"全高清1080p", nil];
    //分辨率初始化
    if ([[NSUserDefaults standardUserDefaults] objectForKey:RESOLUTION]) {
        self.resolution= [[NSUserDefaults standardUserDefaults] objectForKey:RESOLUTION];
    }
    
}

-(void)initializeReSendCount
{
    self.autoReSendCount = [[NSArray alloc]initWithObjects:@"不重传",@"5",@"10",@"15",@"20",@"无限",nil];
    //自动保存时间初始化
    if ([USERDEFAULTS objectForKey:RE_SEND_COUNT]) {
        int i = [[USERDEFAULTS objectForKey:RE_SEND_COUNT] intValue];
        if (i==9999) {
            self.currentResendCount = @"无限";
        }
        else if(i==0)
        {
            self.currentResendCount = @"不重传";
        }
        else {
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            self.currentResendCount = [string stringByAppendingFormat:@"次"];
            
        }
    }
    else {
        self.currentResendCount = @"5 次";
        [USERDEFAULTS setObject:@"5 " forKey:RE_SEND_COUNT];
    }
    
}

-(void)initializeCodeArray
{
    self.codeBitArray = [[NSArray alloc]initWithObjects:@"24FPS",@"25FPS",@"30FPS",@"60FPS",nil];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CODE_BIT])
    {
        NSString *codetext = [USERDEFAULTS objectForKey:CODE_BIT];
        self.codeText = codetext;
    }
}

#pragma mark - Privite
-(NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

-(void)LogOut:(id)sender
{
    if ([USERDEFAULTS objectForKey:SAVE_PASSWORD]) {
        if (![[USERDEFAULTS objectForKey:SAVE_PASSWORD] intValue]) {
            [USERDEFAULTS setObject:nil forKey:PASSWORD];
        }
    }
    
    [USERDEFAULTS setObject:@"" forKey:SESSION_ID];
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:FALSE];
    
    NSString *filePath = [Utility temporaryTemplateFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSFileManager *defaultManager;
        defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:filePath error:nil];
    }
    
    //将当前用户的所有任务都取消
    for (int i=0; i<[[UploadManager sharedManager] uploadClientCount]; i++) {
        [[UploadManager sharedManager] pauseUploadClientAtQueueIndex:i];//先暂停
        [[UploadManager sharedManager] removeClient:i];//再删除
        i=i-1;
    }
    
}

//获取保存密码开关的事件
- (void)switchValueChanged:(UISwitch*)sender
{
    NSString *string = [[NSString alloc] initWithFormat:@"%d",self.switchOfSavePassword.isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:string forKey:SAVE_PASSWORD];
    [defaults synchronize];
}

-(void)initializeActionSheet
{
    //退出键盘
    [self.view endEditing:YES];
    
    //初始化actionsheet
    self.actionSheet = [[UIView alloc]initWithFrame:self.view.bounds];
    self.actionSheet.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    
    UIView *backcolorView = [[UIView alloc]initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.actionSheet.frame)-240.0, CGRectGetWidth(self.view.frame), 260.0)];
    backcolorView.backgroundColor = [UIColor colorWithWhite:218.0/255.0 alpha:1.0];
    backcolorView.tag = 1101;
    [self.actionSheet addSubview:backcolorView];
    
    //定义取消按钮
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [[self.actionSheet viewWithTag:1101] addSubview:cancelButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.networkSettingItems count];
    }
    return [self.localSettingItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sysItemCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    //表格标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=[UIColor blackColor];
    
    UILabel *detailLabel = [[UILabel alloc]init];
    detailLabel.backgroundColor=[UIColor clearColor];
    detailLabel.textColor = DETAIL_LABEL_COLOR;
    detailLabel.font = TF_FONT;
    
    if (indexPath.section == 0) {
        titleLabel.frame = NETWORK_TITLE_CGRECT;
        titleLabel.text = [self.networkSettingItems objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            detailLabel.frame = NETWORK_DETAIL_CGRECT;
            detailLabel.text = [USERDEFAULTS objectForKey:LOGIN_NAME];
        }
        else if (indexPath.row == 1) {
            //当前服务器
            ServerAddressDB *sDB = [[ServerAddressDB alloc]init];
            ServerAddress *sAddr = [sDB getDefaultServer];
            self.currentserver = MITI_IP;
            
            detailLabel.frame = CGRectMake(145, 0, 125, 45);
            detailLabel.text = self.currentserver;
            detailLabel.numberOfLines = 2;
            detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
        }
        else if (indexPath.row == 3) {
            detailLabel.frame = NETWORK_DETAIL_CGRECT;
            detailLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        }
        else if (indexPath.row == 4) {
            detailLabel.frame = CGRectMake(145, 0, 165, 45);
            detailLabel.numberOfLines = 2;
            detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
            detailLabel.text = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
            
        }
    }
    else {
        titleLabel.frame = LOCAL_TITLE_CGRECT;
        titleLabel.text = [self.localSettingItems objectAtIndex:indexPath.row];
        if (indexPath.row !=3) {
            UIImageView *imageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"TempleView_detail"]];
            imageView.frame = CGRectMake(0, 0, 25, 25);
            cell.accessoryView = imageView;
            if (indexPath.row == 0) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.currentFileBlock;
            }
            if (indexPath.row == 1) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.currentAutoSaveTime;
            }
            if (indexPath.row == 2) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.currentResendCount;
            }
            if (indexPath.row == 4) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.compress;
            }
            if (indexPath.row == 5) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.resolution;
            }
            if (indexPath.row == 6) {
                detailLabel.frame = LOCAL_DETAIL_CGRECT;
                detailLabel.text = self.codeText;
            }
            
        }
        else {
            self.switchOfSavePassword = [[UISwitch alloc]initWithFrame:CGRectMake(180, 9, 120, 35)];
            
            if ([USERDEFAULTS objectForKey:SAVE_PASSWORD]) {
                if ([[USERDEFAULTS objectForKey:SAVE_PASSWORD] intValue]) {
                    [self.switchOfSavePassword setOn:YES animated:NO];
                }
                else {
                    [self.switchOfSavePassword setOn:NO animated:NO];
                }
            }
            else {
                [self.switchOfSavePassword setOn:YES animated:NO];
            }
            [cell addSubview:self.switchOfSavePassword];
            [self.switchOfSavePassword addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }
    [cell addSubview:detailLabel];
    [cell addSubview:titleLabel];
    return cell;
}


#pragma mark - Table view delegate
//点击cell推出子列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //更新基础数据
        if (indexPath.row == 2) {
            if (![self connectedToNetwork]) {
                [self showAlertWithType:AlertTypeAlert withString:@"请确认网络连接"];
                return;
            }
            
            [self showWait];
            dispatch_async(dispatch_get_current_queue(), ^{
                //////更新基础数据start
                BasicInfoUtility *bInfo = [[BasicInfoUtility alloc]init];
                if([bInfo copyBasicInfoPlist]){   //拷贝存放基础数据的plist文件
                    NSString *xmlfileNameList = [bInfo getFileNameList];
                    //查看基础数据是否有更新
                    NSString *xmlResult = [bInfo getFileNameWithNewBasicInfo:xmlfileNameList];
                    if ([xmlResult isEqualToString:@""]||[xmlResult isEqual:nil]) {
                        [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"没有可更新的基础数据"];
                    }
                    else{
                        //异步加载等待对话框，完成发送前的准备工作后予以关闭
                        if ([bInfo updateBasicInfo:xmlResult]) {
                            [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"更新基础数据成功"];
                        };
                        
                    }
                }
                else{
                    [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"更新基础数据失败"];
                }
                [self hideWaiting];
                /////更新基础数据end
            });
            
        }
        //版本更新检测
        if (indexPath.row == 3) {
            if (![self connectedToNetwork]) {
                [self showAlertWithType:AlertTypeAlert withString:@"请确认网络连接"];
                return;
            }
            
            [self showWait];
            dispatch_async(dispatch_get_current_queue(), ^{
                if ([Utility checkNewVersion]) {
                    [self hideWaiting];
                    [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"当前已是最新版本！"];
                }else {
                    [self hideWaiting];
                    UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"新版本！"
                                                                                      message: @"已经检测到最新版本，请下载更新"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"取消"
                                                                            otherButtonTitles:@"更新", nil];
                    [createUserResponseAlert show];
                }
            });
        }
        
    }
    else {
        //选择传输文件块大小
        if (indexPath.row == 0) {
            [self initializeActionSheet];
            
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = FILE_BLOCK_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = FILE_BLOCK_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            //zyq
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
        }
        //选择自动保存时间
        else if (indexPath.row == 1) {
            [self initializeActionSheet];
            
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = AUTO_SAVE_TIME_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = AUTO_SAVE_TIME_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
        }
        else if(indexPath.row==2)
        {
            [self initializeActionSheet];
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = AUTO_SAVE_TIME_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = AUTO_SAVE_TIME_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
            
        }
        else if(indexPath.row==4)
        {
            [self initializeActionSheet];
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = COMPRESS_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = COMPRESS_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
            
        }
        else if(indexPath.row==5)
        {
            [self initializeActionSheet];
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = RESOLUTION_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = RESOLUTION_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            //zyq
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];

        }
        else if(indexPath.row==6)
        {
            [self initializeActionSheet];
            //初始化选择器
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = CODE_BIT_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            //定义选择按钮
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = CODE_BIT_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
            
        }
        
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

//设置表头
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headview.backgroundColor = [UIColor clearColor];
    
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 100, 20)];
    
    [lbText setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:17]];
    if (section == 0) {
        lbText.text = @"网络设置";
    }
    else {
        lbText.text = @"本地设置";
    }
    lbText.backgroundColor=[UIColor clearColor];
    lbText.textColor=[UIColor blackColor];
    [headview addSubview:lbText];
    return headview;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


#pragma mark -
#pragma mark pickerView data delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//设置选择器的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == FILE_BLOCK_TAG) {
        return [self.fileBlockArray count];
    }
    else if (pickerView.tag == AUTO_SAVE_TIME_TAG) {
        return [self.autoSaveTimeArray count];
    }
    else if (pickerView.tag == AUTO_SEND_COUNT_TAG){
        return [self.autoReSendCount count];
    }
    else if (pickerView.tag == COMPRESS_TAG){
        return [self.compressLevel count];
    }
    else if (pickerView.tag == RESOLUTION_TAG){
        return [self.resolutionArry count];
    }
    else if (pickerView.tag == CODE_BIT_TAG)
    {
        return [self.codeBitArray count];
    }
    return 0;
}

//设置选择器每行内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == FILE_BLOCK_TAG) {
        if (row<2) {
            return [[self.fileBlockArray objectAtIndex:row] stringByAppendingFormat:@"KB"];
        }
        else {
            return [[self.fileBlockArray objectAtIndex:row] stringByAppendingFormat:@"MB"];
        }
    }
    else if (pickerView.tag == AUTO_SAVE_TIME_TAG) {
        return [self.autoSaveTimeArray objectAtIndex:row];
    }
    else if (pickerView.tag == AUTO_SEND_COUNT_TAG){
        return [self.autoReSendCount objectAtIndex:row];
    }
    else if (pickerView.tag == COMPRESS_TAG){
        return [self.compressLevel objectAtIndex:row];
    }
    else if (pickerView.tag == RESOLUTION_TAG)
    {
        return [self.resolutionArry objectAtIndex:row];
        
    }
    else if (pickerView.tag == CODE_BIT_TAG)
    {
        return [self.codeBitArray objectAtIndex:row];
        
    }
    return nil;
}

//离开动作表时，完成所选内容的保存
- (void)dismissActionSheet:(UIButton *)DoneButton
{
    
    switch (DoneButton.tag) {
        case FILE_BLOCK_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:FILE_BLOCK_TAG];
            NSString *intValue = [self.fileBlockArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            int i = [intValue intValue];
            if (i<8) {
                self.currentFileBlock = [intValue stringByAppendingFormat:@"MB"];
                i *=1024;
            }
            else {
                self.currentFileBlock = [intValue stringByAppendingFormat:@"KB"];
            }
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            [USERDEFAULTS setObject:string forKey:FILE_BLOCK];
            [USERDEFAULTS synchronize];
            break;
        }
        case AUTO_SAVE_TIME_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:AUTO_SAVE_TIME_TAG];
            NSString *intValue = [self.autoSaveTimeArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            self.currentAutoSaveTime = intValue;
            int i = [intValue intValue];
            if ([pickerView selectedRowInComponent:0]>1) {
                i *=60;
            }
            else if ([pickerView selectedRowInComponent:0] == 0) {
                i = 0;
            }
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            [USERDEFAULTS setObject:string forKey:AUTO_SAVE_TIME];
            [USERDEFAULTS synchronize];

            break;
        }
        case AUTO_SEND_COUNT_TAG:
        {
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:AUTO_SEND_COUNT_TAG];
            self.currentResendCount=[self.autoReSendCount objectAtIndex:[pickerView selectedRowInComponent:0]];
            int i = [self.currentResendCount intValue];
            if ([pickerView selectedRowInComponent:0]==0) {
                i = 0;
            }
            else if([pickerView selectedRowInComponent:0]==5)
            {
                i = 9999;
            }
            NSString *string = [[NSString alloc] initWithFormat:@"%d",i];
            [USERDEFAULTS setObject:string forKey:RE_SEND_COUNT];
            [USERDEFAULTS synchronize];
            break;
            
        }
        case COMPRESS_TAG:
        {
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:COMPRESS_TAG];
            self.compress = [self.compressLevel objectAtIndex:[pickerView selectedRowInComponent:0]];
            [USERDEFAULTS setObject:self.compress forKey:COMPRESS];
            [USERDEFAULTS synchronize];
            break;
            
        }
        case RESOLUTION_TAG:
        {
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:RESOLUTION_TAG];
            self.resolution = [self.resolutionArry objectAtIndex:[pickerView selectedRowInComponent:0]];
            [USERDEFAULTS setObject:self.resolution forKey:RESOLUTION];
            [USERDEFAULTS synchronize];
            break;
            
        }
        case CODE_BIT_TAG:
        {
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:CODE_BIT_TAG];
            self.codeText = [self.codeBitArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            [[NSUserDefaults standardUserDefaults] setObject:self.codeText forKey:CODE_BIT];
            break;
            
        }
        default:
            break;
    }
    
    [self.sysTableView reloadData];
    CGRect sheetFrame = self.actionSheet.frame;
    sheetFrame.origin.y += sheetFrame.size.height;
    sheetFrame.size.height = 1.0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.actionSheet.frame = sheetFrame;
                     } completion:^(BOOL finished) {
                         //nop
                         [self.actionSheet removeFromSuperview];
                     }];

}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        NSString *iTunesLink = @"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=541796756&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}








@end
