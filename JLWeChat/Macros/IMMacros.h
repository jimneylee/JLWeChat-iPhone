//
//  IMMacros.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#ifndef JLWeChat_IMMacros_h
#define JLWeChat_IMMacros_h

// 是否为本地地址测试
#define LOCAL_TEST 0

#if LOCAL_TEST
#define XMPP_DOMAIN         @"127.0.0.1"
#define XMPP_HOST_NAME      @"127.0.0.1"
#else
#define XMPP_DOMAIN         @"121.41.129.248"
#define XMPP_HOST_NAME      @"121.41.129.248"
#endif//LOCAL_TEST

// Qiniu
#define QN_AK @"903l5JQnmIRgHD_Rhwdwnrtr0qKRj1C3GPcwj_jh"
#define QN_SK @"kuZCw35r20ErLP8y5jaD9nxAAhIlnGASYdtRkdYH"
#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://jlwechat.qiniudn.com/%@", key]
#define QN_BUCKET_NAME @"jlwechat"

#define XMPP_RESOURCE       @"iPhoneXMPP"
#define XMPP_DEFAULT_GROUP_NAME @"friends"

#define XMPP_USER_ID        @"XMPP_USER_ID"
#define XMPP_PASSWORD       @"XMPP_PASSWORD"

#define STROE_USER_NAME     @"STROE_USER_NAME"
#define STROE_PASSWORD      @"STROE_PASSWORD"
#define STROE_NICKNAME      @"STROE_NICKNAME"
#define ISLOGINED           @"ISLOGINED"

#define DEFAULT_MESSAGE_MAX_COUNT 100
#define DEFAULT_ROSTER_MAX_COUNT 100

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
                ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) \
                : NO)

#define IM_MOC [IMDataBaseManager sharedManager].managedObjectContext
#define MY_JID [IMManager sharedManager].myJID

#endif
