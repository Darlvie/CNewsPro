//
//  SendToAddressController.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "SendToAddressController.h"
#import "Utility.h"
#import "User.h"
#import "EmployeeSendToAddressDB.h"
#import "EmployeeSendToAddress.h"
#import "SendToAddressDB.h"
#import "SendToAddress.h"

@interface SendToAddressController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation SendToAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sendToAddressView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView) style:UITableViewStylePlain];
    self.sendToAddressView.delegate = self;
    self.sendToAddressView.dataSource = self;
    [self.view addSubview:self.sendToAddressView];
    
    //导航试图
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    
    if (self.sendToAddressType == SendToAddressTypeCustom) {
        [self.titleLabelAndImage setTitle:@"发稿通道" forState:UIControlStateNormal];
    }
   
    //添加保存按钮
    self.rightButton.userInteractionEnabled = YES;
    [self.rightButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendToAddressDictionary = [[NSMutableDictionary alloc]init];
    self.sendToAddressArray = [[NSMutableArray alloc]init];

    //从数据库读取稿件分类一级列表
    [self readManuscriptClassFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//从数据库读取稿件分类一级列表
- (void)readManuscriptClassFromDB {
    //判断是否是用于用户自定地址簿，还是普通稿签详情
    if (self.sendToAddressType == SendToAddressTypeCustom) {
        //是否存在网络发稿地址
        if ([[Utility sharedSingleton].userInfo.sendAdressList count]) {
            [self.sendToAddressArray addObjectsFromArray:[Utility sharedSingleton].userInfo.sendAdressList];
        }
        //用户是否有正式发稿权限
        if ([[Utility sharedSingleton].userInfo.rightSendNews isEqualToString:@"true"]) {
            EmployeeSendToAddressDB *estAddressDB = [[EmployeeSendToAddressDB alloc] init];
            //用户是否有自定义地址簿
            if ([estAddressDB getESTAddressListLoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]].count) {
                [self.sendToAddressArray addObjectsFromArray:[estAddressDB getESTAddressListLoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]]];
                //将用户已选地址标记为已选
                if (self.selectedSendToAddressArray.count) {
                    for (EmployeeSendToAddress *estAddress in self.sendToAddressArray) {
                        for (int i = 0; i < self.selectedSendToAddressArray.count; i++) {
                            if ([estAddress.name isEqualToString:[self.selectedSendToAddressArray objectAtIndex:i]]) {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sendToAddressArray indexOfObject:estAddress] inSection:0];
                                [self.sendToAddressDictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                            }
                        }
                    }
                }
            } else {
                //没有地址簿就加载整个本地地址列表
                self.sendToAddressType = SendToAddressTypeNoCustom;
                SendToAddressDB *stAddressDB = [[SendToAddressDB alloc] init];
                [self.sendToAddressArray addObjectsFromArray:[stAddressDB getSendToAddressList]];
                
                //将用户已选地址标记为已选
                if (self.selectedSendToAddressArray.count) {
                    for (SendToAddress *stAddress in self.sendToAddressArray) {
                        for (int i = 0; i < self.selectedSendToAddressArray.count; i++) {
                            if ([stAddress.name isEqualToString:[self.selectedSendToAddressArray objectAtIndex:i]]) {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sendToAddressArray indexOfObject:stAddress] inSection:0];
                                [self.sendToAddressDictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                            }
                        }
                    }
                }
            }
        }
    } else {
        //该页面用于用户选择用户地址簿
        if ([[Utility sharedSingleton].userInfo.rightSendNews isEqualToString:@"true"])
        {
            SendToAddressDB* SendToAddressdb=[[SendToAddressDB alloc] init];
            [self.sendToAddressArray addObjectsFromArray:[SendToAddressdb getSendToAddressList]];

            EmployeeSendToAddressDB* EmployeeSendToAddressdb=[[EmployeeSendToAddressDB alloc] init];
            NSMutableArray *CustomAddress = [EmployeeSendToAddressdb getESTAddressListLoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
            //将用户已选地址标记为已选
            if ([CustomAddress count]) {
                for (int i=0; i<[CustomAddress count]; i++) {
                    EmployeeSendToAddress* employeeSendToAddress = [CustomAddress objectAtIndex:i];
                    for (SendToAddress* sendToAddress in self.sendToAddressArray) {
                        if ([sendToAddress.name isEqualToString:employeeSendToAddress.name]) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sendToAddressArray indexOfObject:sendToAddress] inSection:0];
                            [self.sendToAddressDictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                        }
                    }
                }
            }
        } else {
            [self.sendToAddressArray addObjectsFromArray:[Utility sharedSingleton].userInfo.sendAdressList];
        }

    }
}


