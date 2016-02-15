//
//  NewTagDetailViewController.h
//  CNewsPro
//
//  Created by hooper on 1/30/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

typedef	NS_ENUM(NSInteger,TemplateType)
{
    TemplateTypeNew,
    TemplateTypeExist,
    TemplateTypeEditAble,
    TemplateTypeCheckAble,
    TemplateTypeSaveAs
};

@class ManuscriptTemplate,User;
@interface NewTagDetailViewController : RootViewController
/** 稿件属性视图 **/
@property (nonatomic,strong) UITableView *templateDetailView;
/** 另存功能用到的文本框 **/
@property (nonatomic,strong) UITextField *tfSaveAs;
/** 模版名称 **/
@property (nonatomic,strong) UITextField *tf0;
/** 稿源 **/
@property (nonatomic,strong) UITextView  *tf1;
/** 供稿类别 **/
@property (nonatomic,strong) UITextField *tf2;
/** 分类 **/
@property (nonatomic,strong) UITextView  *tf3;
/** 地区 **/
@property (nonatomic,strong) UITextView  *tf4;
/** 来稿地点 **/
@property (nonatomic,strong) UITextField *tf5;
/** 事发地点 **/
@property (nonatomic,strong) UITextField *tf6;
/** 报到地点 **/
@property (nonatomic,strong) UITextField *tf7;
/** 关键字 **/
@property (nonatomic,strong) UITextField *tf8;
/** 送审情况 **/
@property (nonatomic,strong) UITextField *tf9;
/** 默认标题 **/
@property (nonatomic,strong) UITextField *tf10;
/** 默认正文 **/
@property (nonatomic,strong) UITextField *tf11;
/** 文种 **/
@property (nonatomic,strong) UITextField *tf12;
/** 优先级 **/
@property (nonatomic,strong) UITextField *tf13;
/** 发稿地址 **/
@property (nonatomic,strong) UITextField  *tf14;
/** 作者 **/
@property (nonatomic,strong) UITextField  *tf15;
/** 稿件类型 **/
@property (nonatomic,strong) UITextField  *tf16;
/** 语种数据 **/
@property (nonatomic,copy) NSMutableArray *languageArray;
/** 供稿类别数据 **/
@property (nonatomic,copy) NSMutableArray *provideTypeArray;
/** 优先级数据 **/
@property (nonatomic,copy) NSMutableArray *newsPriorityArray;
/** 公用动作表 **/
@property (nonatomic,strong) UIView *actionSheet;
/** 加载TemplateDetailController的类型 **/
@property (nonatomic,assign) NSInteger templateType;
/** 加载的稿签 **/
@property (nonatomic,strong) ManuscriptTemplate *manuscriptTemplate;
/** 判断键盘是否弹出 **/
@property (nonatomic,assign) BOOL keyboardShown;
/** 上级页面键盘是否弹出，会影响该页面滚动情况 **/
@property (nonatomic,assign) BOOL superViewKeyboardShow;
/** 键盘弹出时所编辑的文本框 **/
@property (nonatomic,strong) UITextField *activeField;
/** 另存 **/
@property (nonatomic,strong) UIButton *saveAsbtn;
/** 套用 **/
@property (nonatomic,strong) UIButton *applybtn;
/** 用于存储当前键盘高度 **/
@property (nonatomic,assign) int keyboardHeight;
/** 用于设置行号 **/
@property (nonatomic,assign) int rowNum;
@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) SEL action;
@property (nonatomic,strong) User *userInfo;
/** 中间稿签，用于检查稿签是否进行了修改 **/
@property (nonatomic,strong) ManuscriptTemplate *midManuscriptTemplate;

@property (nonatomic,copy) NSString *isSystemTemplate;

- (void)setComeFromAddress:(NSString *)comeFromAddressInf getComeFromAddressID:(NSString *)addressID;

- (void)setNewsCategory:(NSString *)newsCategoryInf getNewsCategoryID:(NSString *)categoryID;

- (void)setRegion:(NSString *)regionInf getRegionID:(NSString *)regionID;

- (void)setSendArea:(NSString *)placeInf;

- (void)setHappenPlace:(NSString *)placeInf;

- (void)setReportPlace:(NSString *)placeInf;

- (void)setKeywords:(NSString *)keywordsInf;

- (void)setSendToAddress:(NSString *)sendToAddressInf getSendToAddressID:(NSString *)addressId ;


- (void)returnManuscriptTemplate:(ManuscriptTemplate *)returnManuscriptTemplate;









@end
