//
//  NewTagDetailViewController.m
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewTagDetailViewController.h"
#import "Manuscripts.h"
#import "ManuscriptTemplate.h"
#import "ManuscriptTemplateDB.h"
#import "User.h"
#import "Utility.h"
#import "MAlertView.h"
#import "AppDelegate.h"
#import "TemplateManageController.h"
#import "Language.h"
#import "LanguageDB.h"
#import "ProvideType.h"
#import "NewsPriority.h"
#import "NewsPriorityDB.h"
#import "NetworkManager.h"
#import "DocTypeSuperController.h"
#import "SendToAddressController.h"

@interface NewTagDetailViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation NewTagDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //添加键盘弹出与消失的消息监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldKeyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    if (self.actionSheet) {
        CGRect sheetFrame = self.actionSheet.frame;
        sheetFrame.origin.y += sheetFrame.size.height;
        sheetFrame.size.height = 1.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.actionSheet.frame = sheetFrame;
                         } completion:^(BOOL finished) {
                             //nop
                             [self.actionSheet removeFromSuperview];
                         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KeyboardNotification
//根据键盘遮挡情况移动视图
-(void)textFieldKeyboardDidShow:(NSNotification *)notification
{
    NSDictionary * info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //防止响应多次键盘弹出事件
    if (self.keyboardShown){
        //由于iOS5中英文键盘高度不同，保证用户切换键盘时视图随之滚动
        if (kbSize.height < self.keyboardHeight) {
            self.keyboardHeight = kbSize.height;
            CGRect viewFrame = [self.templateDetailView frame];
            viewFrame.size.height = viewFrame.size.height+36;
            self.templateDetailView.frame = viewFrame;
            
            // Scroll the active text field into view.
            CGRect textFieldRect = [[self.activeField superview] frame];
            [self.templateDetailView scrollRectToVisible:textFieldRect animated:YES];
            return;
        }
        else if (kbSize.height > self.keyboardHeight) {
            self.keyboardHeight = kbSize.height;
            CGRect viewFrame = [self.templateDetailView frame];
            viewFrame.size.height = viewFrame.size.height-36;
            self.templateDetailView.frame = viewFrame;
            
            // Scroll the active text field into view.
            CGRect textFieldRect = [[self.activeField superview] frame];
            [self.templateDetailView scrollRectToVisible:textFieldRect animated:YES];
            return;
        }
        return;
    }
    
    else {
        self.keyboardHeight = kbSize.height;
        CGRect viewFrame = [self.templateDetailView frame];
        viewFrame.size.height = viewFrame.size.height-kbSize.height+45;
        self.templateDetailView.frame = viewFrame;
        
        // Scroll the active text field into view.
        CGRect textFieldRect = [[self.activeField superview] frame];
        [self.templateDetailView scrollRectToVisible:textFieldRect animated:YES];
        self.keyboardShown = YES;
    }
}


//键盘消失，恢复视图
-(void)textFieldKeyboardDidHide:(NSNotification *)notification
{
    //防止在新建稿件页弹出键盘后，在默认稿签页响应键盘消去的BUG
    if ((self.templateType == TemplateTypeCheckAble || self.templateType == TemplateTypeEditAble) && self.superViewKeyboardShow&&!self.keyboardShown) {
        self.keyboardShown = NO;
        return;
    }
    //在发稿地址页禁用随键盘滚动功能
    else if (!self.keyboardShown) {
        return;
    }
    else {
        NSDictionary * info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        // Reset the height of the scroll view to its original value
        CGRect viewFrame = [self.templateDetailView frame];
        viewFrame.size.height = viewFrame.size.height+kbSize.height-45;
        self.templateDetailView.frame = viewFrame;
        
        self.keyboardShown = NO;
    }
}

#pragma mark - Private
- (void)setUpView {
    
    UIImageView *tableBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TempleView_bg"]];
    tableBg.frame = CGRectMake(21.0f,80.0f,292.0f,self.view.frame.size.height-57-37-37);
    [self.view addSubview:tableBg];
    
    self.templateDetailView = [[UITableView alloc] initWithFrame:CGRectMake(25.0f,84.0f,286.0f,self.view.frame.size.height-57-37-44) style:UITableViewStylePlain];
    self.templateDetailView.delegate = self;
    self.templateDetailView.dataSource = self;
    self.templateDetailView.separatorStyle = NO;
    self.templateDetailView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:self.templateDetailView];
    
    self.templateDetailView.hidden=NO;
    
    
    self.midManuscriptTemplate = [[ManuscriptTemplate alloc] init];
    
    //zyq 另存和套用按钮
    self.saveAsbtn = [[UIButton alloc] initWithFrame:CGRectMake(150, self.view.frame.size.height-40, 71, 30)];
    [self.saveAsbtn addTarget:self action:@selector(saveAs:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveAsbtn setTitle:@"另存为" forState:0];
    [self.saveAsbtn setBackgroundImage:[UIImage imageNamed:@"TempleView_btnSelect"] forState:UIControlStateNormal];
    [self.view addSubview:self.saveAsbtn];
    
    self.applybtn = [[UIButton alloc] initWithFrame:CGRectMake(238, self.view.frame.size.height-40, 71, 30)];
    [self.applybtn addTarget:self action:@selector(applybtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.applybtn setTitle:@"套用" forState:0];
    [self.applybtn setBackgroundImage:[UIImage imageNamed:@"TempleView_btnSelect"] forState:UIControlStateNormal];
    [self.view addSubview:self.applybtn];
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"TempleView－titlebg.png"] forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    [self.titleLabelAndImage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeExist) {
        [self.titleLabelAndImage setTitle:@"稿签编辑" forState:UIControlStateNormal];
    }
    else {
        [self.titleLabelAndImage setTitle:@"稿签栏" forState:UIControlStateNormal];
    }
    //添加确认按钮
    if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeExist) {
        self.rightButton.userInteractionEnabled = YES;
        [self.rightButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    }

    //获得用户信息
    self.userInfo = [Utility sharedSingleton].userInfo;
    
    self.templateDetailView.backgroundColor=[UIColor clearColor];
    
    if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeExist || self.templateType == TemplateTypeCheckAble) {
        if (self.templateType == TemplateTypeNew) {
            self.manuscriptTemplate = [[ManuscriptTemplate alloc]init];
        }
 
        //liying
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        
        if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeExist) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 150, 20, 60)];
            view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view];
        }
    }
    if (!(self.templateType == TemplateTypeNew)) {
        if ([self.manuscriptTemplate.comeFromDept isEqualToString:@""]) {
            if (self.userInfo!=nil) {
                [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+2 inSection:0]] viewWithTag:COMEFROM_DEPT_TAG] setText:self.userInfo.groupNameC];
                self.manuscriptTemplate.comeFromDept = self.userInfo.groupNameC;
                self.manuscriptTemplate.comeFromDeptID = self.userInfo.groupCode;
                
            }
        }
    }
    [self copyManuscriptTemplate];//刚进入稿签详情页，将之前的稿签信息进行保存
}

