//
//  RequestMaker.m
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "RequestMaker.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+Security.h"
#import "ASIHTTPRequest.h"
#import "NetworkManager.h"
#import "JSONKit.h"
#include "Utility.h"

@implementation RequestMaker
//同步登录请求
+ (NSString *)syncLoginWithUerName:(NSString *)userName password:(NSString *)pwd {
    NSString *deviceCode = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"uServices!login.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"loginname=%@&loginpswd=%@&encryptMethod=%d&vType=%@&vData=%@",userName,[pwd MD5],1,@"device.imei",deviceCode];
    NSString *sessionId = [USERDEFAULTS objectForKey:SESSION_ID];
    if (sessionId && ![sessionId isEqualToString:@""]) {
        [bodyStr stringByAppendingFormat:@"&sss=%@",sessionId];
    }
    
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds = TIMEOUT_INTERVAL2;
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld",[bodyData length]]];
    [request appendPostData:bodyData];
    [request setRequestMethod:POST];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        return [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"登录失败");
        return nil;
    }
}

//异步登录请求
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate {
    NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"uServices!login.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"loginname=%@&loginpswd=%@&encryptMethod=%@&vType=%@&vData=%@",username,[password MD5],@"1",@"device.imei",[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] init];
    [requestInfo setObject:url forKey:REQUEST_URL];
    [requestInfo setObject:LOGIN forKey:REQUEST_TYPE];
    [requestInfo setObject:POST forKey:REQUEST_METHOD];
    [requestInfo setObject:bodyStr forKey:POST_BODY];
    
    [[NetworkManager sharedManager] requestDataWithDelegate:delegate info:requestInfo];
}

//保持存活
+ (BOOL)keepAlive {
    NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"uServices!keepAlive.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"ua=%@&sss=%@",@"sys.keepalive",[USERDEFAULTS objectForKey:@"session_id"]];
    
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds = TIMEOUT_INTERVAL2;
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld",[bodyData length]]];
    [request appendPostData:bodyData];
    [request setRequestMethod:POST];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        if ([[responseString componentsSeparatedByString:@"||"] count] > 1) {
            if ([[[responseString componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
                return TRUE;
            } else {
                return FALSE;
            }
        } else {
            return FALSE;
        }
    } else {
        NSLog(@"登录失败!");
        return FALSE;
    }
}


+ (NSString *)getServerVersion {
    NSString *url = [NSString stringWithFormat:@"%@%@?ua=%@&appname=%d",MITI_IP,@"appServices!appInfo.action",@"get.clientcontrol",CLIENT_ID];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        return responseStr;
    } else {
        NSLog(@"登陆失败！");
        return nil;
    }
}

+ (NSString *)syncGetUserInfo:(NSString *)sessionId loginName:(NSString *)loginName {
    NSString *bodyStr = [NSString stringWithFormat:@"sss=%@&loginname=%@",sessionId,loginName];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@",MITI_IP,@"uServices!getUserInfo.action",@"?",bodyStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSString *xmlStr = [[responseStr componentsSeparatedByString:@"||"] objectAtIndex:1];
        if ([[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"132"]) {
            return @"132";//session过期
        } else {
            return xmlStr;
        }
    } else {
        NSLog(@"登录失败");
        return nil;
    }
}

+ (BOOL)getUrlArry:(NSString *)defaultUrl {
    NSString *bodyStr=[NSString stringWithFormat:@"ua=%@",@"get.ipnodeaddress"];
    NSString *url=[NSString stringWithFormat:@"%@%@%@",defaultUrl,@"?",bodyStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds = TIMEOUT_INTERVAL2;
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSMutableDictionary *responseDic = [responseStr mutableObjectFromJSONString];
        NSDictionary *dic = [responseDic objectForKey:@"AppServerIp"];
        [Utility sharedSingleton].urlArray = [dic allValues];
        return TRUE;
    } else {
        NSLog(@"获取服务器信息不正常");
        //清空url对象里的值
        NSArray *urlArrayTemp = [[NSArray alloc] init];
        [Utility sharedSingleton].urlArray = urlArrayTemp;
        return FALSE;
    }
}

+ (void)getTemplate:(NSString *)loginName sessionid:(NSString *)sessionId delegate:(id)delegate {
    
}

+ (void)getSingleNewByID:(NSInteger)newsID delegate:(id)delegate {
    NSString *uurl = [NSString stringWithFormat:@"%@%@?NewsId=%ld",MITI_IP,@"auditService!getNewsById",newsID];
    
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc]init];
    [requestInfo setObject:uurl forKey:REQUEST_URL];
    
    [[NetworkManager sharedManager]requestDataWithDelegate:delegate info:requestInfo];

}

//获取审稿列表
+ (void)getAuditNewsByPageNum:(NSInteger)pageNum size:(NSInteger)pageSize delegate:(id)delegate {
    NSString *uurl = [NSString stringWithFormat:@"%@%@",MITI_IP,@"auditService!getNews"];

    NSString *bodyStr = [NSString stringWithFormat:@"currentPage=%ld&pageSize=%ld",pageNum,pageSize];

    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc]init];
    [requestInfo setObject:uurl forKey:REQUEST_URL];
    [requestInfo setObject:POST forKey:REQUEST_METHOD];
    [requestInfo setObject:bodyStr forKey:POST_BODY];
    
    [[NetworkManager sharedManager]requestDataWithDelegate:delegate info:requestInfo];

}






@end
