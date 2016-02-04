//
//  NewArticlesController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

typedef NS_ENUM(NSInteger,FileNameTags) {
    FileNameTagsPhoto,
    FileNameTagsAudio,
    FileNameTagsVideo
};

@interface NewArticlesController : RootViewController

@property (nonatomic,copy) NSString *manuscript_id;

@end
