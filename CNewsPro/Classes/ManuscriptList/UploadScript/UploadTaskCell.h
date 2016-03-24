//
//  UploadTaskCell.h
//  CNewsPro
//
//  Created by hooper on 2/13/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UploadTaskCell : UITableViewCell

@property (nonatomic,strong) UIImageView*	m_checkImageView;
@property (nonatomic,assign) BOOL			m_checked;
@property (weak, nonatomic)  UIView *cellBackgroundView;
@property (nonatomic,retain) UIProgressView *progressView;
@property (nonatomic,strong) UIButton *btnSwitch;
@property (nonatomic,strong) UILabel  *manuscriptsTitle;
@property (nonatomic,strong) UITextView  *manuscriptsContent;
@property (nonatomic,strong) UIImageView *attachmentimg;
@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) UILabel *fileLenth;//文件大小
@property (nonatomic,strong) UILabel *leaveTime;

- (void)setChecked:(BOOL)checked;

@end
