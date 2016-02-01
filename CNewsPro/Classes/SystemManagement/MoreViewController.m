//
//  MoreViewController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "MoreViewController.h"
#import "SendToAddressController.h"
#import "TemplateManageController.h"

@interface MoreViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *moreTableView;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航视图
    [self.titleLabelAndImage setTitle:@"更多" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:71.0f/255.0f green:67.0f/255.0f blue:66.0f/225.0f alpha:1.0f];
    
    self.moreTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStyleGrouped];
    self.moreTableView.backgroundView = nil;
    self.moreTableView.backgroundColor = [UIColor lightGrayColor];
    self.moreTableView.delegate = self;
    self.moreTableView.dataSource = self;
    [self.view addSubview:self.moreTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 1;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:nil];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    //表格标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.frame = CGRectMake(20, 5, 220, 35);
    
    //section
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleLabel.text = @"自定义发稿通道配置";
        }
        else {
            titleLabel.text = @"稿签模板配置";
        }
    }else
        if (indexPath.section == 1) {
            titleLabel.text = @"OA信息";
        }
    
    
    UIImageView *imageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"TempleView_detail"]];
    imageView.frame = CGRectMake(0, 0, 25, 25);
    cell.accessoryView = imageView;
    [cell addSubview:titleLabel];
    
    return cell;
}


#pragma mark - Table view delegate
//点击cell推出子列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            SendToAddressController *sendToAddressController = [[SendToAddressController alloc]init];
            sendToAddressController.sendToAddressType = SendToAddressTypeSelectCustom;
            [self.navigationController pushViewController:sendToAddressController animated:YES];
        }
        else {
            TemplateManageController *tagManageController = [[TemplateManageController alloc]init];
            [self.navigationController pushViewController:tagManageController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}
















@end
