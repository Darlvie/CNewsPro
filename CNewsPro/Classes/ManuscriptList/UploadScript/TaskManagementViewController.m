//
//  TaskManagementViewController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "TaskManagementViewController.h"
#import "ManuscriptsDB.h"
#import "UploadManager.h"
#import "ScriptItem.h"
#import "UploadClient.h"
#import "AppDelegate.h"
#import "UploadTaskCell.h"
#import "Utility.h"
#import "Accessories.h"
#import "AccessoriesDB.h"
#import "ManuscriptTemplate.h"
#import "MultipleScriptCell.h"
#import "NewArticlesController.h"

static const CGFloat kCellHeight = 105.0f;

@interface TaskManagementViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableDictionary *selectDic;
@property (nonatomic,strong)  NSMutableArray *imageList;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *pauseButton;
@property (nonatomic,strong) UIButton *startButton;
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIView *viewAboveTableView;
@property (nonatomic,strong) UILabel *totalNumber;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UILabel *noDataLabel;
@property (nonatomic,strong) NSMutableArray *scriptItems;
@property (nonatomic,assign) BOOL		allSelected;
@property (nonatomic,strong) UIButton *selectedButton;
@end

@implementation TaskManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.selectDic = [[NSMutableDictionary alloc]init];
    //设置禁止锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"SendingScript_titleimge"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"待发稿件" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = RGB(60, 90, 154);
    
    self.imageList = [[NSMutableArray alloc] init];
    [self.imageList addObject:[UIImage imageNamed:@"bigpicholder.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"audioBg.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"videoBg.png"]];
 
    self.viewAboveTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.titleLabelAndImage.frame),SCREEN_WIDTH,34.0f)];
    self.viewAboveTableView.backgroundColor = [UIColor whiteColor];
    
    //edit button
    self.editButton=[[UIButton alloc]initWithFrame:CGRectMake(40, 1, 58, 30)];
    [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.editButton setBackgroundColor:RGB(60, 90, 154)];
    self.editButton.layer.cornerRadius = 3.0f;
    self.editButton.layer.masksToBounds = YES;
    [self.editButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.editButton];
    
    self.selectedButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 32, 32)];
    [self.selectedButton setImage:[UIImage imageNamed:@"checked_2-1"] forState:UIControlStateNormal];
    [self.selectedButton setImage:[UIImage imageNamed:@"checked_2_filled"] forState:UIControlStateSelected];
    [self.selectedButton addTarget:self action:@selector(allSelect) forControlEvents:UIControlEventTouchUpInside];
    self.selectedButton.hidden = YES;
    [self.viewAboveTableView addSubview:self.selectedButton];
    
    //cancelButton init,hidden
    self.pauseButton=[[UIButton alloc]initWithFrame:CGRectMake(140,0,32,32)];
    [self.pauseButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    self.pauseButton.hidden=YES;
    [self.pauseButton setImage:[UIImage imageNamed:@"pause_filled"] forState:UIControlStateNormal];
    [self.pauseButton setContentMode:UIViewContentModeCenter];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton setShowsTouchWhenHighlighted:YES];
    [self.viewAboveTableView addSubview:self.pauseButton];
    
    self.startButton=[[UIButton alloc]initWithFrame:CGRectMake(203,0,32,32)];
    self.startButton.hidden=YES;
    [self.startButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageNamed:@"play_filled"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setShowsTouchWhenHighlighted:YES];
    [self.viewAboveTableView addSubview:self.startButton];
    
    //delete button
    self.deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(260,-2,35,35)];//CGRectMake(110,10,25,22)
    self.deleteButton.hidden=YES;
    [self.deleteButton setImage:[UIImage imageNamed:@"delete_sign_filled"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteFuntion) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setShowsTouchWhenHighlighted:YES];
    [self.viewAboveTableView addSubview:self.deleteButton];
    
    //separated Line
    UILabel * sLine = [[UILabel alloc] initWithFrame:CGRectMake(40,32,self.widthOfMainView-40.0,1)];
    sLine.backgroundColor =[UIColor lightGrayColor];
    [self.viewAboveTableView addSubview:sLine];
    
    //total number
    self.totalNumber = [[UILabel alloc]initWithFrame:CGRectMake(400,1,55,30)];//CGRectMake(300,10,20,22)
    self.totalNumber.font = [UIFont boldSystemFontOfSize:20];
    self.totalNumber.textAlignment = NSTextAlignmentRight;
    self.totalNumber.textColor = RGB(60, 90, 154);
    self.totalNumber.backgroundColor=[UIColor clearColor];
    [self.viewAboveTableView addSubview:self.totalNumber];
    [self.view addSubview:self.viewAboveTableView];
    
    //注册上传进度通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgress:)
                                                 name:UPDATE_UPLOAD_PROGRESS_NOTIFICATION
                                               object:nil];
    
    //注册刷新列表通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCompleteClient:)
                                                 name:DELETE_COMPLETE_CLIENT
                                               object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.viewAboveTableView.frame),self.widthOfMainView,HEIGH_TO_FMAIN_VIEW(self.heightOfMainView, CGRectGetHeight(self.viewAboveTableView.frame), 0.0)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGB(245, 245, 245);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:self.tableView];
    
    //no data label
    self.noDataLabel= [[UILabel alloc]initWithFrame:CGRectMake(40,3,100,30)];
    [self.noDataLabel setText:@"暂无数据"];
    self.noDataLabel.textColor = RGB(60, 90, 154);
    self.noDataLabel.hidden = NO;
    [self.tableView addSubview:self.noDataLabel];
    self.noDataLabel.backgroundColor = [UIColor clearColor];
    
    // [self PauseAllClient];
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    self.scriptItems = [mdb getManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME] status:MANUSCRIPT_STATUS_STAND_TO];

    if ([[UploadManager sharedManager] uploadClientCount]>0) {
        
        self.noDataLabel.hidden = YES;
        
    }else {
        
        self.noDataLabel.hidden = NO;
    }
    
    // [self.tableView reloadData];
    
    self.totalNumber.text = [NSString stringWithFormat:@"%ld",[[UploadManager sharedManager] uploadClientCount]];
    [self loadTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [NOTIFICATION_CENTER removeObserver:self];
}