//另存稿签功能
-(void)saveAs:(id)sender
{
    MAlertView *mAlertView = [[MAlertView alloc] initWithTitle:@"请输入模板名称"
                                                       message:nil delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定删除", nil];
    [mAlertView addTextField:@"" placeHolder:@"请输入模板名称"];
    self.templateType = TemplateTypeSaveAs;
    mAlertView.tag=1;
    self.tfSaveAs = [mAlertView textFieldAtIndex:0];
    [mAlertView show];
}

-(void)applybtn:(id)sender
{
    TemplateManageController *tagManageController = [[TemplateManageController alloc]init];
    tagManageController.delegate=self;
    tagManageController.viewTemplate = ViewTemplateSelect;
    [self presentViewController:tagManageController animated:YES completion:nil];
    
}

//完成稿签编辑
-(void)complete
{
    [self addFieldText];
    [self copyManuscriptTemplate];
    if ([self checkManuscriptTemplate:self.manuscriptTemplate])
    {
        if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeSaveAs) {
            self.manuscriptTemplate.mt_id = [Utility stringWithUUID];
            self.manuscriptTemplate.loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
            self.manuscriptTemplate.is3Tnews = @"0";//是否3T稿件
            self.manuscriptTemplate.isDefault = @"0";//是否默认稿签
            self.manuscriptTemplate.createTime = [Utility getLogTimeStamp];
            self.manuscriptTemplate.isSystemOriginal = MANUSCRIPT_TEMPLATE_TYPE;//@"0";//是否系统稿签
            
            ManuscriptTemplateDB* addDB = [[ManuscriptTemplateDB alloc] init];
            NSInteger i = [addDB addManuscriptTemplate:self.manuscriptTemplate];
            if (i) {
                [[AppDelegate getAppDelegate]  alert:AlertTypeSuccess message:@"新建稿签模版成功！"];
            }
            else {
                [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"模板名称重复！"];
            }
            if(self.templateType == TemplateTypeNew){
                //返回稿签对象
                NSInteger index = [self.navigationController.viewControllers count]-2;
                TemplateManageController *templateManageController = [self.navigationController.viewControllers objectAtIndex:index];
                [templateManageController reloadtable];
                [self.navigationController popToViewController:templateManageController  animated:YES];
            }
        }
        else {
            ManuscriptTemplateDB* updateDB = [[ManuscriptTemplateDB alloc] init];
            NSInteger i = [updateDB updateManuscriptTemplate:self.manuscriptTemplate];
            if (!i) {
                if(self.templateType == TemplateTypeExist){
                    //返回稿签对象
                    [[AppDelegate getAppDelegate]  alert:AlertTypeSuccess message:@"稿签更新成功！"];
                    [self.delegate reloadtable];
                }
                else {
                    [self.delegate returnManuScriptTemplate:self.manuscriptTemplate];;
                }
                NSInteger index=[self.navigationController.viewControllers count]-2;
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index]  animated:YES];
            }
        }
    }
    
}

