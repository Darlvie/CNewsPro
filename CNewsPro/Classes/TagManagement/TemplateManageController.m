//
//  TemplateManageController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "TemplateManageController.h"
#import "ManuscriptTemplate.h"
#import "ManuscriptTemplateDB.h"
#import "AppDelegate.h"
#import "NewTagDetailViewController.h"

@interface TemplateManageController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation TemplateManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //导航试图
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:71.0f/255.0f green:67.0f/255.0f blue:66.0f/225.0f alpha:1.0f];
    
    if (self.viewTemplate == ViewTemplateEdit) {
        [self.titleLabelAndImage setTitle:@"稿签管理" forState:UIControlStateNormal];
    }
    else {
        [self.titleLabelAndImage setTitle:@"选择稿签" forState:UIControlStateNormal];
    }
    
    [self initializtion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializtion {
    //通过用户名称及稿签类型获取系统稿签
    ManuscriptTemplateDB* manuscriptemplatedb = [[ManuscriptTemplateDB alloc] init];
    NSString *loginNameInf = [USERDEFAULTS objectForKey:LOGIN_NAME];
    self.sysTagArray = [[NSMutableArray alloc] initWithArray:[manuscriptemplatedb getSystemTemplate:loginNameInf type:MANUSCRIPT_TEMPLATE_TYPE]];
    self.customTagArray = [[NSMutableArray alloc] initWithArray:[manuscriptemplatedb getManuScriptTemplate:loginNameInf type:MANUSCRIPT_TEMPLATE_TYPE]];
    if ([self.sysTagArray count]==0) {
        [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"当前系统稿签没有进行同步，请到系统设置里进行稿签同步"];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.sysTagArray count];
    }
    
    return [self.customTagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    if(self.viewTemplate == ViewTemplateEdit)
    {
        UIImageView *imageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"TempleView_detail"]];
        imageView.frame = CGRectMake(0, 0, 25, 25);
        cell.accessoryView = imageView;
    }
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=[UIColor blackColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:16];
    UIButton *isdefaultButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 45)];
    UIImageView *isdefaultImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 25, 25)];
    isdefaultImage.userInteractionEnabled = YES;
    isdefaultButton.tag = indexPath.row;
    [isdefaultButton addTarget:self action:@selector(tappedisdefaultButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (indexPath.section == 0) {
        ManuscriptTemplate *manuscriptTemplate = [self.sysTagArray objectAtIndex:indexPath.row];
        titleLabel.text = manuscriptTemplate.name;
        titleLabel.frame = CGRectMake(20, 5, 250, 35);
    }
    else {
        ManuscriptTemplate *manuscriptTemplate = [self.customTagArray objectAtIndex:indexPath.row];
        titleLabel.text = manuscriptTemplate.name;
        titleLabel.frame = CGRectMake(60, 5, 250, 35);
        if ([manuscriptTemplate.isDefault isEqualToString:@"1"]) {
            self.defaultManuscriptTemplate = manuscriptTemplate;
            [isdefaultImage setImage:[UIImage imageNamed:@"Selected"]];
        }
        else {
            [isdefaultImage setImage:[UIImage imageNamed:@"Unselected"]];
        }
        [cell addSubview:isdefaultImage];
        [cell addSubview:isdefaultButton];
    }

    [cell addSubview:titleLabel];
    return cell;
}


#pragma mark - Table view delegate
//点击cell推出子列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewTemplate == ViewTemplateSelect) {
        if (indexPath.section == 0) {
            
            [self.delegate  returnManuScriptTemplate:[self.sysTagArray objectAtIndex:indexPath.row]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            
            [self.delegate  returnManuScriptTemplate:[self.customTagArray objectAtIndex:indexPath.row]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        
    }
    else {
        NewTagDetailViewController *tagDetailController = [[NewTagDetailViewController alloc] init];
        tagDetailController.templateType = TemplateTypeExist;
        
        if (indexPath.section == 0) {
            tagDetailController.manuscriptTemplate = [self.sysTagArray objectAtIndex:indexPath.row];
            tagDetailController.isSystemTemplate = @"SystemTemplate";
        }
        else {
            tagDetailController.manuscriptTemplate = [self.customTagArray objectAtIndex:indexPath.row];
        }
        tagDetailController.delegate=self;
        [self.navigationController pushViewController:tagDetailController animated:YES];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}


//设置表头
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.viewTemplate == ViewTemplateSelect) {
        return 0;
    }
    else {
        return 40.0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.viewTemplate == ViewTemplateSelect) {
        return NULL;
    }
    else {
        UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        headview.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 200, 20)];
        
        [lbText setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:17]];
        if (section == 0) {
            lbText.text = @"系统稿签模板";
        }
        else {
            lbText.text = @"自定义稿签模板";
        }
        
        lbText.backgroundColor = [UIColor clearColor];
        lbText.textColor = [UIColor blackColor];
        [headview addSubview:lbText];
        if (section == 1) {
            UIButton *bButton = [[UIButton alloc]initWithFrame:CGRectMake(272, 10, 30, 30)];
            [bButton setImage:[UIImage imageNamed:@"TemplateAddIcon"] forState:UIControlStateNormal];
            bButton.tag = 9;
            [bButton addTarget:self action:@selector(plusTag) forControlEvents:UIControlEventTouchUpInside];
            [headview addSubview:bButton];
        }
        return headview;
        
    }
} 