- (void)returnToParentView:(UIButton *)button {
    //取消禁止锁屏
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    NSInteger i=[self.navigationController.viewControllers count]-2;
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i]  animated:YES];
}

//表格进入编辑状态
- (void)setEditing:(BOOL)editting animated:(BOOL)animated
{
    if (!editting)
    {
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = NO;
        }
    }
    [self.tableView setEditing:editting animated:animated];
}

#pragma mark - NSNotification Method
-(void)updateCompleteClient:(NSNotification*)notif
{
    self.noDataLabel.hidden = NO;
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    self.scriptItems = [[NSMutableArray alloc] initWithArray:[mdb getManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME] status:MANUSCRIPT_STATUS_STAND_TO]];
    [self loadTableView];
  
}

-(void)updateProgress:(NSNotification*)notif
{
    //刷新tableview，以更新上传进度显示
    UploadClient *a = [notif object];
    NSIndexPath *i  = [NSIndexPath indexPathForRow:a.currentIndexPath inSection:0];
    UploadTaskCell *cell = (UploadTaskCell*)[self.tableView cellForRowAtIndexPath:i];
    cell.progressView.progress = a.progress;
    NSString *filepath = [[UploadManager sharedManager] attachmentPathAtQueueIndex:i.row];
    double totalSize = (double)[Utility getFileLengthByPath:filepath]/1024.0;
    double speed = (double)[[USERDEFAULTS objectForKey:FILE_BLOCK] intValue]*1000/a.blockTime;
    double time  = (double)totalSize*(1-a.progress)/speed;
    if (time>60&&time<60*60) {
        NSInteger minute = time/60;
        cell.leaveTime.text = [NSString stringWithFormat:@"%@%ld%@",@"剩余时间:",minute,@"分钟"];
        
    }
    if (time>60*60) {
        NSInteger minute=time/3600;
        cell.leaveTime.text=[NSString stringWithFormat:@"%@%ld%@",@"剩余时间:",minute,@"小时"];
        
    }
    if (time<60) {
        cell.leaveTime.text=[NSString stringWithFormat:@"%@%.lf%@",@"剩余时间:",time,@"秒"];
        
    }

    NSString *clientstatus = [[UploadManager sharedManager] getUploadRequestStatus:a.currentIndexPath];

    if ([clientstatus isEqualToString:LAST_FAIL])
    {
        cell.progressView.progress=0;//进度清0
        [cell.btnSwitch setTitle:@"2" forState:UIControlStateNormal];
        [cell.btnSwitch setImage:[UIImage imageNamed:@"recurring_appointment_filled"] forState:UIControlStateNormal];
        
    }
    if ([clientstatus isEqualToString:REQUEST_FAIL])
    {
        [cell.btnSwitch setImage:[UIImage imageNamed:@"play_filled"] forState:UIControlStateNormal];
        [cell.btnSwitch setTitle:@"1" forState:UIControlStateNormal];
        [[UploadManager sharedManager] pauseUploadClientAtQueueIndex:i.row];
        
    }
    if (!a.paused && a.running) {
        [cell.btnSwitch setImage:[UIImage imageNamed:@"pause_filled"] forState:UIControlStateNormal];
        [cell.btnSwitch setTitle:@"1" forState:UIControlStateNormal];
        
    }
    self.noDataLabel.hidden = YES;
}


