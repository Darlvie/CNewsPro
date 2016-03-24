//
//  SendedScriptController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "SendedScriptController.h"
#import "ManuscriptsDB.h"
#import "ScriptItem.h"
#import "AccessoriesDB.h"
#import "Accessories.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "MultipleScriptCell.h"
#import "NewArticlesController.h"

static const NSInteger kPageSize = 50;
static const NSInteger kTableCellHeight = 70;

@interface SendedScriptController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *deleteDic;
@property (nonatomic,assign) int pageNum;
@property (nonatomic,strong) NSMutableArray *imageList;
@property (nonatomic,strong) UIView *viewAboveTableView;
@property (nonatomic,strong) UIView *viewBelowTableView;
@property (nonatomic,strong) UITableView *scriptTableView;
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UILabel *totalNumber;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UIButton *lastBtn;
@property (nonatomic,strong) UILabel *pageStatusLabel;
@property (nonatomic,strong) UILabel *noDataLabel;
@property (nonatomic,strong) NSMutableArray *scriptItems;
@property (nonatomic,assign) BOOL allSelected;
@property (nonatomic,strong) UIButton *selectedButton;
@end

@implementation SendedScriptController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.deleteDic = [[NSMutableDictionary alloc]init];
    
    //sent manuscripts data binding
    self.pageNum = 0;
    self.imageList = [[NSMutableArray alloc] init];
    [self.imageList addObject:[UIImage imageNamed:@"bigpicholder.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"videoBg.png"]];
    [self.imageList addObject:[UIImage imageNamed:@"audioBg.png"]];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"sent_icon.png"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"已发列表" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = RGB(60, 90, 154);
    
    //table header view
    self.viewAboveTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.titleLabelAndImage.frame),self.widthOfMainView,34.0f)];
    self.viewAboveTableView.backgroundColor = [UIColor whiteColor];
    
    //edit Button
    self.editButton=[[UIButton alloc]initWithFrame:CGRectMake(40,1,60,30)];//CGRectMake(40,10,48,22)
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
    
    //delete button
    self.deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(112,1,22,30)];
    self.deleteButton.hidden = YES;
    [self.deleteButton setImage:[UIImage imageNamed:@"delete_filled"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteFuntion) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAboveTableView addSubview:self.deleteButton];
    
    //separated Line
    UILabel * sLine = [[UILabel alloc] initWithFrame:CGRectMake(40,32,self.widthOfMainView-40.0,1)];
    sLine.backgroundColor = [UIColor lightGrayColor];
    [self.viewAboveTableView addSubview:sLine];
    
    //total number
    self.totalNumber = [[UILabel alloc]initWithFrame:CGRectMake(263,1,55,30)];
    self.totalNumber.font = [UIFont boldSystemFontOfSize:20];
    self.totalNumber.textColor = RGB(60, 90, 154);
    self.totalNumber.textAlignment=NSTextAlignmentRight;
    [self.viewAboveTableView addSubview:self.totalNumber];
    [self.view addSubview:self.viewAboveTableView];
    
    //table below view
    self.viewBelowTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,self.view.frame.size.height-40,SCREEN_WIDTH,40.0f)];
    self.viewBelowTableView.backgroundColor = [UIColor whiteColor];
    
    //next Button
    self.nextBtn=[[UIButton alloc]initWithFrame:CGRectMake(40, 2, 80, 29)];
    [self.nextBtn setTitle:@"上一页" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.nextBtn setBackgroundColor:RGB(60, 90, 154)];
    self.nextBtn.layer.cornerRadius = 3.0f;
    self.nextBtn.layer.masksToBounds = YES;
    [self.nextBtn addTarget:self action:@selector(lastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.nextBtn];
    
    //last Button
    self.lastBtn=[[UIButton alloc]initWithFrame:CGRectMake(130, 2, 80, 29)];
    [self.lastBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.lastBtn setBackgroundColor:RGB(60, 90, 154)];
    self.lastBtn.layer.cornerRadius = 3.0f;
    self.lastBtn.layer.masksToBounds = YES;
    [self.lastBtn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.lastBtn];
    
    //pagestatus label
    self.pageStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(285,1,32,29)];
    self.pageStatusLabel.font = [UIFont boldSystemFontOfSize:20];
    self.pageStatusLabel.textColor = RGB(60, 90, 154);
    [self.viewBelowTableView addSubview:self.pageStatusLabel];
    
    //separated Line
    UILabel * sLine1 = [[UILabel alloc] initWithFrame:CGRectMake(40,0,self.widthOfMainView-40.0,1)];
    sLine1.backgroundColor = [UIColor lightGrayColor];
    [self.viewBelowTableView addSubview:sLine1];
    
    [self.view addSubview:self.viewBelowTableView];
    
    self.scriptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(self.viewAboveTableView.frame),self.widthOfMainView,HEIGH_TO_FMAIN_VIEW(self.heightOfMainView, CGRectGetHeight(self.viewAboveTableView.frame), CGRectGetHeight(self.viewBelowTableView.frame))) style:UITableViewStylePlain];
    self.scriptTableView.delegate=self;
    self.scriptTableView.dataSource=self;
    self.scriptTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.scriptTableView.backgroundColor = RGB(245, 245, 245);
    self.scriptTableView.tableFooterView = [[UIView alloc] init];
    self.scriptTableView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:self.scriptTableView];
    
    //no data label
    self.noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,-3,100,30)];
    [self.noDataLabel setText:@"暂无数据"];
    self.noDataLabel.textColor = RGB(60, 90, 154);
    self.noDataLabel.hidden= NO;
    [self.scriptTableView addSubview:self.noDataLabel];

    [self reloadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pravite Method
- (void)reloadView {

    ManuscriptsDB *sendedScriptsDB = [[ManuscriptsDB alloc] init];
    self.scriptItems = [sendedScriptsDB getManuscriptListByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                           status:MANUSCRIPT_STATUS_SENT
                                                           pageNO:self.pageNum
                                                         pageSize:kPageSize];
    
    [self.deleteDic removeAllObjects];
    [self.scriptTableView reloadData];
    
    self.totalNumber.text = [NSString stringWithFormat:@"%ld",[self getTotalNum]];
    self.pageStatusLabel.text = [NSString stringWithFormat:@"%d/%ld",self.pageNum+1,[self getTotalPageNum]];
    
    
    if([self getTotalNum]>0){
        
        self.viewBelowTableView.hidden = NO;
        self.scriptTableView.backgroundColor = RGB(245, 245, 245);
        self.noDataLabel.hidden = YES;
    }
    else {
        
        self.viewBelowTableView.hidden = YES;
        self.scriptTableView.backgroundColor = [UIColor whiteColor];
        self.noDataLabel.hidden = NO;
   
    }
   
}


- (NSInteger)getTotalPageNum{
    
    NSInteger i = [self getTotalNum] / kPageSize;
    if ([self getTotalNum] % kPageSize>0) {
        i++;
    }
    return i;
    
}

//获得此状态下的稿件总数目
- (NSInteger)getTotalNum{
    
    ManuscriptsDB* sDB = [[ManuscriptsDB alloc] init];
    NSInteger num= [sDB getNumberOfManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                status:MANUSCRIPT_STATUS_SENT]; //总数目量
    return num;
}

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
    [self.scriptTableView setEditing:editting animated:animated];
}

