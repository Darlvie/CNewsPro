//
//  AbandonedScriptController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AbandonedScriptController.h"
#import "ManuscriptsDB.h"
#import "ScriptItem.h"
#import "Accessories.h"
#import "AccessoriesDB.h"
#import "AppDelegate.h"
#import "AbandonedScriptCell.h"
#import "Utility.h"
#import "ScriptCell.h"
#import "NewArticlesController.h"

static const NSInteger kPageSize = 50;
static const NSInteger kTableCellHeight = 70;

@interface AbandonedScriptController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) BOOL allSelected;
@property (nonatomic,strong) NSMutableDictionary *deleteDic;
@property (nonatomic,strong) NSMutableArray *scriptItems;
@property (nonatomic,strong) UITableView *scriptTableView;
@property (nonatomic,strong) UIImageView *checkImageView;
@property (nonatomic,strong) UIView *viewAboveTableView;
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *delButton;
@property (nonatomic,strong) UIButton *reButton;
@property (nonatomic,strong) UILabel *totalNumber;
@property (nonatomic,assign) int pageNum;
@property (nonatomic,strong) NSMutableArray *imageList;
@property (nonatomic,strong) UIView *viewBelowTableView;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UIButton *lastBtn;
@property (nonatomic,strong) UILabel *pageStatusLabel;
@property (nonatomic,strong) UILabel *noDataLabel;
@end

