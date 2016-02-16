//
//  DocTypeSecLVController.h
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@class NewsCategory;
@interface DocTypeSecLVController : RootViewController

@property (nonatomic,strong) NSMutableArray *docTypeSecLVArray;
@property (nonatomic,strong) NewsCategory *newsCategorySuper;
@property (nonatomic,copy) NSString *newsCategorySuperInf;
@property (nonatomic,strong) UITableView *docTypeSecLVView;

@end
