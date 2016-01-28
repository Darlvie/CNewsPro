//
//  XinHuaManuscriptController.m
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "XinHuaManuscriptController.h"
#import "User.h"
#import "Utility.h"
#import "NetworkManager.h"
#import "ManuscriptTemplateDB.h"
#import "Manuscripts.h"
#import "NewTextController.h"
#import "NewImageController.h"
#import "NewAudioController.h"
#import "NewVideoController.h"
#import "EditingScriptController.h"
#import "TaskManagementViewController.h"
#import "SendedScriptController.h"
#import "AbandonedScriptController.h"
#import "TemplateManageController.h"
#import "NewArticlesController.h"
#import "MoreViewController.h"
#import "SystemManagerController.h"
#import "AuditNewsViewController.h"

static const CGFloat kMargin          = 20;

@interface XinHuaManuscriptController () <UIAlertViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *auditNewsBtn;

@end

@implementation XinHuaManuscriptController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width*2, self.scrollView.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self setUpScrollView];
    
    self.pageControl.numberOfPages = 2;
    
    User *userInfo = [Utility sharedSingleton].userInfo;
    if ([userInfo.rightAuditNews isEqualToString:@"true"]) {
        self.auditNewsBtn.hidden = NO;
    }else
    {
        self.auditNewsBtn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NetworkManager sharedManager] cancelRequestForDelegate:self];
}