- (void)complete {
    //完成后退出，针对已有用户地址簿的情况
    if (self.sendToAddressType == SendToAddressTypeCustom) {
        NSString *sendToAddressNameResult = [[NSString alloc]init];
        NSString *sendToAddressIDResult = [[NSString alloc]init];

        NSIndexPath *lastIndexPath = [[self.sendToAddressDictionary allKeysForObject:[NSNumber numberWithBool:YES]] lastObject];
        for (NSIndexPath *indexPath in [self.sendToAddressDictionary allKeysForObject:[NSNumber numberWithBool:YES]]) {
            if (indexPath == lastIndexPath) {
                EmployeeSendToAddress*  employeeSendToAddress = [self.sendToAddressArray objectAtIndex:indexPath.row];
                sendToAddressNameResult = [sendToAddressNameResult stringByAppendingFormat:@"%@",employeeSendToAddress.name];
                sendToAddressIDResult = [sendToAddressIDResult stringByAppendingFormat:@"%@",employeeSendToAddress.code];
            }
            else {
                EmployeeSendToAddress*  employeeSendToAddress = [self.sendToAddressArray objectAtIndex:indexPath.row];
                sendToAddressNameResult = [sendToAddressNameResult stringByAppendingFormat:@"%@，",employeeSendToAddress.name];
                sendToAddressIDResult = [sendToAddressIDResult stringByAppendingFormat:@"%@，",employeeSendToAddress.code];
            }
        }
        
        NSInteger i=[self.navigationController.viewControllers count]-2;
        [[self.navigationController.viewControllers objectAtIndex:i]  setSendToAddress:sendToAddressNameResult getSendToAddressID:sendToAddressIDResult];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
    }
    //完成后退出，针对没有用户地址簿的情况
    else if (self.sendToAddressType == SendToAddressTypeNoCustom) {
        NSString *sendToAddressNameResult = [[NSString alloc]init];
        NSString *sendToAddressIDResult = [[NSString alloc]init];

        NSIndexPath *lastIndexPath = [[self.sendToAddressDictionary allKeysForObject:[NSNumber numberWithBool:YES]] lastObject];
        for (NSIndexPath *indexPath in [self.sendToAddressDictionary allKeysForObject:[NSNumber numberWithBool:YES]]) {
            if (indexPath == lastIndexPath) {
                SendToAddress*  sendToAddress = [self.sendToAddressArray objectAtIndex:indexPath.row];
                sendToAddressNameResult = [sendToAddressNameResult stringByAppendingFormat:@"%@",sendToAddress.name];
                sendToAddressIDResult = [sendToAddressIDResult stringByAppendingFormat:@"%@",sendToAddress.code];
            }
            else {
                SendToAddress*  sendToAddress = [self.sendToAddressArray objectAtIndex:indexPath.row];
                sendToAddressNameResult = [sendToAddressNameResult stringByAppendingFormat:@"%@，",sendToAddress.name];
                sendToAddressIDResult = [sendToAddressIDResult stringByAppendingFormat:@"%@，",sendToAddress.code];
            }
        }
        NSInteger i=[self.navigationController.viewControllers count]-2;
        [[self.navigationController.viewControllers objectAtIndex:i]  SetSendToAddress:sendToAddressNameResult getSendToAddressID:sendToAddressIDResult];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
    }
    //完成后退出，针对用户选择的是地址簿的情况
    else if (self.sendToAddressType == SendToAddressTypeSelectCustom) {
        EmployeeSendToAddressDB* EmployeeSendToAddressdb=[[EmployeeSendToAddressDB alloc] init];
        [EmployeeSendToAddressdb deleteAll];
        for (NSIndexPath *indexPath in [self.sendToAddressDictionary allKeysForObject:[NSNumber numberWithBool:YES]]) {
            SendToAddress*  sendToAddress = [self.sendToAddressArray objectAtIndex:indexPath.row];
            EmployeeSendToAddress*  employeeSendToAddress = [[EmployeeSendToAddress alloc]init];
            employeeSendToAddress.loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
            employeeSendToAddress.name = sendToAddress.name;
            employeeSendToAddress.code = sendToAddress.code;
            employeeSendToAddress.language = sendToAddress.language;
            employeeSendToAddress.order = sendToAddress.order;
            if ([EmployeeSendToAddressdb addESTAddress:employeeSendToAddress]) {
                NSLog(@"成功！");
            }
        }
        NSInteger i=[self.navigationController.viewControllers count]-2;
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
    }

}





@end
