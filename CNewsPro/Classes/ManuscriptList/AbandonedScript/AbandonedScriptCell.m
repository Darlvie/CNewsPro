//
//  AbandonedScriptCell.m
//  CNewsPro
//
//  Created by hooper on 2/14/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AbandonedScriptCell.h"

@implementation AbandonedScriptCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//设置cell结构
-(void)updateCell
{
    self.lbText1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 20)];
    [self.lbText1 setFont:[UIFont systemFontOfSize:15]];
    self.lbText1.backgroundColor = [UIColor clearColor];
    self.lbText1.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.lbText1];
    
    self.lbText2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 200 , 45)];
    [self.lbText2 setFont:[UIFont systemFontOfSize:14]];
    self.lbText2.backgroundColor = [UIColor clearColor];
    self.lbText2.textColor = [UIColor grayColor];
    self.lbText2.numberOfLines = 3;
    self.lbText2.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.lbText2];
    
    self.lbText3 = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, 80, 15)];
    [self.lbText3 setFont:[UIFont systemFontOfSize:12]];
    self.lbText3.backgroundColor=[UIColor clearColor];
    self.lbText3.textColor=[UIColor grayColor];
    [self.contentView addSubview:self.lbText3];
    
    self.accessaryView = [[UIImageView alloc] init];
    CGRect accessaryViewSize = CGRectMake(210, 2, 80, 66);
    self.accessaryView.frame = accessaryViewSize;
    [self.contentView addSubview:self.accessaryView];
  
}

//自定义编辑模式下的选中图片
- (void)setChecked:(BOOL)checked
{
    if (checked)
    {
        _checkImageView.image = [UIImage imageNamed:@"abandoned_selectBg.png"];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
    else
    {
        _checkImageView.image = [UIImage imageNamed:@"abandoned_unselectBg.png"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    _checked = checked;
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
        
        _checkImageView.center = pt;
        _checkImageView.alpha = alpha;
        
        [UIView commitAnimations];
    }
    else
    {
        _checkImageView.center = pt;
        _checkImageView.alpha = alpha;
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
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
//
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (_checkImageView == nil)
        {
            _checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abandoned_unselectBg.png"]];
            [self addSubview:_checkImageView];
        }
        
        [self setChecked:_checked];
        _checkImageView.frame = CGRectMake(0,0,25,24);
        _checkImageView.center = CGPointMake(-CGRectGetWidth(_checkImageView.frame) * 0.5,
                                              CGRectGetHeight(self.bounds) * 0.5);
        _checkImageView.alpha = 0.0;
        [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
                                alpha:1.0 animated:animated];
    }
    else
    {
        _checked = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundView = nil;

        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
        
        if (_checkImageView)
        {
            _checkImageView.frame = CGRectMake(0,0,25,24);
            [self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(_checkImageView.frame) * 0.5,
                                                      CGRectGetHeight(self.bounds) * 0.5)
                                    alpha:0.0 
                                 animated:animated];
        }
    }
}

@end