#pragma mark - Private
- (void)setUpScrollView {
    CGFloat kAuditItemWidth   = (self.scrollView.frame.size.width - kMargin*3) / 2.0;
    CGFloat kAuditItemHeight  = (self.scrollView.frame.size.height - kMargin*3) / 2.0;
    
    UIButton *newTextItem = [[UIButton alloc] init];
    newTextItem.frame = CGRectMake(kMargin, kMargin, kAuditItemWidth, kAuditItemHeight);
    [newTextItem setBackgroundImage:[UIImage imageNamed:@"FlashWord2.png"] forState:UIControlStateNormal];
    [newTextItem setTitle:@"文字快讯" forState:UIControlStateNormal];
    [newTextItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [newTextItem addTarget:self action:@selector(showNewText:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:newTextItem];
    
    UIButton *newImageItem = [[UIButton alloc] init];
    newImageItem.frame = CGRectMake(kMargin*2 + kAuditItemWidth, kMargin, kAuditItemWidth, kAuditItemHeight);
    [newImageItem setBackgroundImage:[UIImage imageNamed:@"FlashPhoto2.png"] forState:UIControlStateNormal];
    [newImageItem setTitle:@"图片快讯" forState:UIControlStateNormal];
    [newImageItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [newImageItem addTarget:self action:@selector(showNewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:newImageItem];
    
    UIButton *newAudioItem = [[UIButton alloc] init];
    newAudioItem.frame = CGRectMake(kMargin, kMargin*2 + kAuditItemHeight, kAuditItemWidth, kAuditItemHeight);
    [newAudioItem setBackgroundImage:[UIImage imageNamed:@"FlashVoice2.png"] forState:UIControlStateNormal];
    [newAudioItem setTitle:@"音频快讯" forState:UIControlStateNormal];
    [newAudioItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [newAudioItem addTarget:self action:@selector(showNewAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:newAudioItem];
    
    UIButton *newVideoItem = [[UIButton alloc] init];
    newVideoItem.frame = CGRectMake(kMargin*2 + kAuditItemWidth, kMargin*2 + kAuditItemHeight, kAuditItemWidth, kAuditItemHeight);
    [newVideoItem setBackgroundImage:[UIImage imageNamed:@"FlashVideo2.png"] forState:UIControlStateNormal];
    [newVideoItem setTitle:@"视频快讯" forState:UIControlStateNormal];
    [newVideoItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [newVideoItem addTarget:self action:@selector(showNewVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:newVideoItem];
    
    UIButton *editingArticlesItem = [[UIButton alloc] init];
    editingArticlesItem.frame = CGRectMake(kMargin*4 + kAuditItemWidth*2, kMargin, kAuditItemWidth, kAuditItemHeight);
    [editingArticlesItem setBackgroundImage:[UIImage imageNamed:@"EdittingScript1.png"] forState:UIControlStateNormal];
    [editingArticlesItem setTitle:@"在编稿件" forState:UIControlStateNormal];
    [editingArticlesItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [editingArticlesItem addTarget:self action:@selector(showEditingArticles:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:editingArticlesItem];
    
    UIButton *watingSendArticlesItem = [[UIButton alloc] init];
    watingSendArticlesItem.frame = CGRectMake(kMargin*5 + kAuditItemWidth*3, kMargin, kAuditItemWidth, kAuditItemHeight);
    [watingSendArticlesItem setBackgroundImage:[UIImage imageNamed:@"SendScript1.png"] forState:UIControlStateNormal];
    [watingSendArticlesItem setTitle:@"待发稿件" forState:UIControlStateNormal];
    [watingSendArticlesItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [watingSendArticlesItem addTarget:self action:@selector(showWatingSendedArticle:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:watingSendArticlesItem];
    
    UIButton *sendedArticlesItem = [[UIButton alloc] init];
    sendedArticlesItem.frame = CGRectMake(kMargin*4 + kAuditItemWidth*2, kMargin*2 + kAuditItemHeight, kAuditItemWidth, kAuditItemHeight);
    [sendedArticlesItem setBackgroundImage:[UIImage imageNamed:@"SendedScript1.png"] forState:UIControlStateNormal];
    [sendedArticlesItem setTitle:@"已发稿件" forState:UIControlStateNormal];
    [sendedArticlesItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [sendedArticlesItem addTarget:self action:@selector(showSendedArticles:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:sendedArticlesItem];
    
    UIButton *eliminatedArticlesItem = [[UIButton alloc] init];
    eliminatedArticlesItem.frame = CGRectMake(kMargin*5 + kAuditItemWidth*3, kMargin*2 + kAuditItemHeight, kAuditItemWidth, kAuditItemHeight);
    [eliminatedArticlesItem setBackgroundImage:[UIImage imageNamed:@"Eliminated1.png"] forState:UIControlStateNormal];
    [eliminatedArticlesItem setTitle:@"淘汰稿件" forState:UIControlStateNormal];
    [eliminatedArticlesItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [eliminatedArticlesItem addTarget:self action:@selector(showEliminatedArticles:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:eliminatedArticlesItem];
}

- (void)alertCheckResult:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认",nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else {
        //弹出稿签模板配制页
        TemplateManageController *tagManageController = [[TemplateManageController alloc]init];
        [self.navigationController pushViewController:tagManageController animated:YES];
    }
}

#pragma mark - AuditItemAction

//快讯稿的默认标题不能为空
//新建“文字快讯”
- (void)showNewText:(id)sender
{
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    Manuscripts *mscripts = [[Manuscripts alloc] init];
    mscripts.mTemplate = [mdb getDefaultManuscriptTemplate:TEXT_EXPRESS_TEMPLATE_TYPE
                                                 LoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    
    NSString *info=[Utility checkInfoIsCompleted:mscripts];
    if ([info isEqualToString:@""]) {
        NewTextController *newTextController = [[NewTextController alloc] init];
        newTextController.manuscript_id = @"";
        newTextController.title = @"新建文字快讯";
        [self.navigationController pushViewController:newTextController animated:YES];
    }else {
        NSString *message = [NSString stringWithFormat:@"%@\n%@",info,@"请完善文字快讯稿签内容"];
        [self alertCheckResult:message];
    }
}

//新建“图片快讯”
- (void)showNewImage:(id)sender
{
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    Manuscripts *mscripts = [[Manuscripts alloc] init];
    mscripts.mTemplate = [mdb getDefaultManuscriptTemplate:PICTURE_EXPRESS_TEMPLATE_TYPE
                                                 LoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
                                 
    NSString *info=[Utility checkInfoIsCompleted:mscripts];
    if ([info isEqualToString:@""]) {
        NewImageController *newImageController = [[NewImageController alloc] init];
        newImageController.manuscript_id = @"";
        newImageController.title = @"新建图片快讯";
        [self.navigationController pushViewController:newImageController animated:YES];
    }
    else{
        NSString *message = [NSString stringWithFormat:@"%@\n%@",info,@"请完善图片快讯稿签内容"];
        [self alertCheckResult:message];
    }
}

//新建“音频快讯”
- (void)showNewAudio:(id)sender
{
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    Manuscripts *mscripts = [[Manuscripts alloc] init];
    mscripts.mTemplate = [mdb getDefaultManuscriptTemplate:AUDIO_EXPRESS_TEMPLATE_TYPE
                                                 LoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    
    NSString *info=[Utility checkInfoIsCompleted:mscripts];
    if ([info isEqualToString:@""]) {
        NewAudioController *newAudioController = [[NewAudioController alloc] init];
        newAudioController.manuscript_id = @"";
        newAudioController.title = @"新建音频快讯";
        [self.navigationController pushViewController:newAudioController animated:YES];
    }
    else{
        NSString *message = [NSString stringWithFormat:@"%@\n%@",info,@"请完善音频快讯稿签内容"];
        [self alertCheckResult:message];
    }
}

//新建视频快讯”
-(IBAction)showNewVideo:(id)sender
{
    ManuscriptTemplateDB *mdb = [[ManuscriptTemplateDB alloc] init];
    Manuscripts *mscripts = [[Manuscripts alloc] init];
    mscripts.mTemplate = [mdb getDefaultManuscriptTemplate:VIDEO_EXPRESS_TEMPLATE_TYPE
                                                 LoginName:[USERDEFAULTS objectForKey:LOGIN_NAME]];
    
    NSString *info=[Utility checkInfoIsCompleted:mscripts];
    if ([info isEqualToString:@""]) {
        NewVideoController *newVideoController = [[NewVideoController alloc] init];
        newVideoController.manuscript_id = @"";
        newVideoController.title = @"新建视频快讯";
        [self.navigationController pushViewController:newVideoController animated:YES];
    }
    else{
        NSString *message = [NSString stringWithFormat:@"%@\n%@",info,@"请完善视频快讯稿签内容"];
        [self alertCheckResult:message];
    }
    
}

//在编稿件
-(IBAction)showEditingArticles:(id)sender
{
    EditingScriptController *editingScriptListController = [[EditingScriptController alloc]init];
    self.navigationController.navigationBarHidden = YES;
    editingScriptListController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editingScriptListController animated:YES];
}

//待发稿件
-(IBAction)showWatingSendedArticle:(id)sender
{
    TaskManagementViewController *taskController = [[TaskManagementViewController alloc] init];
    taskController.title = @"任务管理";
    [self.navigationController pushViewController:taskController animated:YES];
}


//已发稿件页面
-(IBAction)showSendedArticles:(id)sender
{
    SendedScriptController *sendedScriptController = [[SendedScriptController alloc]init];
    self.navigationController.navigationBarHidden = YES;
    sendedScriptController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sendedScriptController animated:YES];
}

//淘汰稿件页面
-(IBAction)showEliminatedArticles:(id)sender
{
    AbandonedScriptController *abandonedScriptController = [[AbandonedScriptController alloc]init];
    self.navigationController.navigationBarHidden = YES;
    abandonedScriptController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:abandonedScriptController animated:YES];
}

//新建稿件
- (IBAction)showNewArticles:(UIButton *)sender {
    
    NewArticlesController *newArticlesVC = [[NewArticlesController alloc] init];
    newArticlesVC.manuscript_id = @"";
    [self.navigationController pushViewController:newArticlesVC animated:YES];
}

//显示“更多”页面
- (IBAction)showMoreViewController:(UIButton *)sender {
    MoreViewController *moreVC = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:moreVC animated:YES];
}

//系统设置界面
- (IBAction)showSystemSet:(UIButton *)sender {
    SystemManagerController *sysManagerVC = [[SystemManagerController alloc] init];
    sysManagerVC.title = @"任务管理";
    [self.navigationController pushViewController:sysManagerVC animated:YES];
}


- (IBAction)showAuditNews:(UIButton *)sender {
    AuditNewsViewController *auditNewsVC = [[AuditNewsViewController alloc] init];
    [self.navigationController pushViewController:auditNewsVC animated:YES];
}

//scrollView切换
- (IBAction)pageTurn:(UIPageControl *)sender {
    NSInteger switchPage = sender.currentPage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.scrollView.contentOffset = CGPointMake(320.0f * switchPage, 0.0f);
    [UIView commitAnimations];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffset = scrollView.contentOffset.x;
    if (contentOffset == 0) {
        self.pageControl.currentPage = 0;
    } else if (contentOffset >= 320){
        self.pageControl.currentPage = 1;
    }
}




@end
