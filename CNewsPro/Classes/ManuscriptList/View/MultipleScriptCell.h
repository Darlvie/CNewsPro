//
//  EditScriptCell.h
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScriptItem;
@interface MultipleScriptCell : UITableViewCell

@property (weak, nonatomic)  UIImageView *cellImageView;
@property (weak, nonatomic)  UILabel *cellTitleLabel;
@property (weak, nonatomic)  UILabel *cellDetailLabel;
@property (weak, nonatomic)  UILabel *cellDateLabel;
@property (weak, nonatomic)  UIView *cellBackgroundView;

@property (nonatomic,strong) ScriptItem *scriptItem;
@property (nonatomic, assign) BOOL m_checked;
@property (nonatomic, strong) UIImageView* m_checkImageView;

//- (void)updateCell;
- (void)setChecked:(BOOL)checked;

@end
