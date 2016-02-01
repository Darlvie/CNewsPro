//
//  EditScriptCell.h
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditScriptCell : UITableViewCell

@property (nonatomic, assign) BOOL m_checked;
@property (nonatomic, strong) UILabel* m_lbText1;
@property (nonatomic, strong) UILabel* m_lbText2;
@property (nonatomic, strong) UILabel* m_lbText3;
@property (nonatomic, strong) UIImageView* m_accessaryView;
@property (nonatomic, strong) UIImageView* m_checkImageView;

- (void)updateCell;
- (void)setChecked:(BOOL)checked;

@end
