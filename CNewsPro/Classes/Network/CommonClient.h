//
//  CommonClient.h
//  CNewsPro
//
//  Created by zyq on 16/1/21.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface CommonClient : ASIHTTPRequest 

@property (nonatomic,assign) id callBack;

@property (nonatomic,strong) NSMutableDictionary *responseInfo;

-(id)initWithDelegate:(id)delegate info:(id)requestInfo;

@end
