//
//  AttachDetailController.m
//  CNewsPro
//
//  Created by hooper on 2/2/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AttachDetailController.h"
#import "Utility.h"
#import "Accessories.h"
#import "AccessoriesDB.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayerController.h"
#import "UIView+FirstResponder.h"

#define TV_HEIGHT self.view.frame.size.height*0.4f
#define DOWN  self.view.frame.size.height*0.2f

static const NSInteger kTFHeight = 30;
static const NSInteger kBtnHeight = 150;
static const NSInteger kLableHeight = 30;

@interface AttachDetailController () <UITextFieldDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UITextField *tvTitle;
@property (nonatomic,strong) UITextView *tvContent;
@property (nonatomic,strong) UIButton *keyboardButton;
@property (nonatomic,assign) NSInteger keyboardHeight;
@property (nonatomic,assign) BOOL keyboardHide;
@end

@implementation AttachDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"manuscript_logo.png"] forState:UIControlStateNormal];
    [self.titleLabelAndImage setTitle:@"附件详情" forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:185.0f/225.0f alpha:1.0f];
    
    //liying
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView)];
    //scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    //scrollView.backgroundColor=[UIColor redColor];
    [self.view addSubview:self.scrollView];
    
    NSInteger  Y = self.view.frame.size.height-TV_HEIGHT-kTFHeight-kBtnHeight;
    UIButton *btnimage=[[UIButton alloc] initWithFrame:CGRectMake(55, Y-DOWN-2, 200, kBtnHeight)];
    [btnimage addTarget:self action:@selector(touchBtnimg:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnimage];
    
    if ([self.filetype isEqualToString:@"PHOTO"]) {
        [btnimage setImage:[Utility scale:[UIImage imageWithContentsOfFile:self.filepath] toHeight:150] forState:UIControlStateNormal];
    }
    if ([self.filetype isEqualToString:@"AUDIO"]) {
        [btnimage setImage:[Utility scale:[UIImage imageNamed:@"express_audioBtn.png"] toHeight:170] forState:UIControlStateNormal];
    }
    if ([self.filetype isEqualToString:@"VIDEO"]) {
        [btnimage setImage:[Utility scale:[UIImage imageNamed:@"video.png"] toHeight:120] forState:UIControlStateNormal];
    }
    
    //liying
    UILabel *static_title=[[UILabel alloc]initWithFrame:CGRectMake(12, self.view.frame.size.height-TV_HEIGHT-kLableHeight-DOWN, 51, kLableHeight)];
    
    [static_title setFont:[UIFont fontWithName:@"System" size:17.0f]];
    static_title.textColor = [UIColor colorWithRed:117.0f/255.0f green:162.0f/255.0f blue:240.0f/225.0f alpha:1.0f];
    [self.scrollView addSubview:static_title];
    static_title.text = @"标题";
    
    //liying
    self.tvTitle=[[UITextField alloc]initWithFrame:CGRectMake(61, self.view.frame.size.height-TV_HEIGHT-kTFHeight-DOWN, 248, kTFHeight)];
    self.tvTitle.placeholder = @"请输入标题...";
    self.tvTitle.textColor   = [UIColor grayColor];
    [self.tvTitle setFont:[UIFont fontWithName:@"黑体-简 细体" size:15.0f]];
//    [self.tvTitle addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
    self.tvTitle.delegate = self;
    self.tvTitle.returnKeyType =UIReturnKeyDone;
    [self.scrollView addSubview:self.tvTitle];
    
    
    //liying
    self.tvContent=[[UITextView alloc]initWithFrame:CGRectMake(12, self.view.frame.size.height-TV_HEIGHT-DOWN, 297, TV_HEIGHT)];
    self.tvContent.font = [UIFont systemFontOfSize:15.0];
    self.tvContent.textAlignment = NSTextAlignmentLeft;
    self.tvContent.userInteractionEnabled = YES;
    self.tvContent.multipleTouchEnabled = YES;
    [self.scrollView addSubview:self.tvContent];
    
    //绑定“标题”和“正文”的内容
    self.tvTitle.text = self.accessory.title;
    self.tvContent.text = self.accessory.desc;
    
    if( ![self.operationType isEqualToString:@"detail"] )
    {
    }
    else
    {
        self.tvTitle.enabled = NO;
        self.tvContent.editable = NO;
        
        if([self.accessory.title isEqualToString:@""])
        {
            self.tvTitle.text = @" ";
        }
    }
    
    //liying
    UIImageView *imageUp=[[UIImageView alloc]initWithFrame:CGRectMake(12, self.view.frame.size.height-TV_HEIGHT-DOWN-2, 297, 1)];
    [imageUp setImage:[UIImage imageNamed:@"TempleView_line"]];
    [self.scrollView addSubview:imageUp];
    
    //liying
    UIImageView *imageDown=[[UIImageView alloc]initWithFrame:CGRectMake(12, self.view.frame.size.height-DOWN-1, 297, 1)];
    [imageDown setImage:[UIImage imageNamed:@"TempleView_line"]];
    [self.scrollView addSubview:imageDown];
    
    
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //控制键盘按钮
    self.keyboardHide=TRUE;
    UIButton *keyboardButtonTemp = [[UIButton alloc] initWithFrame:CGRectMake(290,430,40,50)];
    [keyboardButtonTemp setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
    [keyboardButtonTemp addTarget:self action:@selector(controlkeyboard:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardButton = keyboardButtonTemp;
    [self.view addSubview:self.keyboardButton];
    [self.keyboardButton setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新附件的标题和正文信息
- (void)saveAttachDetail:(id)sender
{
    if( ![self.operationType isEqualToString:@"detail"] )
    {
        self.accessory.title = [Utility trimBlankSpace:self.tvTitle.text];
        self.accessory.desc = [Utility trimBlankSpace:self.tvContent.text];
        AccessoriesDB *acdb=[[AccessoriesDB alloc] init];
        
        [acdb updateAccessories:self.accessory];
    }
    [self returnToParentView:nil];
}

- (void)textFieldDoneEditing:(id)sender
{
    [self.tvContent becomeFirstResponder];
}

#pragma mark - KeyboardNotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    UIViewAnimationCurve animationCurve	= [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //if (self.segmentedControl.selectedSegmentIndex==0) {
    [UIView beginAnimations:@"RS_showKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    
    CGSize kbSize = [[[notification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    self.tvContent.frame = CGRectMake(12, self.view.frame.size.height-TV_HEIGHT-DOWN, 297, TV_HEIGHT+DOWN-kbSize.height);

    self.keyboardHeight = kbSize.height;

    self.keyboardButton.alpha = 1.0;
    self.keyboardButton.frame = CGRectMake(280,
                                      self.view.frame.size.height-self.keyboardHeight-36,//liying
                                      40,
                                      50);
    [UIView commitAnimations];
    self.keyboardHide=FALSE;
    [self.keyboardButton setHidden:FALSE];
    
    //设定当前屏幕的高度和显示位置，以适应用户编辑
    [self.scrollView setContentSize:CGSizeMake(320,self.view.frame.size.height*2)];//liying
    [self.scrollView setContentOffset:CGPointMake(0,45) animated:TRUE];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //if (self.segmentedControl.selectedSegmentIndex==0) {
//    UIViewAnimationCurve animationCurve	= [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
//    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.tvContent.frame=CGRectMake(12, self.view.frame.size.height-TV_HEIGHT-DOWN, 297, TV_HEIGHT);
    
    [UIView commitAnimations];
    self.keyboardHide=TRUE;
    [self.keyboardButton setHidden:TRUE];
    
    //设定当前屏幕的高度和显示位置，以适应用户编辑
    [self.scrollView setContentSize:CGSizeMake(320,460)];
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:TRUE];
}




#pragma mark - Action Method
- (void)touchBtnimg:(id)sender
{
    //退出键盘
    [self.view endEditing:YES];
    
    if ([self.filetype isEqualToString:@"VIDEO"]) {
        NSURL *url=[NSURL URLWithString:[@"file://" stringByAppendingString:self.filepath]];
        
        MPMoviePlayerViewController *moviePlayViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [[moviePlayViewController moviePlayer] prepareToPlay];
        [[moviePlayViewController moviePlayer] setShouldAutoplay:YES];
        [[moviePlayViewController moviePlayer] setControlStyle:2];
        [[moviePlayViewController moviePlayer] setScalingMode:MPMovieScalingModeFill];
        [self presentMoviePlayerViewControllerAnimated:moviePlayViewController];
    }
    if ([self.filetype isEqualToString:@"AUDIO"]) {
        // AVAudioPlayer *player
        AudioPlayerController *audioPlayerController = [[AudioPlayerController alloc] init];
        audioPlayerController.path = self.filepath;
        [self.navigationController pushViewController:audioPlayerController animated:YES];
        
    }
    if ([self.filetype isEqualToString:@"PHOTO"]) {
        UIImage *BigImg = [UIImage imageWithContentsOfFile:self.filepath];
        UIImageView *BigImgView = [[UIImageView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        [BigImgView setBackgroundColor:[UIColor blackColor]];
        [BigImgView setContentMode:UIViewContentModeScaleAspectFit];
        [BigImgView setUserInteractionEnabled:YES];
        //添加点击事件
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [BigImgView addGestureRecognizer:singleTap];
        [BigImgView setImage:BigImg];
        [[UIApplication sharedApplication].keyWindow addSubview:BigImgView];
    }
}

//控制键盘弹出和隐藏
-(void)controlkeyboard:(id)sender
{
    if (self.keyboardHide) {
        //[self.scrollView1  becomeFirstResponder];//弹出键盘
        [self.tvContent becomeFirstResponder];
    }
    else {
        [[self.view findFirstResponder] resignFirstResponder];//隐藏键盘
    }
}

- (void)tapImageView:(id)sender
{
    [[sender view] removeFromSuperview];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.returnKeyType=UIReturnKeyDefault;
    [self.tvContent   becomeFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.returnKeyType=UIReturnKeyDone;
    return YES;
}




@end