#pragma mark - Private Method
//进入编辑模式添加的动画
//- (void)setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
//{
//    if (animated)
//    {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.3];
//        
//        self.checkImageView.center = pt;
//        self.checkImageView.alpha = alpha;
//        
//        [UIView commitAnimations];
//    }
//    else
//    {
//        self.checkImageView.center = pt;
//        self.checkImageView.alpha = alpha;
//    }
//}

//点击编辑按钮之后点击取消时，取消全选
- (void)allSelectCancel
{
    
    for (ScriptItem* item in self.scriptItems)
    {
        item.checked = NO;
    }
    [self.selectDic removeAllObjects];
    
    [self.tableView reloadData];
}

-(void)loadTableView
{
    ManuscriptsDB *Mdb = [[ManuscriptsDB alloc] init];
    self.scriptItems = [Mdb getManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME] status:MANUSCRIPT_STATUS_STAND_TO];
    if ([[UploadManager sharedManager] uploadClientCount]>0) {
        self.tableView.backgroundColor = RGB(245, 245, 245);
        self.noDataLabel.hidden = YES;
    }else {
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.noDataLabel.hidden = NO;
    }
    [self.tableView reloadData];
    
    self.totalNumber.text = [NSString stringWithFormat:@"%ld",[[UploadManager sharedManager] uploadClientCount]];
}


#pragma mark - Action Method
- (void)editButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.editButton setTitle:@"取消" forState:UIControlStateNormal];
        self.pauseButton.hidden = NO;
        self.deleteButton.hidden=NO;
        self.startButton.hidden = NO;
        self.selectedButton.hidden = NO;
        [self.tableView setEditing:YES animated:YES];
        self.allSelected = NO;
        [self.tableView reloadData];
    } else {
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.deleteButton.hidden = YES;
        self.pauseButton.hidden=YES;
        self.startButton.hidden=YES;
        self.selectedButton.hidden = YES;
        //列表恢复原始状态
        [self allSelectCancel];
        //checkbox in tableview
        [self.tableView setEditing:NO animated:NO];
        self.allSelected = NO;
        [self.tableView reloadData];
    }
}

//全部选择
- (void)allSelect
{
    self.selectedButton.selected = !self.selectedButton.selected;
    self.allSelected = !self.allSelected;
    if (!self.allSelected) {
        
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = NO;
        }
        [self.selectDic removeAllObjects];
    }
    else {
        for (int i=0; i<[self.scriptItems count]; i++) {
            ScriptItem* item =[self.scriptItems objectAtIndex:i];
            item.indexPath = i;
            item.checked = YES;
            [self.selectDic setObject:item forKey:item.m_id];
            
        }
        
    }
    
    [self.tableView reloadData];
}

//暂停任务
-(void)pause
{
    for (ScriptItem* scriptItem in [self.selectDic allValues])
    {
        UploadClient *uclient = [[UploadManager sharedManager] getClientAtIndex:scriptItem.indexPath];
        if (!uclient.paused && uclient.running) {
            [[UploadManager sharedManager] pauseUploadClientAtQueueIndex:scriptItem.indexPath];
            
        }
    }
    
    
}

//开始任务
-(void)start
{
    for (ScriptItem* scriptItem in [self.selectDic allValues])
    {
        UploadClient *uclient=[[UploadManager sharedManager] getClientAtIndex:scriptItem.indexPath];
        if (uclient.paused && !uclient.running) {
            [[UploadManager sharedManager] continueUploadClientAtQueueIndex:scriptItem.indexPath];
        }
        
        
    }
    
}

