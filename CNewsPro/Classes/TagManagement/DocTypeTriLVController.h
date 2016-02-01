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

@property (nonatomic,retain) NSMutableArray *docTypeTriLVArray;
@property (nonatomic,retain) NewsCategory *newsCategorySecLV;
@property (nonatomic,retain) NSString *newsCategorySecLVInf;
@property (nonatomic,retain) UITableView *docTypeTriLVView;

@end
