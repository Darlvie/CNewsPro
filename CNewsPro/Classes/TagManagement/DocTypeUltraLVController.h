//
//  DocTypeUltraLVController.h
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@class NewsCategory;
@interface DocTypeUltraLVController : RootViewController

@property (nonatomic,retain) NSMutableArray *docTypeUltraLVArray;
@property (nonatomic,retain) NewsCategory *newsCategoryTriLV;
@property (nonatomic,retain) NSString *newsCategoryTriLVInf;
@property (nonatomic,retain) UITableView *docTypeUltraLVView;

@end