- (void)deleteFuntion
{
    //删除
    NSMutableArray *ClientArray=[[NSMutableArray alloc] init];
    for (ScriptItem* scriptItem in [self.selectDic allValues])
    {
        UploadClient *uclient=[[UploadManager sharedManager] getClientAtIndex:scriptItem.indexPath];
        if (uclient.running && !uclient.paused) {
            [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"当前任务正在执行，不能撤销！"];
            return;
        }
        [ClientArray addObject:uclient];
        //全选按钮  呈现 未选状态
    }
    for (int i=0; i<[ClientArray count]; i++) {
        [[UploadManager  sharedManager] removeClientByClient:[ClientArray objectAtIndex:i]];
    }
    [self.selectDic removeAllObjects];
    self.allSelected = NO;
    [self loadTableView];
    
}

//切换暂定／继续
-(void)switchUploadStatus:(UIButton*)sender
{
    UploadClient *uclient = [[UploadManager sharedManager] getClientAtIndex:[sender tag]];
    NSString *clientstatus=[[UploadManager sharedManager] getUploadRequestStatus:[sender tag]];
    //任务失败，则重新开始
    if ([clientstatus isEqualToString:LAST_FAIL]) {
        uclient.reloadCount = 1;//手动开始重传
        [uclient startUpload];
        [sender setImage:[UIImage imageNamed:@"pause_filled"] forState:UIControlStateNormal];
        return;
    }
    //任务正在运行，则暂停
    if (!uclient.paused && uclient.running) {
        [[UploadManager sharedManager] pauseUploadClientAtQueueIndex:[sender tag]];
        [sender setImage:[UIImage imageNamed:@"play_filled"] forState:UIControlStateNormal];
        return;
    }
    //任务正暂停，则运行
    if (uclient.paused && !uclient.running) {
        [[UploadManager sharedManager] continueUploadClientAtQueueIndex:[sender tag]];
        [sender setImage:[UIImage imageNamed:@"pause_filled"] forState:UIControlStateNormal];
        return;
    }
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kCellHeight;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[UploadManager sharedManager] uploadClientCount];
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"noticeCell";
    
    ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
    UploadTaskCell *cell = (UploadTaskCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Manuscripts *manuscripts = [[UploadManager sharedManager] objectAtQueueIndex:indexPath.row];
    NSString *filepath = [[UploadManager sharedManager] attachmentPathAtQueueIndex:indexPath.row];
    
    if (cell==nil)
    {
        cell = [[UploadTaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == [[UploadManager sharedManager] uploadClientCount]) {
        return cell ;
    }
    
    if (!scriptItem.image) {
        if (![filepath isEqualToString:@"0"]) {
            NSString *type = [filepath substringWithRange:NSMakeRange([filepath length]-3, 3)];
           
            if ([[@"." stringByAppendingString:type] isEqualToString:IMG_TYPE]) {
             
                if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    [self startIconDownload:scriptItem  forIndexPath:indexPath];
                }
                // if a download is deferred or in progress, return a placeholder image
                cell.attachmentimg.image = [self.imageList objectAtIndex:0];//[UIImage imageNamed:@"bigpicholder.png"];
            }
            if ([[@"." stringByAppendingString:type] isEqualToString:VOC_TYPE]) {
                scriptItem.image = [self.imageList objectAtIndex:1];
                cell.attachmentimg.image = [self.imageList objectAtIndex:2];
                
            }
            if ([[@"." stringByAppendingString:type] isEqualToString:MOV_TYPE]) {
                scriptItem.image = [self.imageList objectAtIndex:2];
                cell.attachmentimg.image = [self.imageList objectAtIndex:1];
            }
        }
        
    }else {
        cell.attachmentimg.image=scriptItem.image;
    }
    
    UploadClient *uclient = [[UploadManager sharedManager] getClientAtIndex:indexPath.row];
    uclient.currentIndexPath=indexPath.row;
    if (uclient.running) {
        [cell.btnSwitch setImage:[UIImage imageNamed:@"pause_filled"] forState:UIControlStateNormal];
        [cell.btnSwitch setTitle:@"0" forState:UIControlStateNormal];
    }
    else if(uclient.paused){
        [cell.btnSwitch setImage:[UIImage imageNamed:@"play_filled"] forState:UIControlStateNormal];
        [cell.btnSwitch setTitle:@"1" forState:UIControlStateNormal];
    }
    else
    {
        [cell.btnSwitch setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
    }
    //为控件赋值
   cell.progressView.progress = [[UploadManager sharedManager] uploadProgressAtQueueIndex:indexPath.row];
    cell.manuscriptsContent.text = manuscripts.mTemplate.address;
    if ([manuscripts.title isEqualToString:@""]) {
        NSLog(@"manuscripts is null");
    }

    cell.manuscriptsTitle.text = manuscripts.title;
    cell.btnSwitch.tag = indexPath.row;
    [cell.btnSwitch addTarget:self action:@selector(switchUploadStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *clientstatus=[[UploadManager sharedManager] getUploadRequestStatus:indexPath.row];
    if ([clientstatus isEqualToString:LAST_FAIL]) {
        [cell.btnSwitch setTitle:@"2" forState:UIControlStateNormal];
        [cell.btnSwitch setImage:[UIImage imageNamed:@"recurring_appointment_filled"] forState:UIControlStateNormal];
    }
    if (indexPath.row < MAX_CLIENT_COUNT) {
        cell.btnSwitch.hidden = NO;
    }
    else {
        cell.btnSwitch.hidden = YES;
    }
    //编辑模式下隐藏按钮
    if (aTableView.editing == YES) {
        cell.btnSwitch.hidden = YES;
    }
    else
    {
        cell.btnSwitch.hidden = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell setChecked:scriptItem.checked];
    cell.fileLenth.text = [NSString stringWithFormat:@"%@%.2f%@",@"文件大小:",[Utility getFileLengthByPath:filepath]/(1024*1024.0),@"M"]; //显示文件大小
    
    return  cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
        scriptItem.indexPath = indexPath.row;
        MultipleScriptCell *cell = (MultipleScriptCell *)[tableView cellForRowAtIndexPath:indexPath];
        scriptItem.checked = !scriptItem.checked;
        [cell setChecked:scriptItem.checked];
        if (scriptItem.checked) {
            [self.selectDic setObject:scriptItem forKey:scriptItem.m_id];
        }
        else{
            [self.selectDic removeObjectForKey:scriptItem.m_id];
        }
    }
    else
    {
        ScriptItem* item = [self.scriptItems objectAtIndex:indexPath.row];
        NewArticlesController *postViewController = [[NewArticlesController alloc] init];
        postViewController.operationType = @"detail";
        postViewController.manuscript_id = item.m_id;
        postViewController.indexPath = indexPath;
        [self.navigationController pushViewController:postViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self switchUploadStatus:nil];
       
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//打开编辑模式后，默认情况下每行左边会出现红的删除按钮，这个方法就是关闭这些按钮的
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}



#pragma mark Table cell image support

- (void)startIconDownload:(ScriptItem *)scriptItem forIndexPath:(NSIndexPath *)indexPath
{
    NSString* str = scriptItem.m_id;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取缩略图
        UIImage* img = [self getThumb:str];
        // 更新图像
        dispatch_async(dispatch_get_main_queue(), ^{
            scriptItem.image = img;
            [self appImageDidLoad:indexPath];
        });
    });
}

- (UIImage *)getThumb:(NSString *)m_id {
    
    //取得稿件附件列表：取得第一个附件将其放入淘汰列表的附图位置
    
    AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
    NSMutableArray *accessoriesList=[adb getAccessoriesListByMId:m_id];
    
    NSString *imageName=@"";
    if([accessoriesList count]==0){  //如果没有附件时，加载默认图片
        //        imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"bigpicholder.png"];
    }
    else{
        //根据附件类型确定加载视频图片、音频图片还是普通图片
        Accessories *firstAccess = [accessoriesList objectAtIndex:0];//第一个附件
        NSString *accessType = firstAccess.type;
        
        
        if (accessType == nil) {
            //            imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"bigpicholder.png"];
        }
        else {
            if ([accessType isEqualToString:@"PHOTO"]) {
                
                imageName = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:firstAccess.originName];
            }
            else if([accessType isEqualToString:@"VIDEO"]){
                imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"videoBg.png"];
            }
            else if([accessType isEqualToString:@"AUDIO"]){
                imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"audioBg.png"];
                
            }
        }
    }
    return [Utility scale:[UIImage imageWithContentsOfFile:imageName] toSize:CGSizeMake(70,60) ];
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    if ([self.scriptItems count]>indexPath.row) {
        ScriptItem *iconDownloader = [self.scriptItems objectAtIndex:indexPath.row];
        if (iconDownloader.image != nil)
        {
            UploadTaskCell *cell =(UploadTaskCell *) [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.attachmentimg.image = iconDownloader.image;
        }
        
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        ScriptItem *appRecord = [self.scriptItems objectAtIndex:indexPath.row];
        
        if (!appRecord.image) // avoid the app icon download if the app already has an icon
        {
            [self startIconDownload:appRecord forIndexPath:indexPath];
        }
    }
    
}

#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
