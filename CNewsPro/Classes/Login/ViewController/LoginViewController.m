//
//  LoginViewController.m
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "LoginViewController.h"
#import "Utility.h"
#import "UserDB.h"
#import "User.h"
#import "RequestMaker.h"
#import "AppDelegate.h"
#import "BasicInfoUtility.h"
#import "LoginManagermentController.h"
#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"
#import "SVProgressHUD.h"

@interface LoginViewController () <UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewConstraint;
@property (nonatomic,assign) CGFloat constant;

@property (nonatomic,assign) NSInteger loginStatus;

@property (nonatomic,assign) BOOL IMEIisRegistered;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftButton.hidden = YES;
    self.logoButton.hidden = NO;
    
    [self configureButton];
    
    [self resetTextField:self.userNameTextField];
    [self resetTextField:self.passwordTextField];

    self.constant = self.inputViewConstraint.constant;
    
    NSString *uName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    NSString *pwd = [USERDEFAULTS objectForKey:PASSWORD];
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
    if (uName) {
        self.userNameTextField.text = uName;
    }
    
    if (pwd) {
        self.passwordTextField.text = pwd;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NOTIFICATION_CENTER addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [NOTIFICATION_CENTER addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.originFrame = self.backView.frame;
}

- (void)dealloc {
    [NOTIFICATION_CENTER removeObserver:self];
}

#pragma mark - Configure Method
- (void)configureButton {
    //设置logo样式
    NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = RGBA(0, 0, 0, 0.8);
    titleShadow.shadowOffset = CGSizeMake(0, 1.5);
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:RGB(245, 245, 245),NSForegroundColorAttributeName,titleShadow,NSShadowAttributeName,[UIFont boldSystemFontOfSize:35.0f],NSFontAttributeName, nil];
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"迅媒无限"
                                                                 attributes:attributes];
    [self.logoButton.titleLabel setAttributedText:attStr];
    self.logoButton.userInteractionEnabled = NO;
    
    //设置登陆按钮样式
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.cornerRadius = 3.0f;
    self.loginButton.layer.masksToBounds = YES;
    
    //设置textField
    self.userNameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
}

- (void)resetTextField:(UITextField *)textField {
    textField.tintColor = [UIColor whiteColor];
    [textField setValue:UIColorFromRGBA(0xffffff, 0.6f) forKeyPath:@"_placeholderLabel.textColor"];
    UIButton *clearButton = [textField valueForKey:@"_clearButton"];
    [clearButton setImage:[UIImage imageNamed:@"login_icon_clear"] forState:UIControlStateNormal];
}

#pragma mark - Notification
#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] floatValue];
    self.inputViewConstraint.constant = keyboardFrame.size.height;
    self.logoButton.hidden = YES;

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] floatValue];
    self.logoButton.hidden = NO;
    
    self.inputViewConstraint.constant = self.constant;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Action
- (IBAction)loginAction:(id)sender {
    if ([self.userNameTextField.text isEqualToString:@""]) {
        [self showAlertWithType:AlertTypeAlert withString:@"请输入用户名"];
        return;
    } else if ([self.passwordTextField.text isEqualToString:@""]) {
        [self showAlertWithType:AlertTypeAlert withString:@"请输入密码"];
        return;
    }
    
//    [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    [self showWait];

    if (![Utility testConnection]) {
        UserDB *userDB = [[UserDB alloc] init];
        //检测是否可以离线登录
        if ([userDB getUserAndPassword:self.userNameTextField.text password:self.passwordTextField.text]) {
            //创建用户文件夹
            [self createFile];
            //离线登录的情况下，从文件中读取userinfo的信息
            [Utility getUserInfoFromFile];
            [USERDEFAULTS setObject:@"" forKey:SESSION_ID];
            [USERDEFAULTS setObject:self.userNameTextField.text forKey:LOGIN_NAME];
            [USERDEFAULTS setObject:self.passwordTextField.text forKey:PASSWORD];
            [USERDEFAULTS synchronize];
            
            [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"当前网络不佳，您已离线登录!"];
            [Utility sendUnFinishedTaskToQueue];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"第一次登录请连接网络"];
        }
        [self hideWaiting];
        return;
    }
    [RequestMaker loginWithUsername:self.userNameTextField.text password:self.passwordTextField.text delegate:self];
}

