//
//  ScriptCell.m
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "ScriptCell.h"

@implementation ScriptCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//设置cell结构
- (void)updateCell {
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
    [self.lbText3 setFont:[UIFont systemFontOfSize:13]];
    self.lbText3.backgroundColor=[UIColor clearColor];
    self.lbText3.textColor=[UIColor grayColor];
    [self.contentView addSubview:self.lbText3];
    
    self.accessaryView = [[UIImageView alloc] init];
    CGRect accessaryViewSize = CGRectMake(210, 2, 80, 66);
    self.accessaryView.frame = accessaryViewSize;
    [self.contentView addSubview:self.accessaryView];
}

//自定义编辑模式下的选中图片
- (void)setChecked:(BOOL)checked {
    if (checked) {
        self.checkImageView.image = [UIImage imageNamed:@"sent_selectBg.png"];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    } else {
        self.checkImageView.image = [UIImage imageNamed:@"sent_unselectBg.png"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    self.checked = checked;
}

//自定义的编辑模式
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if ((self.editing = editing)) {
        return;
    }
    [super setEditing:editing animated:YES];
    
    if (editing) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[UIView alloc] init];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (self.checkImageView == nil) {
            self.checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sent_unselectBg.png"]];
            [self addSubview:self.checkImageView];
        }
        [self setChecked:self.checked];
        self.checkImageView.frame = CGRectMake(0,0,25,24);
        self.checkImageView.center = CGPointMake(-CGRectGetWidth(self.checkImageView.frame) * 0.5,
                                                 CGRectGetHeight(self.bounds) * 0.5);
        self.checkImageView.alpha = 0.0;
        [self setCheckImageViewCenter:CGPointMake(20.5, CGRectGetHeight(self.bounds) * 0.5)
                                alpha:1.0
                             animated:animated];
    } else {
        self.checked = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundView = nil;
        if (self.checkImageView) {
            self.checkImageView.frame = CGRectMake(0,0,25,24);
            [self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(self.checkImageView.frame) * 0.5,
                                                      CGRectGetHeight(self.bounds) * 0.5)
                                    alpha:0.0
                                 animated:animated];
        }
    }
}

//进入编辑模式添加的动画
- (void)setCheckImageViewCenter:(CGPoint)cp alpha:(CGFloat)alpha animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        
        self.checkImageView.center = cp;
        self.checkImageView.alpha = alpha;
        [UIView commitAnimations];
    } else {
        self.checkImageView.center = cp;
        self.checkImageView.alpha = alpha;
    }
}





@end