@implementation AbandonedScriptController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.deleteDic = [[NSMutableDictionary alloc] init];
    
    // data binding
    self.pageNum = 0;
    self.imageList = [[NSMutableArray alloc] init];
    [self.imageList addObject:[UIImage imageNamed:@"bigpicholder.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"videoBg.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"audioBg.png"]];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"abandoned_icon.png"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"淘汰视图" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:219.0f/255.0f green:172.0f/255.0f blue:102.0f/225.0f alpha:1.0f];
    
    //table header view
    self.viewAboveTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.titleLabelAndImage.frame),320.0f,34.0f)];//32
    
    //edit button
    self.editButton=[[UIButton alloc]initWithFrame:CGRectMake(40,1,58,30)];//CGRectMake(40,10,48,22)
    
    [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"abandoned_editButton.png"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.editButton];
    
    //cancelButton init,hidden
    self.cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(40,1,58,30)];
    self.cancelButton.hidden = YES;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"abandoned_editButton.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.cancelButton];
    
    //delButton init,hidden
    self.delButton=[[UIButton alloc]initWithFrame:CGRectMake(112,1,22,30)];//CGRectMake(110,10,15,22)
    self.delButton.hidden = YES;
    [self.delButton setImage:[UIImage imageNamed:@"abandoned_deleteButton.png"] forState:UIControlStateNormal];
    [self.delButton addTarget:self action:@selector(deleteFuntion) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.delButton];
    
    //recoveryButton init,hidden
    self.reButton=[[UIButton alloc]initWithFrame:CGRectMake(154,1,22,30)];//CGRectMake(155,10,15,22)]
    self.reButton.hidden = YES;
    [self.reButton setImage:[UIImage imageNamed:@"abandoned_recoveryButton.png"] forState:UIControlStateNormal];
    [self.reButton addTarget:self action:@selector(recoveryFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.reButton];
    
    //separated Line
    UILabel * sLine = [[UILabel alloc] initWithFrame:CGRectMake(40,32,self.widthOfMainView-40.0,1)];
    sLine.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f];
    [self.viewAboveTableView addSubview:sLine];
    
    //total number
    self.totalNumber = [[UILabel alloc]initWithFrame:CGRectMake(263,1,55,30)];//CGRectMake(300,10,20,22)
    self.totalNumber.font = [UIFont boldSystemFontOfSize:20];
    self.totalNumber.textAlignment = NSTextAlignmentRight;
    self.totalNumber.textColor = [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f];
    [self.viewAboveTableView addSubview:self.totalNumber];
    [self.view addSubview:self.viewAboveTableView];
    
    
    //table below view
    self.viewBelowTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,self.view.frame.size.height-40,self.view.frame.size.width,40.0)];
    
    //next Button
    self.nextBtn=[[UIButton alloc]initWithFrame:CGRectMake(40, 2, 80, 29)];
    [self.nextBtn setTitle:@"上一页" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"abandoned_editButton.png"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(lastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.nextBtn];
    
    //last Button
    self.lastBtn=[[UIButton alloc]initWithFrame:CGRectMake(130, 2, 80, 29)];
    [self.lastBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.lastBtn setBackgroundImage:[UIImage imageNamed:@"abandoned_editButton.png"] forState:UIControlStateNormal];
    [self.lastBtn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.lastBtn];
    
    //pagestatus label
    self.pageStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(285,1,32,29)];
    self.pageStatusLabel.font = [UIFont boldSystemFontOfSize:20];
    self.pageStatusLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f];
    [self.viewBelowTableView addSubview:self.pageStatusLabel];
    
    //separated Line
    UILabel * sLine1 = [[UILabel alloc] initWithFrame:CGRectMake(40,0,self.widthOfMainView-40.0,1)];
    sLine1.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f];
    [self.viewBelowTableView addSubview:sLine1];
    
    [self.view addSubview:self.viewBelowTableView];
    
    //table  abandoned manuscripts
    self.scriptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.viewAboveTableView.frame),self.widthOfMainView,HEIGH_TO_FMAIN_VIEW(self.heightOfMainView, CGRectGetHeight(self.viewAboveTableView.frame), CGRectGetHeight(self.viewBelowTableView.frame))) style:UITableViewStylePlain];
    self.scriptTableView.delegate = self;
    self.scriptTableView.dataSource = self;
    self.scriptTableView.separatorStyle = NO;
    self.scriptTableView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:self.scriptTableView];
    
    //no data label
    self.noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,-3,100,30)];
    [self.noDataLabel setText:@"暂无数据"];
    self.noDataLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f];
    self.noDataLabel.hidden= NO;
    [self.scriptTableView addSubview:self.noDataLabel];
    
    [self reloadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editting animated:(BOOL)animated
{
    if (!editting)
    {
        for (ScriptItem *item in self.scriptItems)
        {
            item.checked = NO;
        }
    }
    [self.scriptTableView setEditing:editting animated:animated];
}


#pragma mark - PrivateMehod
- (void)reloadView{
    
    ManuscriptsDB* sendedScriptsDB = [[ManuscriptsDB alloc] init];
    
    self.scriptItems = [sendedScriptsDB getManuscriptListByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                           status:MANUSCRIPT_STATUS_ELIMINATION
                                                           pageNO:self.pageNum
                                                         pageSize:kPageSize];
    
    [self.deleteDic removeAllObjects];
    
    self.totalNumber.text = [NSString stringWithFormat:@"%ld",[self getTotalNum]];
    self.pageStatusLabel.text = [NSString stringWithFormat:@"%d/%ld",self.pageNum+1,[self getTotalPageNum]];
    if([self getTotalNum] > 0){
        self.viewBelowTableView.hidden = NO;
        self.noDataLabel.hidden = YES;
    }
    else {
        self.viewBelowTableView.hidden = YES;
        self.noDataLabel.hidden = NO;
    }
    [self.scriptTableView reloadData];
}

- (NSInteger)getTotalPageNum{
    
    NSInteger i = [self getTotalNum]/kPageSize;
    if ([self getTotalNum]%kPageSize>0) {
        i++;
    }
    return i;
    
}

- (NSInteger)getTotalNum{
    
    ManuscriptsDB *sDB = [[ManuscriptsDB alloc] init];
    NSInteger num = [sDB getNumberOfManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                status:MANUSCRIPT_STATUS_ELIMINATION]; //总数目量
    return num;
}

//进入编辑模式添加的动画
- (void)setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        
        self.checkImageView.center = pt;
        self.checkImageView.alpha = alpha;
        
        [UIView commitAnimations];
    }
    else
    {
        self.checkImageView.center = pt;
        self.checkImageView.alpha = alpha;
    }
}

//点击编辑按钮之后点击取消时，取消全选
- (void)allSelectCancel
{
    self.checkImageView.image = [UIImage imageNamed:@"ManulistCheckBox.png"];
    
    for (ScriptItem* item in self.scriptItems)
    {
        item.checked = NO;
    }
    [self.deleteDic removeAllObjects];
    
    [self.scriptTableView reloadData];
}

- (void)purgeManuscript:(NSString *)m_id
{
    AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
    NSMutableArray *accessoriesList = [[NSMutableArray alloc]init];
    accessoriesList = [adb getAccessoriesListByMId:m_id];
 
    for(Accessories* accessories in accessoriesList)
    {
        //删除物理文件
        if (![[NSFileManager defaultManager] removeItemAtPath:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessories.originName] error:nil])
        {
            NSLog(@"%@",@"视频物理文件删除成功");
        }
        
        [adb deleteAccessoriesByID:accessories.a_id];
        
    }
 
    ManuscriptsDB *sendedScriptsDB = [[ManuscriptsDB alloc] init];
    BOOL i = [sendedScriptsDB deleteManuscript:m_id];
    if (i) {
        NSLog(@"删除稿件成功！");
    }
    
}