//稿签对象深拷贝
-(void)copyManuscriptTemplate
{
    self.midManuscriptTemplate.name = self.manuscriptTemplate.name;
    self.midManuscriptTemplate.loginName = self.manuscriptTemplate.loginName;
    self.midManuscriptTemplate.comeFromDept = self.manuscriptTemplate.comeFromDept;
    self.midManuscriptTemplate.region = self.manuscriptTemplate.region;
    self.midManuscriptTemplate.docType = self.manuscriptTemplate.docType;
    self.midManuscriptTemplate.provType = self.manuscriptTemplate.provType;
    self.midManuscriptTemplate.keywords = self.manuscriptTemplate.keywords;
    self.midManuscriptTemplate.language = self.manuscriptTemplate.language;
    self.midManuscriptTemplate.priority = self.manuscriptTemplate.priority;
    self.midManuscriptTemplate.sendArea = self.manuscriptTemplate.sendArea;
    self.midManuscriptTemplate.happenPlace = self.manuscriptTemplate.happenPlace;
    self.midManuscriptTemplate.reportPlace = self.manuscriptTemplate.reportPlace;
    self.midManuscriptTemplate.address = self.manuscriptTemplate.address;
    self.midManuscriptTemplate.reviewStatus = self.manuscriptTemplate.reviewStatus;
    self.midManuscriptTemplate.defaultTitle = self.manuscriptTemplate.defaultTitle;
    self.midManuscriptTemplate.defaultContents = self.manuscriptTemplate.defaultContents;
    self.midManuscriptTemplate.author = self.manuscriptTemplate.author;
}

//查看稿签信息是否填写完整
-(BOOL)checkManuscriptTemplate:(ManuscriptTemplate *)amanuscriptTemplate
{
    //去除首尾空格
    NSString *string = [amanuscriptTemplate.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([amanuscriptTemplate.name isEqualToString:@""] || [string isEqualToString:@""])
    {
        [self alert:@"模板名称不能为空！"];
        return NO;
    }
    ManuscriptTemplateDB* manuscriptemplatedb=[[ManuscriptTemplateDB alloc] init];
    NSArray *templateArray = [manuscriptemplatedb getAllTemplate:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    for (ManuscriptTemplate *checkTemplate in templateArray) {
        if ([checkTemplate.name isEqualToString:string]) {
            if ([checkTemplate.mt_id isEqualToString:amanuscriptTemplate.mt_id]) {
                return YES;
            }
            [self alert:@"模板名称重复！"];
            return NO;
        }
    }
    return YES;
}

//弹出警示窗
-(void)alert:(NSString *)theMessage{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:theMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
    [alertView show];

}

-(void)addFieldText
{
    if (self.templateType == TemplateTypeNew || self.templateType == TemplateTypeEditAble) {
        if (self.tf0.editing) {
            self.manuscriptTemplate.name = ![self.tf0.text isEqualToString:@""]&&self.tf0.text ? self.tf0.text : @"";
        }
        if (self.tf15.editing) {
            self.manuscriptTemplate.author = ![self.tf15.text isEqualToString:@""]&&self.tf15.text ? self.tf15.text : @"";
        }
        if (self.tf5.editing) {
            self.manuscriptTemplate.sendArea = ![self.tf5.text isEqualToString:@""]&&self.tf5.text ? self.tf5.text : @"";
        }
        if (self.tf6.editing) {
            self.manuscriptTemplate.happenPlace = ![self.tf6.text isEqualToString:@""]&&self.tf6.text ? self.tf6.text : @"";
        }
        if (self.tf7.editing) {
            self.manuscriptTemplate.reportPlace = ![self.tf7.text isEqualToString:@""]&&self.tf7.text ? self.tf7.text : @"";
        }
        if (self.tf8.editing) {
            self.manuscriptTemplate.keywords = ![self.tf8.text isEqualToString:@""]&&self.tf8.text ? self.tf8.text : @"";
        }
        if (self.tf9.editing) {
            self.manuscriptTemplate.reviewStatus = ![self.tf9.text isEqualToString:@""]&&self.tf9.text ? self.tf9.text : @"";
        }
        if (self.tf10.editing) {
            self.manuscriptTemplate.defaultTitle = ![self.tf10.text isEqualToString:@""]&&self.tf10.text ? self.tf10.text : @"";
        }
        if (self.tf11.editing) {
            self.manuscriptTemplate.defaultContents = ![self.tf11.text isEqualToString:@""]&&self.tf11.text ? self.tf11.text : @"";
        }
    }
}

- (void)initializeActionSheet
{
    //退出键盘
    [self.view endEditing:YES];
    //初始化actionsheet
    self.actionSheet = [[UIView alloc]initWithFrame:self.view.bounds];
    self.actionSheet.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    
    UIView *backcolorView = [[UIView alloc]initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.actionSheet.frame)-240.0, CGRectGetWidth(self.view.frame), 260.0)];
    backcolorView.backgroundColor = [UIColor colorWithWhite:218.0/255.0 alpha:1.0];
    backcolorView.tag = 1101;
    [self.actionSheet addSubview:backcolorView];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [[self.actionSheet viewWithTag:1101] addSubview:cancelButton];
    
}