- (void)purgeManuscript:(NSString *) m_id
{
    AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
    NSMutableArray *accessoriesList=[adb getAccessoriesListByMId:m_id];

    for(Accessories* accessories in accessoriesList)
    {
        //删除物理文件
        if (![[NSFileManager defaultManager] removeItemAtPath:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessories.originName] error:nil])
        {
            NSLog(@"%@",@"视频物理文件删除成功");
        }
        
        [adb deleteAccessoriesByID:accessories.a_id];
        
    }

    ManuscriptsDB* sendedScriptsDB = [[ManuscriptsDB alloc] init];
    BOOL i = [sendedScriptsDB deleteManuscript:m_id];
    if (i) {
        NSLog(@"删除稿件成功！");
    }
}


#pragma mark - Action Method
- (void)editButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.editButton setTitle:@"取消" forState:UIControlStateNormal];
        self.deleteButton.hidden = NO;
        self.selectedButton.hidden = NO;
        
        [self.scriptTableView setEditing:YES animated:YES];
        self.allSelected = NO;
        [self.scriptTableView reloadData];
    } else {
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.deleteButton.hidden = YES;;
        self.selectedButton.hidden = YES;
        
        //列表恢复原始状态
        [self allSelectCancel];
        //checkbox in tableview
        [self.scriptTableView setEditing:NO animated:NO];
        self.allSelected = NO;
        [self.scriptTableView reloadData];
    }
}


