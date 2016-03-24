//
//  UserGuideViewController.m
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "UserGuideViewController.h"
#import "LoginViewController.h"

@interface UserGuideViewController ()

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBarHidden = YES;
    
    [self initGuide];   //加载新用户指导页面
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initGuide
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH*4, 0)];
    [scrollView setPagingEnabled:YES];  //视图整页显示
    scrollView.showsHorizontalScrollIndicator = NO;
    [scrollView setBounces:NO]; //避免弹跳效果,避免把根视图露出来
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview setImage:[UIImage imageNamed:@"guide0.png"]];
    [scrollView addSubview:imageview];
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview1 setImage:[UIImage imageNamed:@"guide1.png"]];
    [scrollView addSubview:imageview1];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview2 setImage:[UIImage imageNamed:@"guide2.png"]];
    [scrollView addSubview:imageview2];
    
    UIImageView *imageview3 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageview3 setImage:[UIImage imageNamed:@"guide3.png"]];
    imageview3.userInteractionEnabled = YES;    //打开imageview3的用户交互;否则下面的button无法响应
    [scrollView addSubview:imageview3];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//在imageview3上加载一个透明的button
    [button setTitle:nil forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [button addTarget:self action:@selector(firstpressed) forControlEvents:UIControlEventTouchUpInside];
    [imageview3 addSubview:button];
    
    [self.view addSubview:scrollView];
}

- (void)firstpressed
{
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                    
    [self presentViewController:loginVC animated:YES completion:nil];
}

@end
