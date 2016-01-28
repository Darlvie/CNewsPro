//
//  ScriptCell.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manuscripts.h"

@interface ScriptCell : UITableViewCell

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,strong) UILabel *lbText1;
@property (nonatomic,strong) UILabel *lbText2;
@property (nonatomic,strong) UILabel *lbText3;
@property (nonatomic,strong) UIImageView *accessaryView;
@property(nonatomic,strong) UIImageView *checkImageView;

- (void)updateCell;

- (void)setChecked:(BOOL)checked;

@end