//全部选择
- (void)allSelect
{
    self.selectedButton.selected = !self.selectedButton.selected;
    self.allSelected = !self.allSelected;
    if (!self.allSelected) {
        [self.deleteDic removeAllObjects];
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = NO;
            
        }
    }
    else {
        for (ScriptItem* item in self.scriptItems)
        {
            item.checked = YES;
            [self.deleteDic setObject:item forKey:item.m_id];
        }
    }
    
    [self.scriptTableView reloadData];
}


//点击编辑按钮之后点击取消时，取消全选
- (void)allSelectCancel
{
    for (ScriptItem* item in self.scriptItems)
    {
        item.checked = NO;
    }
    [self.deleteDic removeAllObjects];
    
    [self.scriptTableView reloadData];
}

//删除所选项
- (void)deleteFuntion
{
    if([self.deleteDic count]>0){
        
        for (ScriptItem* scriptItem in [self.deleteDic allValues]) {
            [self purgeManuscript:scriptItem.m_id];
            
        }
        [self.scriptItems removeObjectsInArray:[self.deleteDic allValues]];

        [self.deleteDic removeAllObjects];
        //重新加载已发稿件列表
        [self  reloadView];
      
        //全选框  恢复"未选中"
        self.allSelected = NO;
    }
}

-(void) nextPage
{
    if(self.pageNum+1<[self getTotalPageNum]){
        
        self.pageNum++;
        [self reloadView];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"您已处于最后一页"];
    }
    
}

-(void)lastPage
{
    if(self.pageNum+1>1)
    {
        self.pageNum--;
        [self reloadView];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"您已处于第一页！"];
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
    
    //使用自定义cell
    MultipleScriptCell *cell = (MultipleScriptCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MultipleScriptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
    cell.scriptItem = scriptItem;
    
    // Only load cached images; defer new downloads until scrolling ends
    if (!scriptItem.image)
    {
        //取得稿件附件列表：取得第一个附件将其放入淘汰列表的附图位置
        AccessoriesDB *adb =  [[AccessoriesDB alloc]init];
        NSMutableArray *accessoriesList=[adb getAccessoriesListByMId:scriptItem.m_id];

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
                
                cell.cellImageView.image=nil;
                
                if ([accessType isEqualToString:@"PHOTO"]) {
                    
                    if (self.scriptTableView.dragging == NO && self.scriptTableView.decelerating == NO)
                    {
                        [self startIconDownload:scriptItem  forIndexPath:indexPath];
                    }
                    // if a download is deferred or in progress, return a placeholder image
                    cell.cellImageView.image = [self.imageList objectAtIndex:0];
                }
                else if([accessType isEqualToString:@"VIDEO"]){
                    scriptItem.image = [self.imageList objectAtIndex:1];
                    cell.cellImageView.image = [self.imageList objectAtIndex:1];
                }
                else if([accessType isEqualToString:@"AUDIO"]){
                    scriptItem.image = [self.imageList objectAtIndex:2];
                    cell.cellImageView.image =[self.imageList objectAtIndex:2];
                }
            }
        }
     
    }
    else
    {
        cell.cellImageView.image = scriptItem.image;
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
    if (self.scriptTableView.editing)
    {
        ScriptItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
        MultipleScriptCell *cell = (MultipleScriptCell *)[tableView cellForRowAtIndexPath:indexPath];
        scriptItem.checked = !scriptItem.checked;
        [cell setChecked:scriptItem.checked];
        if (scriptItem.checked) {
            [self.deleteDic setObject:scriptItem forKey:scriptItem.m_id];
        }
        else{
            [self.deleteDic removeObjectForKey:scriptItem.m_id];
        }
        
    }
    else {
        
        ScriptItem* item = [self.scriptItems objectAtIndex:indexPath.row];
        NewArticlesController *postViewController=[[NewArticlesController alloc] init];
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
    accessoriesList=[adb getAccessoriesListByMId:m_id];
    
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
                imageName = [NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"videoBg.png"];
            }
            else if([accessType isEqualToString:@"AUDIO"]){
                imageName = [NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle]resourcePath],@"/",@"audioBg.png"];
                
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
    if ([self.scriptItems count]>indexPath.row) {
        ScriptItem *iconDownloader = [self.scriptItems objectAtIndex:indexPath.row];
        if (iconDownloader.image != nil)
        {
            MultipleScriptCell *cell = (MultipleScriptCell *)[self.scriptTableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.cellImageView.image = iconDownloader.image;
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
