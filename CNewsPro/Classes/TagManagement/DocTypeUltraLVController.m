//
//  DocTypeUltraLVController.m
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "DocTypeUltraLVController.h"
#import "NewsCategory.h"
#import "NewsCategoryDB.h"
#import "NewTagDetailViewController.h"

static const NSInteger kTableViewCellHeight = 50;

@interface DocTypeUltraLVController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation DocTypeUltraLVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.docTypeUltraLVView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStylePlain];
    self.docTypeUltraLVView.delegate = self;
    self.docTypeUltraLVView.dataSource = self;
    [self.view addSubview:self.docTypeUltraLVView];
    
    //导航试图
    [self.titleLabelAndImage setTitle:self.newsCategoryTriLV.name forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = RGB(60, 90, 154);
    
    
    //从数据库读取稿件分类三级列表
    NewsCategoryDB* NewsCategorydb = [[NewsCategoryDB alloc] init];
    self.docTypeUltraLVArray = [[NSMutableArray alloc] initWithArray:[NewsCategorydb getNewsCategoryListBySupernewsCategory:self.newsCategoryTriLV Type:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docTypeUltraLVArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocTypeUltraLVCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
    }
   
    UILabel *tagTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 17, 200, 21)];
    [tagTitle setFont:[UIFont fontWithName:@"Georgia-Bold" size:16]];
    tagTitle.backgroundColor=[UIColor clearColor];
    tagTitle.textColor=[UIColor blackColor];
    
    NewsCategory*  newsCategory = [self.docTypeUltraLVArray objectAtIndex:indexPath.row];
    tagTitle.text = newsCategory.name;
    [cell addSubview:tagTitle];
    
    NewsCategoryDB* subNewsCategorydb=[[NewsCategoryDB alloc] init];
    NSMutableArray *subNewsCategoryArray = [[NSMutableArray alloc] initWithArray:[subNewsCategorydb getNewsCategoryListBySupernewsCategory:newsCategory Type:0]];

    if([subNewsCategoryArray count]){
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark - Table view delegate
//点击表格进行稿件分类选择并返回稿签模版
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCategory*  newsCategory = [self.docTypeUltraLVArray objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger i=[self.navigationController.viewControllers count]-5;
    [[self.navigationController.viewControllers objectAtIndex:i] setNewsCategory:[self.newsCategoryTriLVInf stringByAppendingFormat:@"-%@",newsCategory.name] getNewsCategoryID:newsCategory.code];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}


@end
