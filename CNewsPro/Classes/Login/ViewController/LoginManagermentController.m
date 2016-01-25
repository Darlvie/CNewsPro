//
//  LoginManagermentController.m
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "LoginManagermentController.h"
#import "ServerAddress.h"
#import "ServerAddressDB.h"
#import "UIDevice+IdentifierAddition.h"
#import "Utility.h"
#import "AppDelegate.h"

@interface LoginManagermentController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSArray *settingItems;
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,copy) NSString *currentVersion;
@property (nonatomic,copy) NSString *currentServer;
@end

@implementation LoginManagermentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStyleGrouped];
    self.tableview.backgroundColor = [UIColor lightGrayColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    //导航视图
    [self.titleLabelAndImage setTitle:@"设置" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = RGB(71, 67, 66);
    
    self.settingItems = [[NSArray alloc] initWithObjects:@"系统版本",@"设备标识号", nil];
    
    //当前服务器
    ServerAddressDB *serverDB = [[ServerAddressDB alloc] init];
    ServerAddress *serverAddress = [serverDB getDefaultServer];
    self.currentServer = serverAddress.code;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadSendServer:(NSString *)serverURL {
    self.currentServer = serverURL;
    [self.tableview reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"systemItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    //表格标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = DETAIL_LABEL_COLOR;
    detailLabel.font = TF_FONT;
    
    titleLabel.frame = NETWORK_TITLE_CGRECT;
    titleLabel.text = self.settingItems[indexPath.row];
    
    if (indexPath.row == 0) {
        detailLabel.frame = NETWORK_DETAIL_CGRECT;
        detailLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [cell addSubview:detailLabel];
    } else if (indexPath.row == 1) {
        detailLabel.frame = CGRectMake(145, 0, 155, 45);
        detailLabel.numberOfLines = 2;
        detailLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        detailLabel.text = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
        [cell addSubview:detailLabel];
    }
    [cell addSubview:titleLabel];
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //版本更新检测
    if (indexPath.row == 0) {
        if (![self connectedToNetwork]) {
            [self showAlertWithType:AlertTypeAlert withString:@"请确认网络连接"];
            return;
        }
        [self showWait];
        dispatch_async(dispatch_get_current_queue(), ^{
            if ([Utility checkNewVersion]) {
                [self hideWaiting];
                [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"当前已是最新版本!"];
            } else {
                [self hideWaiting];
                [[[UIAlertView alloc] initWithTitle:@"新版本!"
                                            message:@"已经检测到最新版本，请下载更新!"
                                           delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"确认", nil] show];
            }
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *iTunesLink = @"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=541796756&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}


@end
