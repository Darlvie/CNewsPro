//
//  DetailAuditNewsViewController.m
//  CNewsPro
//
//  Created by hooper on 1/31/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "DetailAuditNewsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RequestMaker.h"
#import "Utility.h"
#import "AuditNewsItem.h"

@interface DetailAuditNewsViewController ()
@property(nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property(nonatomic,strong) UITextView *contentView;
@property(nonatomic,strong) AuditNewsItem *newsItem;
@end

@implementation DetailAuditNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //导航试图
    [self.titleLabelAndImage setImage:[UIImage imageNamed:@"editingScript_Title.png"] forState:UIControlStateNormal];
    self.titleLabelAndImage.backgroundColor = [UIColor colorWithRed:194.0f/255.0f green:217.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    
    self.moviePlayer = [[MPMoviePlayerController alloc]init];
    [[self.moviePlayer view] setFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame), self.widthOfMainView, self.heightOfMainView-80)];
    [self.view addSubview:self.moviePlayer.view];
    
    
    self.contentView = [[UITextView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-80, self.widthOfMainView, 80.0)];
    self.contentView.editable = NO;
    [self.view addSubview:self.contentView];
}

- (void)viewDidAppear:(BOOL)animated
{
    //请求数据
    [RequestMaker getSingleNewByID:self.newsId delegate:self];
}

-(void)requestDidFinish:(NSDictionary*)responseInfo
{
    if ([[responseInfo objectForKey:REQUEST_STATUS] isEqualToString:REQUEST_FAIL] ) {
        NSLog(@"服务器无响应");
        return;
    }
    self.newsItem = [Utility parseAuditNewsItemFromData:[responseInfo objectForKey:RESPONSE_DATA]];
    
    [self.titleLabelAndImage setTitle:self.newsItem.title forState:UIControlStateNormal];
    
    self.contentView.text = self.newsItem.content;
    
    self.moviePlayer.contentURL = [NSURL URLWithString:self.newsItem.videoSrc];
    [self.moviePlayer play];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
