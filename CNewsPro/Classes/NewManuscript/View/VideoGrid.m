//
//  VideoGrid.m
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "VideoGrid.h"

@implementation VideoGrid

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //图片按钮
        _btnPic = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnPic.frame = self.bounds;
        [self addSubview:_btnPic];
        
        //删除按钮
        _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnDelete setImage:[UIImage imageNamed:@"manuscript_delete"] forState:UIControlStateNormal];
        _btnDelete.frame = CGRectMake(-3, -3, 25, 25);
        [self addSubview:_btnDelete];
    }
    return self;
}


@end