#pragma mark - Public Method
//获取发稿地址选择信息
- (void)setSendToAddress:(NSString *)sendToAddressInf getSendToAddressID:(NSString *)addressId {
    
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:8 + self.rowNum inSection:0]] viewWithTag:SEND_ADDRESS_TAG] setText:sendToAddressInf];
    self.manuscriptTemplate.addressID = addressId;
    self.manuscriptTemplate.address = sendToAddressInf;
}

//获取稿源选择信息
-(void)setComeFromAddress:(NSString *)comeFromAddressInf getComeFromAddressID:(NSString *)addressID
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum + 2 inSection:0]] viewWithTag:COMEFROM_DEPT_TAG] setText:comeFromAddressInf];
    self.manuscriptTemplate.comeFromDeptID = addressID;
    self.manuscriptTemplate.comeFromDept = comeFromAddressInf;
}

//获取稿件分类选择信息
-(void)setNewsCategory:(NSString *)newsCategoryInf getNewsCategoryID:(NSString *)categoryID
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+2 inSection:0]] viewWithTag:DOC_TYPE_TAG] setText:newsCategoryInf];
    self.manuscriptTemplate.docTypeID = categoryID;
    self.manuscriptTemplate.docType = newsCategoryInf;
}

//获取地区选择信息
-(void)setRegion:(NSString *)regionInf getRegionID:(NSString *)regionID
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+5 inSection:0]] viewWithTag:REGION_TAG] setText:regionInf];
    self.manuscriptTemplate.regionID = regionID;
    self.manuscriptTemplate.region = regionInf;
}

//获取来稿地点选择信息，同时同步到事发地点和报到地点
-(void)setSendArea:(NSString *)placeInf
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+3 inSection:0]] viewWithTag:SEND_AREA_TAG] setText:placeInf];
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+4 inSection:0]] viewWithTag:HAPPEN_PLACE_TAG] setText:placeInf];
    self.manuscriptTemplate.sendArea = placeInf;
    self.manuscriptTemplate.happenPlace = placeInf;
    self.manuscriptTemplate.reportPlace = placeInf;
}

//获取事发地点选择信息
-(void)setHappenPlace:(NSString *)placeInf
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+3 inSection:0]] viewWithTag:HAPPEN_PLACE_TAG] setText:placeInf];
    self.manuscriptTemplate.happenPlace = placeInf;
}

//获取报到地点选择信息
-(void)setReportPlace:(NSString *)placeInf
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+7 inSection:0]] viewWithTag:REPORT_PLACE_TAG] setText:placeInf];
    self.manuscriptTemplate.reportPlace = placeInf;
}

//获取关键字选择信息
-(void)setKeywords:(NSString *)keywordsInf
{
    [(UITextField *)[(UITableViewCell*)[self.templateDetailView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowNum+5 inSection:0]] viewWithTag:KEYWORDS_TAG] setText:keywordsInf];
    self.manuscriptTemplate.keywords = keywordsInf;
}

