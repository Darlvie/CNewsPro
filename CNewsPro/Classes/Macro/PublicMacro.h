//
//  PublicMacro.h
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#ifndef PublicMacro_h
#define PublicMacro_h

#define USERDEFAULTS [NSUserDefaults standardUserDefaults]

#define IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

#define BLOCK_SIZE  [[[NSUserDefaults standardUserDefaults] objectForKey:FILE_BLOCK] intValue]*1024

#define FILE_PATH_IN_PHONE [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_NAME]]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif /* PublicMacro_h */
