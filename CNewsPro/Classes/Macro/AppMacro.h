//
//  AppMacro.h
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#define  NAME_TAG             0//标题
#define  COMEFROM_DEPT_TAG     1//稿源
#define  PROV_TYPE_TAG         2//供稿类别
#define  DOC_TYPE_TAG          3//分类
#define  REGION_TAG           4//地区
#define  SEND_AREA_TAG        5//来稿地点
#define  HAPPEN_PLACE_TAG     6//事发地点
#define  REPORT_PLACE_TAG     7//报道地点
#define  KEYWORDS_TAG        8//关键字
#define  REVIEW_STATUS_TAG    9//送审情况
#define  DEFAULT_TITLE_TAG    10//默认标题
#define  DEFAULT_CONTENTS_TAG 11//默认正文
#define  LANGUAGE_TAG        12//语种
#define  PRIORITY_TAG        13//优先级
#define  SEND_ADDRESS_TAG     14//发稿地址
#define  AUTHOR_TAG          15//作者
#define  SCRIPT_TYPE_TAG      16//稿件类型

#define AN_ABSTRCT @"anAbstract"
#define AUDIT_NEWS_ID @"auditNewsId"
#define AUTHOR @"author"
#define CHANNEL @"channel"
#define CONTENT @"content"
#define CREATE_TIME @"createTime"
#define STATUS @"status"
#define TITLE @"title"
#define VIDEO_SRC @"videoSrc"

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

#define IMG_TYPE  @".jpg"
#define VOC_TYPE  @".aif"
#define MOV_TYPE  @".mov"

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


#define TEMPLATE_DETAIL_VIEW_SECTION_NUM 1//稿件属性section
#define TEMPLATE_DETAIL_VIEWROW_NUM 11//稿件属性row
#define SEND_ADDRESS_SECTION_NUM 1//发稿地址section
#define SEND_ADDRESS_ROW_NUM 4//发稿地址row
#define TF_CGRECT CGRectMake(100, 0, 180, 50)
#define TV_CGRECT CGRectMake(90, 7, 180, 43)
#define TF_FONT [UIFont fontWithName:@"Helvetica" size:16.0]
#define TL_FONT [UIFont fontWithName:@"Helvetica" size:16.0]

#define DATA_KEY          @"Data"
//此appid为您所申请,请勿随意修改
#define APP_ID @"56b31055"
#define ENGINE_URL @"http://dev.voicecloud.cn:1028/index.htm"

#define H_CONTROL_ORIGIN CGPointMake(self.view.frame.size.width/2.-140, self.view.frame.size.height/2.-120)

#define CURRENT_MANUSCRIPTID_SESSIONId @"CurrentManuscriptId_SessionId"
#define BUTTON_WIDTH 95.0f
#define BUTTON_HEIGHT 95.0f



#endif /* AppMacro_h */
