//
//  UploadMaker.h
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Manuscripts,Accessories;
@interface UploadMaker : NSObject

+ (void)uploadWithFilePath:(Manuscripts*)manuscripts accessories:(Accessories *)accessories;

@end