#pragma mark - Table view edit mode

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.defaultManuscriptTemplate) {
        self.defaultManuscriptTemplate = nil;
    }
    ManuscriptTemplate* manuscriptTemplate = [self.customTagArray objectAtIndex:indexPath.row];
    ManuscriptTemplateDB* deleteTagDB=[[ManuscriptTemplateDB alloc] init];
    [deleteTagDB deleteManuScriptTemplate:manuscriptTemplate.mt_id];

    [self.customTagArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - Private Method

//点击cell上的isdefaultButton进行默认稿签选择
-(void)tappedisdefaultButton:(UIButton *)button
{
    if (self.viewTemplate != ViewTemplateSelect) {
        ManuscriptTemplateDB* defaultTagDB = [[ManuscriptTemplateDB alloc] init];
        if (self.defaultManuscriptTemplate) {
            self.defaultManuscriptTemplate.isDefault = @"0";
            [defaultTagDB updateManuscriptTemplate:self.defaultManuscriptTemplate];
        }
        self.defaultManuscriptTemplate = [self.customTagArray objectAtIndex:button.tag];
        self.defaultManuscriptTemplate.isDefault = @"1";
        [defaultTagDB updateManuscriptTemplate:self.defaultManuscriptTemplate];
        [self.tableView reloadData];
    }
    else {
        //回传选中得稿签模板
        [self.delegate  returnManuScriptTemplate:[self.customTagArray objectAtIndex:button.tag]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//点击cell上的isdefaultButton进行默认稿签选择
- (void)tapPedisDefaultButton:(UIButton *)button {
    if (self.viewTemplate != ViewTemplateSelect) {
        ManuscriptTemplateDB* defaultTagDB=[[ManuscriptTemplateDB alloc] init];
        if (self.defaultManuscriptTemplate) {
            self.defaultManuscriptTemplate.isDefault = @"0";
            [defaultTagDB updateManuscriptTemplate:self.defaultManuscriptTemplate];
        }
        self.defaultManuscriptTemplate = [self.customTagArray objectAtIndex:button.tag];
        self.defaultManuscriptTemplate.isDefault = @"1";
        [defaultTagDB updateManuscriptTemplate:self.defaultManuscriptTemplate];

        [self.tableView reloadData];
    }
    else {
        //回传选中得稿签模板
        [self.delegate  returnManuScriptTemplate:[self.customTagArray objectAtIndex:button.tag]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}


- (void)plusTag {
    NewTagDetailViewController *tagDetailController = [[NewTagDetailViewController alloc]init];
    [tagDetailController.titleLabelAndImage setTitle:@"新建稿签" forState:UIControlStateNormal];
    tagDetailController.templateType = TemplateTypeNew;
    [self.navigationController pushViewController:tagDetailController animated:YES];

}


- (void)reloadtable {
    [self initializtion];
    [self.tableView reloadData];
}

@end