//回传套用的稿签模板
- (void)returnManuScriptTemplate:(ManuscriptTemplate *)returnManuscriptTemplate {
    self.manuscriptTemplate = returnManuscriptTemplate;
 
    [self.templateDetailView reloadData];
}


#pragma mark TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.templateDetailView) {
        return TEMPLATE_DETAIL_VIEWROW_NUM;
    }
    else {
        return SEND_ADDRESS_SECTION_NUM;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.templateDetailView) {
        if (self.templateType == TemplateTypeCheckAble || self.templateType == TemplateTypeEditAble || self.templateType == TemplateTypeSaveAs) {
            return TEMPLATE_DETAIL_VIEWROW_NUM-3;
        }
        return TEMPLATE_DETAIL_VIEWROW_NUM-2;
    }
    else {
        return SEND_ADDRESS_ROW_NUM;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] init];
    UILabel *tiltelb=[[UILabel alloc] initWithFrame:CGRectMake(4, 5, 120, 40)];
    tiltelb.font = TL_FONT;
    tiltelb.backgroundColor=[UIColor clearColor];
    [cell addSubview:tiltelb];

    UIImageView *linebg=[[UIImageView alloc] initWithFrame:CGRectMake(4, 50, 278, 1)];
    linebg.image=[UIImage imageNamed:@"TempleView_line.png"];
    [cell addSubview:linebg];

    if (self.templateType == TemplateTypeCheckAble || self.templateType == TemplateTypeEditAble || self.templateType == TemplateTypeSaveAs) {
        self.rowNum = -1;
    }
    else {
        self.rowNum = 0;
    }
    if (indexPath.row == self.rowNum)
    {
        tiltelb.text = @"模板名称：";
        self.tf0 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf0.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf0.font = TF_FONT;
        self.tf0.text = self.manuscriptTemplate.name;
        if ([self.isSystemTemplate isEqual:@"SystemTemplate"]) {
            self.tf0.enabled = NO;
        }
        [self.tf0 textRectForBounds:CGRectMake(0, 12, 200, 20)];
        self.tf0.tag = NAME_TAG;
        self.tf0.delegate = self;
        [cell addSubview:self.tf0];
    }
    if (indexPath.row == self.rowNum+1)
    {
        tiltelb.text = @"*作者：";
        self.tf15 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf15.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf15.font = TF_FONT;
        self.tf15.text = self.manuscriptTemplate.author;
        self.tf15.tag = AUTHOR_TAG;
        self.tf15.text = self.userInfo.userNameC;
        self.manuscriptTemplate.author = self.userInfo.userNameC;
        self.tf15.delegate = self;
        [cell addSubview:self.tf15];
    }
    else if (indexPath.row == self.rowNum+2)
    {
        tiltelb.text = @"*供稿类别：";
        self.tf3 = [[UITextView alloc]initWithFrame:TV_CGRECT];
        self.tf3.editable = NO;
        self.tf3.backgroundColor = [UIColor clearColor];
        self.tf3.font = TF_FONT;
        self.tf3.text = self.manuscriptTemplate.docType;
        self.tf3.tag = DOC_TYPE_TAG;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell addSubview:self.tf3];
    }
    else if (indexPath.row == self.rowNum+3)
    {
        tiltelb.text = @"发稿地点：";
        self.tf5 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf5.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf5.font = TF_FONT;
        self.tf5.text = self.manuscriptTemplate.sendArea;
        self.tf5.tag = SEND_AREA_TAG;
        self.tf5.delegate = self;
        [cell addSubview:self.tf5];
    }
    else if (indexPath.row == self.rowNum+4)
    {
        tiltelb.text = @"事发地点：";
        self.tf6 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf6.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf6.font = TF_FONT;
        self.tf6.text = self.manuscriptTemplate.happenPlace;
        self.tf6.tag = HAPPEN_PLACE_TAG;
        self.tf6.delegate = self;
        [cell addSubview:self.tf6];
    }
    else if (indexPath.row == self.rowNum+5)
    {
        tiltelb.text = @"*关键字：";
        self.tf8 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf8.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf8.font = TF_FONT;
        self.tf8.text = self.manuscriptTemplate.keywords;
        self.tf8.tag = KEYWORDS_TAG;
        self.tf8.delegate = self;
        [cell addSubview:self.tf8];
        
    }
    else if (indexPath.row == self.rowNum+6)
    {
        tiltelb.text = @"*稿件类型：";
        tiltelb.textColor=[UIColor redColor];
        self.tf16 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf16.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf16.font = TF_FONT;
        self.tf16.text = @"稿件";
        self.tf16.enabled = NO;
        self.tf16.tag = SCRIPT_TYPE_TAG;
        self.tf16.delegate = self;
        [cell addSubview:self.tf16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.row == self.rowNum+7)
    {
        tiltelb.text = @"*优先级：";
        self.tf13 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf13.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf13.font = TF_FONT;
        self.tf13.text = self.manuscriptTemplate.priority;
        self.tf13.tag = PRIORITY_TAG;
        self.tf13.delegate = self;
        self.tf13.enabled = NO;
        [cell addSubview:self.tf13];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == self.rowNum+8)
    {
        tiltelb.text = @"*发稿通道：";
        tiltelb.textColor=[UIColor redColor];
        self.tf14 = [[UITextField alloc]initWithFrame:TF_CGRECT];
        self.tf14.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tf14.enabled = NO;
        self.tf14.backgroundColor = [UIColor clearColor];
        self.tf14.font = TF_FONT;
        self.tf14.text = self.manuscriptTemplate.address;
        self.tf14.tag = SEND_ADDRESS_TAG;
        [cell addSubview:self.tf14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }

    if (self.templateType == TemplateTypeCheckAble) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tf0.enabled = NO;
        self.tf5.enabled = NO;
        self.tf6.enabled = NO;
        self.tf7.enabled = NO;
        self.tf8.enabled = NO;
        self.tf9.enabled = NO;
        self.tf10.enabled = NO;
        self.tf11.enabled = NO;
        self.tf15.enabled = NO;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)TableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.templateType == TemplateTypeCheckAble) {
        [TableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (!self.templateDetailView.hidden) {
        
        if (indexPath.row == self.rowNum+1){
            [self initializeActionSheet];
            
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = AUTHOR_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = AUTHOR_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
            
        }//进入稿件分类选择页面
        else if (indexPath.row == self.rowNum+2){
            DocTypeSuperController *docTypeSuperController = [[DocTypeSuperController alloc]init];
            [self.navigationController pushViewController:docTypeSuperController animated:YES];
        }
        //来稿地点,事发地点，报道地点
        else if(indexPath.row == self.rowNum+3 || indexPath.row == self.rowNum+4){
            //            PlaceController *placeController = [[PlaceController alloc]init];
            //            if (indexPath.row == rowNum+3) {
            //                placeController.getType = GETSENDAREA;
            //            }
            //            else if(indexPath.row == rowNum+4){
            //                placeController.getType = GETHAPPENPLACE;
            //            }
            //
            //            [self.navigationController pushViewController:placeController animated:YES];
        }
        //进入关键字选择页面
        else if (indexPath.row == self.rowNum+5){
            //            KeywordsController *keywordsController = [[KeywordsController alloc]init];
            //            [self.navigationController pushViewController:keywordsController animated:YES];
        }
        else if (indexPath.row == self.rowNum+7){
            [self initializeActionSheet];
            
            NewsPriorityDB* NewsPrioritydb = [[NewsPriorityDB alloc] init];
            self.newsPriorityArray = [[NSMutableArray alloc] initWithArray:[NewsPrioritydb getNewsPriorityList]];
            
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = PRIORITY_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor blackColor];
            closeButton.tag = PRIORITY_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
        }
        else if (indexPath.row == self.rowNum+8){
            SendToAddressController *sendToAddressController = [[SendToAddressController alloc]init];
            sendToAddressController.sendToAddressType = SendToAddressTypeCustom;
            sendToAddressController.selectedSendToAddressArray = [self.manuscriptTemplate.address componentsSeparatedByString:@"，"];
            [self.navigationController pushViewController:sendToAddressController animated:YES];
        }
        
        
    }
    else {
        //进入稿件类型选择页面
        if(indexPath.row == 0){
            
        }
        //进入文种选择页面
        if(indexPath.row == 1){
            [self initializeActionSheet];
            
            LanguageDB* Languagedb = [[LanguageDB alloc] init];
            self.languageArray = [[NSMutableArray alloc] initWithArray:[Languagedb getLanguageList]];
            
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = LANGUAGE_TAG;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
            closeButton.tag = LANGUAGE_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
        }
        //进入优先级选择页面
        else if(indexPath.row==2){
            [self initializeActionSheet];
            
            NewsPriorityDB* NewsPrioritydb=[[NewsPriorityDB alloc] init];
            self.newsPriorityArray = [[NSMutableArray alloc] initWithArray:[NewsPrioritydb getNewsPriorityList]];
            
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = PRIORITY_TAG ;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [[self.actionSheet viewWithTag:1101] addSubview:pickerView];
            
            UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"选择"]];
            closeButton.momentary = YES;
            closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
            closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
            closeButton.tintColor = [UIColor colorWithRed:154.0f/255.0f green:213.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
            closeButton.tag = PRIORITY_TAG;
            [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [[self.actionSheet viewWithTag:1101] addSubview:closeButton];
            
            [[[UIApplication sharedApplication]keyWindow]addSubview:self.actionSheet];
        }
        //进入发送地址选择页面
        else if (indexPath.row == 3){
            SendToAddressController *sendToAddressController = [[SendToAddressController alloc]init];
            sendToAddressController.sendToAddressType = SendToAddressTypeCustom;
            sendToAddressController.selectedSendToAddressArray = [self.manuscriptTemplate.address componentsSeparatedByString:@"，"];
            [self.navigationController pushViewController:sendToAddressController animated:YES];

        }
    }
    [TableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51.0f;
}



#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}
//点击换行，键盘消去
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//完成填写后保存填写内容
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
    switch (textField.tag) {
        case NAME_TAG:
            self.manuscriptTemplate.name = textField.text;
            break;
        case SEND_AREA_TAG:
            self.manuscriptTemplate.sendArea = textField.text;
            break;
        case HAPPEN_PLACE_TAG:
            self.manuscriptTemplate.happenPlace = textField.text;
            break;
        case REPORT_PLACE_TAG:
            self.manuscriptTemplate.reportPlace = textField.text;
            break;
        case KEYWORDS_TAG:
            self.manuscriptTemplate.keywords = textField.text;
            break;
        case REVIEW_STATUS_TAG:
            self.manuscriptTemplate.reviewStatus = textField.text;
            break;
        case DEFAULT_TITLE_TAG:
            self.manuscriptTemplate.defaultTitle = textField.text;
            break;
        case DEFAULT_CONTENTS_TAG:
            self.manuscriptTemplate.defaultContents = textField.text;
            break;
        case AUTHOR_TAG:
            self.manuscriptTemplate.author = textField.text;
            break;
        default:
            break;
    }
}

