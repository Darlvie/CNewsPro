//
//  EditScriptCell.m
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "MultipleScriptCell.h"
#import "AccessoriesDB.h"
#import "ScriptItem.h"
#import "Utility.h"

#define SCRIPT_CELL_LEFT_BORDER 10.0f
#define SCRIPT_CELL_RIGHT_BORDER 16.0f
#define SCRIPT_CELL_TOP_MARGEN 5.0f
#define SCRIPT_LABEL_HEIGHT 24.0f
#define SCRIPT_DATELABEL_WIDTH 110.0f
#define SCRIPT_CELL_HEIGHT 70.0f


@implementation MultipleScriptCell

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
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpScript];
    }
    return self;
}

//初始化cell内的控件
- (void)setUpScript {
    UIView *cellBackgroundView = [[UIView alloc] init];
    [self.contentView addSubview:cellBackgroundView];
    cellBackgroundView.backgroundColor = [UIColor whiteColor];
    self.cellBackgroundView = cellBackgroundView;
    
    UILabel *cellTitleLabel = [[UILabel alloc] init];
    cellTitleLabel.font = [UIFont systemFontOfSize:15];
    cellTitleLabel.textAlignment = NSTextAlignmentLeft;
    [cellBackgroundView addSubview:cellTitleLabel];
    self.cellTitleLabel = cellTitleLabel;
    
    UILabel *cellDateLabel = [[UILabel alloc] init];
    cellDateLabel.font = [UIFont systemFontOfSize:12];
    cellDateLabel.textColor = [UIColor lightGrayColor];
    cellDateLabel.textAlignment = NSTextAlignmentRight;
    [cellBackgroundView addSubview:cellDateLabel];
    self.cellDateLabel = cellDateLabel;
    
    UILabel *cellDetailLabel = [[UILabel alloc] init];
    cellDetailLabel.font = [UIFont systemFontOfSize:15];
    cellDetailLabel.textColor = [UIColor lightGrayColor];
    cellDetailLabel.textAlignment = NSTextAlignmentLeft;
    cellDetailLabel.numberOfLines = 0;
    cellDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [cellBackgroundView addSubview:cellDetailLabel];
    self.cellDetailLabel = cellDetailLabel;
    
    UIImageView *cellImageView = [[UIImageView alloc] init];
    [cellBackgroundView addSubview:cellImageView];
    self.cellImageView = cellImageView;
}

-(void)setScriptItem:(ScriptItem *)scriptItem {
    _scriptItem = scriptItem;
    
    //取得稿件附件列表：取得第一个附件将其放入淘汰列表的附图位置
    AccessoriesDB *adb =  [[AccessoriesDB alloc] init];
    NSMutableArray *accessoriesList = [[NSMutableArray alloc] init];
    accessoriesList = [adb getAccessoriesListByMId:scriptItem.m_id];
    
    self.cellBackgroundView.frame = self.bounds;
    
    self.cellDateLabel.frame = CGRectMake(SCREEN_WIDTH-SCRIPT_CELL_RIGHT_BORDER-SCRIPT_DATELABEL_WIDTH-SCRIPT_CELL_LEFT_BORDER, SCRIPT_CELL_TOP_MARGEN, SCRIPT_DATELABEL_WIDTH, SCRIPT_LABEL_HEIGHT);
    
    if (accessoriesList.count == 0) {
        self.cellTitleLabel.frame = CGRectMake(SCRIPT_CELL_LEFT_BORDER, SCRIPT_CELL_TOP_MARGEN, SCREEN_WIDTH-SCRIPT_CELL_LEFT_BORDER*2-SCRIPT_DATELABEL_WIDTH-SCRIPT_CELL_RIGHT_BORDER, SCRIPT_LABEL_HEIGHT);
        self.cellDetailLabel.frame = CGRectMake(SCRIPT_CELL_LEFT_BORDER, SCRIPT_CELL_TOP_MARGEN+SCRIPT_LABEL_HEIGHT, SCREEN_WIDTH-SCRIPT_CELL_LEFT_BORDER*2-SCRIPT_CELL_RIGHT_BORDER, SCRIPT_CELL_HEIGHT-SCRIPT_CELL_TOP_MARGEN*2-SCRIPT_LABEL_HEIGHT);
    } else {
        self.cellImageView.frame = CGRectMake(SCRIPT_CELL_LEFT_BORDER, SCRIPT_CELL_TOP_MARGEN, 84, SCRIPT_CELL_HEIGHT-SCRIPT_CELL_TOP_MARGEN*2);
        self.cellTitleLabel.frame = CGRectMake(SCRIPT_CELL_LEFT_BORDER*2+CGRectGetWidth(self.cellImageView.frame), SCRIPT_CELL_TOP_MARGEN, SCREEN_WIDTH-SCRIPT_CELL_LEFT_BORDER*3-CGRectGetWidth(self.cellImageView.frame)-SCRIPT_DATELABEL_WIDTH-SCRIPT_CELL_RIGHT_BORDER, SCRIPT_LABEL_HEIGHT);
        self.cellDetailLabel.frame = CGRectMake(SCRIPT_CELL_LEFT_BORDER*2+CGRectGetWidth(self.cellImageView.frame), SCRIPT_CELL_TOP_MARGEN+SCRIPT_LABEL_HEIGHT, SCREEN_WIDTH-SCRIPT_CELL_LEFT_BORDER*3-CGRectGetWidth(self.cellImageView.frame)-SCRIPT_CELL_RIGHT_BORDER, SCRIPT_CELL_HEIGHT-SCRIPT_CELL_TOP_MARGEN*2-SCRIPT_LABEL_HEIGHT);
    }
    
    self.cellTitleLabel.text = scriptItem.title;
    self.cellDetailLabel.text = scriptItem.contents;
    self.cellDateLabel.text = [Utility getLocalTimeStamp:scriptItem.createTime];
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
        
        if (_m_checkImageView == nil)
        {
            _m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checked_2-1"]];
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
        _m_checkImageView.image = [UIImage imageNamed:@"checked_2_filled"];
        self.cellBackgroundView.backgroundColor = RGB(239, 239, 239);
        self.backgroundView = [[UIView alloc] init];
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"commonbg.png"]];
        self.backgroundView = bgImageView;
    }
    else
    {
        _m_checkImageView.image = [UIImage imageNamed:@"checked_2-1"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView = nil;

    }
    _m_checked = checked;
}






@end
