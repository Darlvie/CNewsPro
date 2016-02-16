//
//  EditScriptCell.m
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "EditScriptCell.h"

@implementation EditScriptCell

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
    self.m_lbText1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 20)];
    [self.m_lbText1 setFont:[UIFont systemFontOfSize:15]];
    self.m_lbText1.backgroundColor = [UIColor clearColor];
    self.m_lbText1.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.m_lbText1];
    
    self.m_lbText2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 200 , 45)];
    [self.m_lbText2 setFont:[UIFont systemFontOfSize:14]];
    self.m_lbText2.backgroundColor = [UIColor clearColor];
    self.m_lbText2.textColor = [UIColor grayColor];
    self.m_lbText2.numberOfLines = 3;
    self.m_lbText2.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.m_lbText2];
    
    self.m_lbText3 = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, 80, 15)];
    [self.m_lbText3 setFont:[UIFont systemFontOfSize:13]];
    self.m_lbText3.backgroundColor = [UIColor clearColor];
    self.m_lbText3.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.m_lbText3];
    
    self.m_accessaryView = [[UIImageView alloc] init];
    CGRect accessaryViewSize = CGRectMake(210, 2, 80, 66);
    self.m_accessaryView.frame = accessaryViewSize;
    [self.contentView addSubview:self.m_accessaryView];
}

//进入编辑模式添加的动画
- (void) setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
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
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (_m_checkImageView == nil)
        {
            _m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"editingScript_Unchecked.png"]];
            [self addSubview:_m_checkImageView];
        }
        
        [self setChecked:_m_checked];
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
