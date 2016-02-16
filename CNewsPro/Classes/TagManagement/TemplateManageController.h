//
//  TemplateManageController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

typedef NS_ENUM(NSInteger,ViewTemplate) {
    ViewTemplateEdit,
    ViewTemplateSelect
};

@class ManuscriptTemplate;
@interface TemplateManageController : RootViewController

@property (nonatomic,strong) NSMutableArray *sysTagArray;
@property (nonatomic,strong) NSMutableArray *customTagArray;
@property (nonatomic,strong) ManuscriptTemplate *defaultManuscriptTemplate;
@property (nonatomic,assign) NSInteger viewTemplate;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) SEL action;

- (void)reloadtable;

@end
