//
//  AppMacro.h
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

//NSDefault key
#define SESSION_ID @"session_id"
#define LOGIN_NAME @"loginname"
#define PASSWORD  @"password"
#define USER_INFO  @"userinfo"
#define SEND_SERVER_ADDRESS @"SendServerAddress"//发稿服务器地址
#define LOW_VERSION @"lowversion"
//稿件的newstype
#define TEXT_MANU_C @"文字稿"
#define AUDIO_MANU_C @"音频稿"
#define VIDEO_MANU_C @"视频稿"
#define PICTURE_MANU_C @"图片稿"

//稿件的newstypeID
#define TEXT_MANU_E @"T"
#define AUDIO_MANU_E @"A"
#define VIDEO_MANU_E @"V"
#define PICTURE_MANU_E @"P"

#define MANUSCRIPT_TEMPLATE_TYPE @"NORMAL"
#define TEXT_EXPRESS_TEMPLATE_TYPE @"TEXT"
#define PICTURE_EXPRESS_TEMPLATE_TYPE @"PICTURE"
#define AUDIO_EXPRESS_TEMPLATE_TYPE @"VOICE"
#define VIDEO_EXPRESS_TEMPLATE_TYPE @"VIDEO"

//系统设置页使用到选择器的相关Tag
#define FILE_BLOCK_TAG 001//传输文件大小
#define FILE_BLOCK  @"kFileBlock"
#define AUTO_SAVE_TIME_TAG 002//自动保存时间
#define AUTO_SEND_COUNT_TAG 003//重发次数
#define COMPRESS_TAG 004//视频压缩质量
#define RESOLUTION_TAG 005 //分辨率设置
#define CODE_BIT_TAG 006//码率设置
#define AUTO_SAVE_TIME @"kAutoSaveTime"
#define SAVE_PASSWORD @"kSavePassword"
#define RE_SEND_COUNT  @"KReSendCount"
#define COMPRESS @"KCompress"
#define RESOLUTION @"KResolution"
#define CODE_BIT @"KCodeBit"

#define TABLEVIEW_CELL_HEIGHT 45
#define NETWORK_TITLE_CGRECT CGRectMake(20, 5, 120, 35)
#define LOCAL_TITLE_CGRECT CGRectMake(20, 5, 140, 35)
#define NETWORK_DETAIL_CGRECT CGRectMake(145, 5, 155, 35)
#define LOCAL_DETAIL_CGRECT CGRectMake(180, 5, 120, 35)
#define DETAIL_LABEL_COLOR [UIColor colorWithRed:0.0f/255.0f green:81.0f/255.0f blue:101.0f/225.0f alpha:1.0f]
#define TF_FONT [UIFont fontWithName:@"Helvetica" size:16.0]

//稿件状态
#define MANUSCRIPT_STATUS_EDITING @"editing"         //在编
#define MANUSCRIPT_STATUS_STAND_TO @"standto"         //待发
#define MANUSCRIPT_STATUS_SENT @"sent"               //已发
#define MANUSCRIPT_STATUS_ELIMINATION @"elimination" //淘汰

#define MANUSCRIPT_TEMPLATE_TYPE @"NORMAL"
#define TEXT_EXPRESS_TEMPLATE_TYPE @"TEXT"
#define PICTURE_EXPRESS_TEMPLATE_TYPE @"PICTURE"
#define AUDIO_EXPRESS_TEMPLATE_TYPE @"VOICE"
#define VIDEO_EXPRESS_TEMPLATE_TYPE @"VIDEO"

#define DATA_KEY          @"Data"

#endif /* AppMacro_h */
