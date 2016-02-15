//
//  AbandonedScriptCell.h
//  CNewsPro
//
//  Created by hooper on 2/14/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbandonedScriptCell : UITableViewCell

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,strong) UILabel* lbText1;
@property (nonatomic,strong) UILabel* lbText2;
@property (nonatomic,strong) UILabel* lbText3;
@property (nonatomic,strong) UIImageView* accessaryView;
@property (nonatomic,strong) UIImageView *checkImageView;

- (void)updateCell;
- (void)setChecked:(BOOL)checked;

@end