#pragma mark - ActionMethod
//编辑函数
- (void)editFunction
{
    //cancel button 取消按钮出现，编辑按钮消失
    self.editButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.delButton.hidden = NO;
    self.reButton.hidden = NO;
  
    //imageView点击事件
    if (self.checkImageView == nil)
    {
        self.checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abandoned_unselectBg.png"]];
        [self.viewAboveTableView addSubview:self.checkImageView];
    }
    self.checkImageView.image = [UIImage imageNamed:@"abandoned_unselectBg.png"];
    self.checkImageView.frame = CGRectMake(0,0,25,24);//CGRectMake(0,0,20,19)
    self.checkImageView.center = CGPointMake(-CGRectGetWidth(self.checkImageView.frame) * 0.5,CGRectGetHeight(self.viewAboveTableView.bounds) * 0.5);
    self.checkImageView.alpha = 0.0;
    [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.viewAboveTableView.bounds) * 0.5) alpha:1.0 animated:YES];
    
    self.checkImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(allSelect)];
    [self.checkImageView addGestureRecognizer:singleTap];

    self.checkImageView.hidden = NO;
    //checkbox in tableview
    [self.scriptTableView setEditing:YES animated:YES];
    
    self.allSelected = NO;
    [self.scriptTableView reloadData];
}

//取消按钮
- (void)cancelFunction{
    self.checkImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    self.editButton.hidden = NO;
    self.delButton.hidden = YES;
    self.reButton.hidden = YES;
    //列表恢复原始状态
    [self allSelectCancel];
    
    //checkbox in tableview
    [self.scriptTableView setEditing:NO animated:NO];
    
    self.allSelected = NO;
    [self.scriptTableView reloadData];
}

//删除函数
- (void)deleteFuntion
{
    if([self.deleteDic count]>0)
    {
        for (ScriptItem* scriptItem in [self.deleteDic allValues]) {
            [self purgeManuscript:scriptItem.m_id];
        }
        
        [self.scriptItems removeObjectsInArray:[self.deleteDic allValues]];

        [self.deleteDic removeAllObjects];
        [self reloadView];
        //全选框  恢复"未选中"
        self.allSelected = NO;
        self.checkImageView.image = [UIImage imageNamed:@"abandoned_unselectBg.png"];
    }
}

//全选操作函数
- (void)allSelect
{
    //select all
    self.allSelected = !self.allSelected;
    
    if (!self.allSelected) {
        self.checkImageView.image = [UIImage imageNamed:@"abandoned_unselectBg.png"];
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = NO;
        }
        [self.deleteDic removeAllObjects];
    }
    else {
        self.checkImageView.image = [UIImage imageNamed:@"abandoned_selectBg.png"];
        
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = YES;
            [self.deleteDic setObject:item forKey:item.m_id];
        }
    }
    [self.scriptTableView reloadData];
}

//恢复操作函数:将淘汰稿件状态改变，成为在编稿件
- (void)recoveryFunction
{
    if([self.deleteDic count]>0)
    {
        for (ScriptItem* scriptItem in [self.deleteDic allValues]) {
            ManuscriptsDB *sendedScriptsDB = [[ManuscriptsDB alloc] init];
            BOOL i = [sendedScriptsDB setManuscriptStatus:MANUSCRIPT_STATUS_EDITING mId:scriptItem.m_id];
            if (i) {
                NSLog(@"恢复稿件成功！");
            }
        }
        [self.scriptItems removeObjectsInArray:[self.deleteDic allValues]];
   
        [self.deleteDic removeAllObjects];
        
        [self reloadView];
        
        //全选框  恢复"未选中"
        self.allSelected = NO;
        self.checkImageView.image = [UIImage imageNamed:@"abandoned_unselectBg.png"];
    }
}

- (void)nextPage
{
    if(self.pageNum+1<[self getTotalPageNum]){
        
        self.pageNum++;
        [self reloadView];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"您已处于第一页！"];
    }
    
}

- (void)lastPage
{
    if(self.pageNum+1>1)
    {
        self.pageNum--;
        [self reloadView];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"您已处于最后一页"];
    }
    
}

