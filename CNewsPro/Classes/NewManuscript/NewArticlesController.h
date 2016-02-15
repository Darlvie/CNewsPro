//
//  NewArticlesController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface NewArticlesController : RootViewController

@property (nonatomic,copy) NSString *manuscript_id;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) id delegate;
@property (nonatomic,copy) NSString *operationType;

-(void)addVoice:(AVAudioRecorder *)recorder;
@end