#pragma mark pickerView data delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//设置选择器的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == PROV_TYPE_TAG) {
        return [self.provideTypeArray count];
    }
    else if (pickerView.tag == LANGUAGE_TAG) {
        return [self.languageArray count];
    }
    else if (pickerView.tag == PRIORITY_TAG) {
        return [self.newsPriorityArray count];
    }
    else if(pickerView.tag == AUTHOR_TAG){
        return 2;
    }
    else if(pickerView.tag == SCRIPT_TYPE_TAG){
        return 0;
    }
    return 0;
}

//设置选择器每行内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == LANGUAGE_TAG)
    {
        Language *language = [self.languageArray objectAtIndex:row];
        return language.name;
    }
    else if (pickerView.tag == PROV_TYPE_TAG) {
        ProvideType *provideType = [self.provideTypeArray objectAtIndex:row];
        return provideType.name;
    }
    else if (pickerView.tag == PRIORITY_TAG) {
        NewsPriority *newsPriority = [self.newsPriorityArray objectAtIndex:row];
        return newsPriority.name;
    }
    else if(pickerView.tag == AUTHOR_TAG){
        if (row==0) {
            return self.userInfo.userNameC;
        }else {
            return self.userInfo.userNameE;
        }
    }
    return nil;
}

//离开动作表时，完成所选内容的保存
- (void)dismissActionSheet:(UIButton *)doneButton
{
    switch (doneButton.tag) {
        case PROV_TYPE_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:PROV_TYPE_TAG];
            ProvideType *provideType = [self.provideTypeArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            self.tf2.text = provideType.name;
            self.manuscriptTemplate.provType = self.tf2.text;
            self.manuscriptTemplate.provTypeid = provideType.code;
            break;
        }
        case LANGUAGE_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:LANGUAGE_TAG];
            Language *language = [self.languageArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            self.tf12.text = language.name;
            self.manuscriptTemplate.language = self.tf12.text;
            self.manuscriptTemplate.languageID = language.code;
            break;
        }
        case PRIORITY_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:PRIORITY_TAG];
            NewsPriority *newsPriority = [self.newsPriorityArray objectAtIndex:[pickerView selectedRowInComponent:0]];
            self.tf13.text = newsPriority.name;
            self.manuscriptTemplate.priority = self.tf13.text;
            self.manuscriptTemplate.priorityID = newsPriority.code;
            break;
        }
        case AUTHOR_TAG:{
            UIPickerView *pickerView = (UIPickerView *)[self.actionSheet viewWithTag:AUTHOR_TAG];
            if ([pickerView selectedRowInComponent:0] == 0) {
                self.tf15.text = self.userInfo.userNameC;
            }
            else if([pickerView selectedRowInComponent:0] == 1) {
                self.tf15.text = self.userInfo.userNameE;
            }
            self.manuscriptTemplate.author = self.tf15.text;
            break;
        }
        default:
            break;
    }
    
    CGRect sheetFrame = self.actionSheet.frame;
    sheetFrame.origin.y += sheetFrame.size.height;
    sheetFrame.size.height = 1.0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.actionSheet.frame = sheetFrame;
                     } completion:^(BOOL finished) {
                         //nop
                         [self.actionSheet removeFromSuperview];
                     }];
}