- (void)loginMangermentSet:(id)sender {
    LoginManagermentController *vc = [[LoginManagermentController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)createFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *paths = [self getPath];
    if (![fileManager fileExistsAtPath:paths]) {
        [fileManager createDirectoryAtPath:paths withIntermediateDirectories:YES attributes:nil error:nil];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSString *)getPath {
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [docDirectory stringByAppendingPathComponent:[USERDEFAULTS objectForKey:LOGIN_NAME]];
}

//网络回调
- (void)requestDidFinish:(NSDictionary *)responseInfo {
    NSData *responseData = [responseInfo objectForKey:RESPONSE_DATA];
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if (![[responseInfo objectForKey:REQUEST_STATUS] isEqualToString:REQUEST_SUCCESS]) {
        [self hideWaiting];
        [[AppDelegate getAppDelegate] alert:AlertTypeError message:[responseInfo objectForKey:@"responseError"]];
        return;
    }
    
    if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
        //成功登录
        if ([[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
            NSString *sessionId = [[responseStr componentsSeparatedByString:@"||"] lastObject];
            [USERDEFAULTS setObject:sessionId forKey:SESSION_ID];
            [USERDEFAULTS setObject:self.userNameTextField.text forKey:LOGIN_NAME];
            [USERDEFAULTS setObject:self.passwordTextField.text forKey:PASSWORD];
            [USERDEFAULTS synchronize];
            
            //创建用户文件
            [self createFile];
            //同步获取userInfo
            [Utility initializeUserInfo];
            
            //检测登录用户名是否拥有系统稿签，如无则为其自动添加
            [self addSystemTemplate];
            
            UserDB *userDB = [[UserDB alloc] init];
            if (![userDB getUserAndPassword:self.userNameTextField.text password:self.passwordTextField.text]) {
                User *userInfo = [[User alloc] init];
                userInfo.loginName = self.userNameTextField.text;
                userInfo.password = self.passwordTextField.text;
                [userDB addUser:userInfo];
            }
            [Utility sendUnFinishedTaskToQueue];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self updateBasicData];
        } else {
            //登录失败
            if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:1]
                                           delegate:self
                                  cancelButtonTitle:@"确认"
                                  otherButtonTitles:nil, nil] show];
                self.IMEIisRegistered = NO;
            } else {
                [[AppDelegate getAppDelegate] alert:AlertTypeError message:[responseInfo objectForKey:@"responseError"]];
            }
        }
    } else {
        if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert
                                        message:[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:1]];
            
        }else {
            //登录失败，检查是否可以离线登录
            UserDB *userDB = [[UserDB alloc] init];
            if ([userDB getUserAndPassword:self.userNameTextField.text password:self.passwordTextField.text]) {
                [self createFile];
                [Utility initializeUserInfo];
                [USERDEFAULTS setObject:@"" forKey:SESSION_ID];
                [USERDEFAULTS setObject:self.userNameTextField.text forKey:LOGIN_NAME];
                [USERDEFAULTS setObject:self.passwordTextField.text forKey:PASSWORD];
                [Utility sendUnFinishedTaskToQueue];
                [self.navigationController popToRootViewControllerAnimated:NO];
            } else {
                [[AppDelegate getAppDelegate] alert:AlertTypeError
                                            message:[responseInfo objectForKey:@"responseError"]];
            }
        }
    }
    [self hideWaiting];
}

//更新基础数据
- (void)updateBasicData {
    BasicInfoUtility *basicInfo = [[BasicInfoUtility alloc] init];
    //拷贝存放基础数据的plist文件
    if ([basicInfo copyBasicInfoPlist]) {
        NSString *xmlFileNameList = [basicInfo getFileNameList];
        //查看基础数据是否有更新
        NSString *xmlResult = [basicInfo getFileNameWithNewBasicInfo:xmlFileNameList];
        if ([xmlResult isEqualToString:@""] || [xmlResult isEqual:nil]) {
            NSLog(@"没有可更新的数据或者网络不响应");
        } else {
            [basicInfo updateBasicInfo:xmlResult];
        }
    } else {
        NSLog(@"拷贝plist文件失败");
    }
}

//检测登录用户名是否拥有系统稿签，如无则为其自动添加
- (BOOL)addSystemTemplate {
    NSString *loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    ManuscriptTemplateDB *checkManuscriptTemplateDB = [[ManuscriptTemplateDB alloc] init];
    
    if (![[checkManuscriptTemplateDB getSystemTemplate:loginName type:MANUSCRIPT_TEMPLATE_TYPE] count]) {
        //将服务器上的稿签同步到手机
        [Utility getTemplate];
        NSArray *sysArray = [[NSArray alloc] initWithObjects:@"文字快讯",@"音频快讯",@"视频快讯",@"图片快讯",nil];
        NSArray *templateTypeArray = [[NSArray alloc] initWithObjects:TEXT_EXPRESS_TEMPLATE_TYPE,AUDIO_EXPRESS_TEMPLATE_TYPE,PICTURE_EXPRESS_TEMPLATE_TYPE,VIDEO_EXPRESS_TEMPLATE_TYPE, nil];
        for (int i = 0; i < 4; i++) {
            ManuscriptTemplate *manuscriptTemplate = [[ManuscriptTemplate alloc] init];
            manuscriptTemplate.mt_id = [Utility stringWithUUID];
            manuscriptTemplate.is3Tnews = @"0";//是否3T稿件
            manuscriptTemplate.isDefault = @"0";//是否默认稿签
            manuscriptTemplate.createTime = [Utility getLogTimeStamp];
            manuscriptTemplate.isSystemOriginal = [templateTypeArray objectAtIndex:i];//@"1";//是否系统稿签
            manuscriptTemplate.name = [sysArray objectAtIndex:i];
            manuscriptTemplate.loginName = loginName;
            [checkManuscriptTemplateDB addManuscriptTemplate:manuscriptTemplate];
        }
    }
    return TRUE;
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.IMEIisRegistered) {
        return;
    }
    [RequestMaker loginWithUsername:self.userNameTextField.text password:self.passwordTextField.text delegate:self];
    [Utility checkVersion];//保存最低版本号
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        [self.userNameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.view endEditing:YES];
        [self loginAction:nil];
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
