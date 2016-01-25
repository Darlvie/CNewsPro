//
//  NetworkMacro.h
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#ifndef NetworkMacro_h
#define NetworkMacro_h

#define MAX_CLIENT_COUNT 2   //允许的最大上传进程数

#define MITI_IP @"http://182.92.101.55:8080/cm/"  //天津正式服务器

#define GET_BASE_DATA_IP @"http://10.255.20.60:8080/enews/basedata/"////正式服务器－－－取文件的

#define CLIENT_ID 201

#define REQUEST_STATUS           @"requestStatus"
#define REQUEST_SUCCESS          @"requestSuccess"
#define LAST_FAIL                @"LastFail"//最后一次失败
#define LAST_SUCESS              @"LastSucess"//最后一次成功
#define REQUEST_FAIL             @"requestFail"
#define RESPONSE_DATA            @"responseData"
#define RESPONSE_ERROR           @"responseError"


#define TIMEOUT_INTERVAL        30.0f
#define TIMEOUT_INTERVAL2       10.0f
#define REQUEST_URL              @"url"
#define REQUEST_METHOD           @"requestMethod"
#define POST                    @"POST"
#define POST_BODY               @"postBody"
#define FILE_DATA                @"fileData"
#define XML_DATA                 @"xmlData"
#define FILE_PATH                @"filePath"
#define XML_PATH                 @"xmlPath"
#define MAIN_SCRIPT_GUID          @"MainScriptGuid"
#define RE_NEWS_ID                @"ReNewsId"//回传的稿件id
#define MANUSCRIPT_INFO          @"ManuscriptInfo"
#define ATTACHMENT_PATH          @"AttachmentPath"
#define CLIENT_TAG               @"clienttag"

//上传原始文件名
#define UPLOAD_FILE_NAME          @"uploadFileName"

//上传文件类型
#define UPLOAD_FILE_TYPE          @"uploadFileType"
#define XML_FILE                 @"xmlFile"
#define MEDIA_FILE               @"mediaFile"
#define LOG_FILE                 @"logFile"

//请求类型
#define REQUEST_TYPE             @"requestTYPE"
#define TEMPLATE                @"Template"
#define LOGIN                   @"login"
#define LOGOUT                  @"logout"
#define GET_URL                  @"geturl"

#endif /* NetworkMacro_h */
