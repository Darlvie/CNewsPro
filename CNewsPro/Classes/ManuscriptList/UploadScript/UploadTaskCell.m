//
//  UploadTaskCell.m
//  CNewsPro
//
//  Created by hooper on 2/13/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "UploadTaskCell.h"

static const CGFloat  kTableCellHeight = 95;

@implementation UploadTaskCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(10, 85, 300, 10);
        [self.contentView addSubview:self.progressView];
        
        self.btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSwitch.frame = CGRectMake(5, 20, 25, 25);
        //btnSwitch.titleLabel.textColor=[UIColor clearColor];
        [self.btnSwitch setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.btnSwitch setTitle:@"0" forState:UIControlStateNormal];
        [self.btnSwitch setImage:[UIImage imageNamed:@"SendingScript_pause"] forState:UIControlStateNormal];
        
        self.manuscriptsTitle=[[UILabel alloc] initWithFrame:CGRectMake(46, 5, 159, 20)];
        self.manuscriptsTitle.backgroundColor=[UIColor clearColor];
        self.manuscriptsTitle.textColor=[UIColor blackColor];
        [self.manuscriptsTitle setFont:[UIFont systemFontOfSize:17]];
        
        
        
        self.manuscriptsContent=[[UITextView alloc] initWithFrame:CGRectMake(40, 25, 300 , kTableCellHeight-55)];
        self.manuscriptsContent.backgroundColor=[UIColor clearColor];
        [self.manuscriptsContent setFont:[UIFont systemFontOfSize:16]];
        self.manuscriptsContent.textColor = [UIColor grayColor];
        self.manuscriptsContent.backgroundColor=[UIColor clearColor];
        self.manuscriptsContent.editable=false;

        self.fileLenth = [[UILabel alloc] initWithFrame:CGRectMake(25, kTableCellHeight-35, 150, 15)];
        self.fileLenth.backgroundColor=[UIColor clearColor];
        self.fileLenth.textColor=[UIColor grayColor];
        [self.fileLenth setFont:[UIFont systemFontOfSize:13]];
        
        self.leaveTime = [[UILabel alloc] initWithFrame:CGRectMake(175, kTableCellHeight-35, 150, 15)];
        self.leaveTime.backgroundColor=[UIColor clearColor];
        self.leaveTime.textColor=[UIColor grayColor];
        [self.leaveTime setFont:[UIFont systemFontOfSize:13]];
        
        
        self.line = [[UILabel alloc] initWithFrame:CGRectMake(0, kTableCellHeight-2, 481, 1)];
        self.line.backgroundColor=[UIColor colorWithRed:205.0f/255.0f green:212.0f/255.0f blue:217.0f/255.0f alpha:1];
        [self.contentView addSubview:self.line];
        
        [self.contentView addSubview:self.btnSwitch];
        [self.contentView addSubview:self.manuscriptsTitle];
        [self.contentView addSubview:self.manuscriptsContent];
        [self.contentView addSubview:self.attachmentimg];
        [self.contentView addSubview:self.leaveTime];
        [self.contentView addSubview:self.fileLenth];
    }
    return self;

}

//进入编辑模式添加的动画
- (void)setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        
        _m_checkImageView.center = pt;
        _m_checkImageView.alpha = alpha;
        
        [UIView commitAnimations];
    }
    else
    {
        _m_checkImageView.center = pt;
        _m_checkImageView.alpha = alpha;
    }
}

//自定义的编辑模式
- (void)setEditing:(BOOL)editting animated:(BOOL)animated
{
    if (self.editing == editting)
    {
        return;
    }
    
    [super setEditing:editting animated:animated];
    
    if (editting)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[UIView alloc] init];
        ////self.backgroundView.backgroundColor = [UIColor whiteColor];
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (_m_checkImageView == nil)
        {
            _m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SendingScript_UnCheck"]];
            [self addSubview:_m_checkImageView];
        }
        
        [self setChecked:self.m_checked];
        _m_checkImageView.frame = CGRectMake(0,0,25,24);
        _m_checkImageView.center = CGPointMake(-CGRectGetWidth(_m_checkImageView.frame) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
        _m_checkImageView.alpha = 0.0;
        [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
                                alpha:1.0 animated:animated];
    }
    else
    {
        _m_checked = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundView = nil;
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
        
        if (_m_checkImageView)
        {
            _m_checkImageView.frame = CGRectMake(0,0,25,24);
            [self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(_m_checkImageView.frame) * 0.5,
                                                      CGRectGetHeight(self.bounds) * 0.5)
                                    alpha:0.0
                                 animated:animated];
        }
    }
}

//自定义编辑模式下的选中图片
- (void)setChecked:(BOOL)checked
{
    if (checked)
    {
        _m_checkImageView.image = [UIImage imageNamed:@"editingScript_Checked.png"];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
    else
    {
        _m_checkImageView.image = [UIImage imageNamed:@"editingScript_Unchecked.png"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    _m_checked = checked;
}

@end