#pragma mark Alertview Delegate
//保存另存的稿签
- (void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 1) {
        //返回alert
        if (aView.tag==0) {
            if (self.templateType == TemplateTypeSaveAs) {
                self.templateType = TemplateTypeEditAble;
            }
            [self complete];
        }
        else {
            self.templateType = TemplateTypeSaveAs;
            NSString *orginalName = [self.manuscriptTemplate.name copy];
            NSString *orginalID = [self.manuscriptTemplate.mt_id copy];
            NSString *orginalIs3Tnews = [self.manuscriptTemplate.is3Tnews copy];
            NSString *orginalIsDefault = [self.manuscriptTemplate.isDefault copy];
            NSString *orginalCreatetime = [self.manuscriptTemplate.createTime copy];
            NSString *orginalIsSystemoriginal = [self.manuscriptTemplate.isSystemOriginal copy];
            
            ManuscriptTemplate *manuscriptTemplateSaveAs = self.manuscriptTemplate;
            manuscriptTemplateSaveAs.name = self.tfSaveAs.text;
            if ([self checkManuscriptTemplate:manuscriptTemplateSaveAs])
            {
                manuscriptTemplateSaveAs.mt_id = [Utility stringWithUUID];
                manuscriptTemplateSaveAs.loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
                manuscriptTemplateSaveAs.is3Tnews = @"0";//是否3T稿件
                manuscriptTemplateSaveAs.isDefault = @"0";//是否默认稿签
                manuscriptTemplateSaveAs.createTime = [Utility getLogTimeStamp];
                manuscriptTemplateSaveAs.isSystemOriginal = MANUSCRIPT_TEMPLATE_TYPE;//@"0";//是否系统稿签
                
                ManuscriptTemplateDB* addDB=[[ManuscriptTemplateDB alloc] init];
                NSInteger i = [addDB addManuscriptTemplate:manuscriptTemplateSaveAs];
                if (i) {
                    [[AppDelegate getAppDelegate]  alert:AlertTypeSuccess message:@"另存稿签成功"];
                }
                else {
                    [[AppDelegate getAppDelegate]  alert:AlertTypeAlert message:@"稿签另存失败"];
                }
            }
            
            self.manuscriptTemplate.name = orginalName;
            self.manuscriptTemplate.mt_id = orginalID;
            self.manuscriptTemplate.is3Tnews = orginalIs3Tnews;
            self.manuscriptTemplate.isDefault = orginalIsDefault;
            self.manuscriptTemplate.createTime = orginalCreatetime;
            self.manuscriptTemplate.isSystemOriginal = orginalIsSystemoriginal;
        }
    }
    else if(anIndex == 0){
        if (aView.tag == 0) {
            [[NetworkManager sharedManager]  cancelRequestForDelegate:self];
            if (self.templateType == TemplateTypeNew)
            {
                NSInteger index=[self.navigationController.viewControllers count]-2;
                TemplateManageController *templateManageController = [self.navigationController.viewControllers objectAtIndex:index];
                [templateManageController reloadtable];
                [self.navigationController popToViewController:templateManageController  animated:YES];
                
            }
            else {
                NSInteger index=[self.navigationController.viewControllers count]-2;
                if(self.templateType == TemplateTypeCheckAble || self.templateType == TemplateTypeEditAble || self.templateType == TemplateTypeSaveAs){
                    //返回稿签对象
                    [self.delegate returnManuScriptTemplate:self.manuscriptTemplate];
                    
                }
                else if(self.templateType == TemplateTypeExist){
                    //返回稿签对象
                    [self.delegate reloadtable];
                }
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index]  animated:YES];
            }
            
        }
    }
}




@end
