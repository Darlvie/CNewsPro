//
//  AuditNewsViewController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AuditNewsViewController.h"
#import "EditScriptCell.h"
#import "AuditNewsItem.h"
#import "DetailAuditNewsViewController.h"
#import "AppDelegate.h"
#import "RequestMaker.h"
#import "Utility.h"

static const NSInteger kPageSize = 50;
static const NSInteger kTableViewCellHeight = 70;

@interface AuditNewsViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation AuditNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"editingScript_Title.png"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"审查列表" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    
    //table header view
    self.viewAboveTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,44.0f,320.0f,32.0f)];
    
    //separated Line
    UILabel * sLine = [[UILabel alloc] initWithFrame:CGRectMake(40,32,281,1)];
    sLine.backgroundColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    [self.viewAboveTableView addSubview:sLine];
    
    //total number
    self.totalNumber = [[UILabel alloc]initWithFrame:CGRectMake(263,1,55,30)];
    self.totalNumber.font = [UIFont boldSystemFontOfSize:20];
    self.totalNumber.textAlignment = NSTextAlignmentRight;
    self.totalNumber.textColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    [self.viewAboveTableView addSubview:self.totalNumber];
    
    [self.view addSubview:self.viewAboveTableView];
    
    //table below view
    self.viewBelowTableView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,self.view.frame.size.height-60,320.0f,32.0f)];
    
    //next Button
    self.nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 2, 80, 29)];
    [self.nextBtn setTitle:@"上一页" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"editingScript_edit.png"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(lastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.nextBtn];
    
    //last Button
    self.lastBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 2, 80, 29)];
    [self.lastBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.lastBtn setBackgroundImage:[UIImage imageNamed:@"editingScript_edit.png"] forState:UIControlStateNormal];
    [self.lastBtn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBelowTableView addSubview:self.lastBtn];
    
    //pagestatus label
    self.pageStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(285,1,32,29)];
    self.pageStatusLabel.font = [UIFont boldSystemFontOfSize:20];
    self.pageStatusLabel.textColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    [self.viewBelowTableView addSubview:self.pageStatusLabel];
    
    
    UILabel * sLine1 = [[UILabel alloc] initWithFrame:CGRectMake(40,0,281,1)];
    sLine1.backgroundColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    [self.viewBelowTableView addSubview:sLine1];
    
    [self.view addSubview:self.viewBelowTableView];
    
    //tableview
    self.scriptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,77.0f,320.0f,self.view.frame.size.height-140) style:UITableViewStylePlain];
    self.scriptTableView.delegate = self;
    self.scriptTableView.dataSource = self;
    self.scriptTableView.separatorStyle = NO;
    self.scriptTableView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:self.scriptTableView];
    
    //no data label
    self.noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,-3,100,30)];
    [self.noDataLabel setText:@"暂无数据"];
    self.noDataLabel.textColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    self.noDataLabel.hidden= NO;
    [self.scriptTableView addSubview:self.noDataLabel];
    
    //初始化基础数据
    self.pageNum = 0;
    self.scriptItems = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self reloadView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark 页面控件按钮

-(void) nextPage
{
    if(self.pageNum+1<[self getTotalPageNum]){
        
        self.pageNum++;
        [self getNewsList];
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
        [self getNewsList];
    }
    else {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"您已处于第一页！"];
    }
    
}

//页面加载完成时刷新数据
- (void)viewDidAppear:(BOOL)animated
{
    [self getNewsList];
}

-(void)getNewsList
{
    [RequestMaker getAuditNewsByPageNum:self.pageNum size:kPageSize delegate:self];
}

-(void)requestDidFinish:(NSDictionary*)responseInfo
{
    if ([[responseInfo objectForKey:REQUEST_STATUS] isEqualToString:REQUEST_FAIL] ) {
        NSLog(@"服务器无响应");
        if (self.pageNum>0) {
            self.pageNum--;
        }
        return;
    }
    
    NSMutableDictionary *responseDic = [Utility parseAuditNewsListFromData:[responseInfo objectForKey:RESPONSE_DATA]];
    self.scriptItems = [responseDic objectForKey:@"items"];
    self.totalNum = [[responseDic objectForKey:@"totalCount"]integerValue];
    
    [self reloadView];
}

-(void)reloadView
{
    self.totalNumber.text = [NSString stringWithFormat:@"%ld",[self getTotalNum]];
    self.pageStatusLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.pageNum+1,[self getTotalPageNum]];
    
    if([self getTotalNum]>0){
        
        self.viewBelowTableView.hidden = NO;
        
        self.noDataLabel.hidden = YES;
    }
    else {
        
        self.viewBelowTableView.hidden = YES;
        
        self.noDataLabel.hidden = NO;
    }
    [self.scriptTableView reloadData];
}

- (NSInteger)getTotalNum
{
    return self.totalNum;
}

-(NSInteger)getTotalPageNum{
    
    NSInteger i = [self getTotalNum] / kPageSize;
    if (([self getTotalNum] % kPageSize)>0) {
        i++;
    }
    return i;
    
}

#pragma mark -
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
    
    static NSString *CellIdentifier = @"EditingscriptItemCell";
    
    //使用自定义cell
    EditScriptCell *cell = (EditScriptCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EditScriptCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        UILabel *grayBg = [[UILabel alloc] initWithFrame:CGRectMake(1,1,319,kTableViewCellHeight-2)];
        grayBg.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1.0f];;
        [backgrdView addSubview:grayBg];
        cell.backgroundView = backgrdView;
        [cell updateCell];
    }
    //改变Cell背景颜色
    cell.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:59.0f/255.0f blue:59.0f/255.0f alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    AuditNewsItem* scriptItem = [self.scriptItems objectAtIndex:indexPath.row];
    cell.m_lbText1.text = scriptItem.anAbstract;
    cell.m_lbText2.text = scriptItem.createTime;
    cell.m_accessaryView.image = [UIImage imageNamed:@"videoBg"];
    cell.m_lbText3.text = scriptItem.author;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AuditNewsItem* item = [self.scriptItems objectAtIndex:indexPath.row];
    DetailAuditNewsViewController *detailNewsView = [[DetailAuditNewsViewController alloc]init];
    detailNewsView.newsId = item.auditNewsId;
    [self.navigationController pushViewController:detailNewsView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
