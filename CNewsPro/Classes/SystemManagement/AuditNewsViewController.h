//
//  AuditNewsViewController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@interface AuditNewsViewController : RootViewController

@property (nonatomic, copy) NSMutableArray *scriptItems;
@property (nonatomic, strong) UITableView *scriptTableView;
@property (nonatomic, assign) NSInteger    pageNum;
@property (nonatomic, strong) UIActivityIndicatorView *actIndView;
@property (nonatomic, strong) UIView *  viewAboveTableView;

@property (nonatomic,strong)  UIImageView*	checkImageView;
@property (nonatomic,strong)  UILabel *totalNumber;
@property (nonatomic,assign) NSInteger totalNum;

@property (nonatomic, strong) UIView*   viewBelowTableView;
@property (nonatomic,strong)  UIButton *nextBtn;
@property (nonatomic,strong)  UIButton *lastBtn;
@property (nonatomic,strong)  UILabel  *pageStatusLabel;

@property (nonatomic,strong) UILabel *noDataLabel;

@end