#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scriptItems count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"scriptItemCell";
    
    AbandonedScriptCell *cell = (AbandonedScriptCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AbandonedScriptCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        UILabel * grayBg = [[UILabel alloc] initWithFrame:CGRectMake(1,1,319,kTableCellHeight-2)];
        grayBg.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
        [backgrdView addSubview:grayBg];
        cell.backgroundView = backgrdView;

        [cell updateCell];
    }
    
    cell.backgroundColor = [UIColor whiteColor];//改变Cell背景颜色
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
    cell.lbText1.text = scriptItem.title;
    cell.lbText2.text = scriptItem.contents;
    cell.lbText3.text = [Utility getLocalTimeStamp:scriptItem.createTime];

    // Only load cached images; defer new downloads until scrolling ends
    if (!scriptItem.image)
    {
        //取得稿件附件列表：取得第一个附件将其放入淘汰列表的附图位置
        AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
        NSMutableArray *accessoriesList = [[NSMutableArray alloc]init];
        accessoriesList=[adb getAccessoriesListByMId:scriptItem.m_id];

        if([accessoriesList count]==0){  //如果没有附件时，加载默认图片

        }
        else{
            //根据附件类型确定加载视频图片、音频图片还是普通图片
            Accessories *firstAccess = [accessoriesList objectAtIndex:0];//第一个附件
            NSString *accessType = firstAccess.type;
            if (accessType == nil) {
                //            imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"bigpicholder.png"];
            }
            else {
                
                cell.accessaryView.image=nil;
                
                if ([accessType isEqualToString:@"PHOTO"]) {
                    
                    if (self.scriptTableView.dragging == NO && self.scriptTableView.decelerating == NO)
                    {
                        [self startIconDownload:scriptItem  forIndexPath:indexPath];
                    }
                    // if a download is deferred or in progress, return a placeholder image
                    cell.accessaryView.image = [self.imageList objectAtIndex:0];
           
                }
                else if([accessType isEqualToString:@"VIDEO"]){
                    scriptItem.image = [self.imageList objectAtIndex:1];
                    cell.accessaryView.image = [self.imageList objectAtIndex:1];
                }
                else if([accessType isEqualToString:@"AUDIO"]){
                    scriptItem.image = [self.imageList objectAtIndex:2];
                    cell.accessaryView.image = [self.imageList objectAtIndex:2];
                }
            }
        }
        
    }
    else
    {
        cell.accessaryView.image = scriptItem.image;
    }
    
    [cell setChecked:scriptItem.checked];
    return cell;
}

#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.scriptTableView.editing)//选中编辑
    {
        ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
        
        AbandonedScriptCell *cell = (AbandonedScriptCell*)[tableView cellForRowAtIndexPath:indexPath];
        scriptItem.checked = !scriptItem.checked;
        [cell setChecked:scriptItem.checked];
        
        if (scriptItem.checked) {
            
            [self.deleteDic setObject:scriptItem forKey:scriptItem.m_id];
        }
        else {
            [self.deleteDic removeObjectForKey:scriptItem.m_id];
        }

    }
    else {
        
        ScriptItem* item = [self.scriptItems objectAtIndex:indexPath.row];
        NewArticlesController *postViewController = [[NewArticlesController alloc] init];
        postViewController.manuscript_id = item.m_id;
        postViewController.operationType = @"detail";
        [self.navigationController pushViewController:postViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.scriptTableView.editing) {
        [self.deleteDic removeObjectForKey:indexPath];
    }	
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

- (UIImage *)getThumb:(NSString *)m_id{
    
    //取得稿件附件列表：取得第一个附件将其放入淘汰列表的附图位置
    AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
    NSMutableArray *accessoriesList = [[NSMutableArray alloc]init];
    accessoriesList = [adb getAccessoriesListByMId:m_id];

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
                imageName=[FILE_PATH_IN_PHONE stringByAppendingPathComponent:firstAccess.originName];
                NSLog(@"imageName is %@",imageName);
            }
            else if([accessType isEqualToString:@"VIDEO"]){
                imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"videoBg.png"];
            }
            else if([accessType isEqualToString:@"AUDIO"]){
                imageName=[NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"audioBg.png"];
                
            }
        }
    }
    return [Utility scale:[UIImage imageWithContentsOfFile:imageName] toSize:CGSizeMake(80,66) ];
}


// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    
    NSArray *visiblePaths = [self.scriptTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        ScriptItem *appRecord = [self.scriptItems objectAtIndex:indexPath.row];
        
        if (!appRecord.image) // avoid the app icon download if the app already has an icon
        {
            [self startIconDownload:appRecord forIndexPath:indexPath];
        }
    }
    
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    if ([self.scriptItems count]>indexPath.row)
    {
        ScriptItem *iconDownloader = [self.scriptItems objectAtIndex:indexPath.row];
        if (iconDownloader.image != nil)
        {
            ScriptCell *cell = (ScriptCell *)[self.scriptTableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.accessaryView.image = iconDownloader.image;
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
