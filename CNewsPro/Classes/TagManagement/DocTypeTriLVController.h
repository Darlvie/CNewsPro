//
//  DocTypeTriLVController.h
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@class NewsCategory;
@interface DocTypeTriLVController : RootViewController

@property (nonatomic,strong) NSMutableArray *docTypeTriLVArray;
@property (nonatomic,strong) NewsCategory *newsCategorySecLV;
@property (nonatomic,copy) NSString *newsCategorySecLVInf;
@property (nonatomic,strong) UITableView *docTypeTriLVView;

@end
