//
//  NewsCategory.h
//  CNewsPro
//
//  Created by hooper on 1/26/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCategory : NSObject

@property (nonatomic,assign) NSInteger nc_id;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *language;

@end
