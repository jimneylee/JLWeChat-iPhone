//
//  QNAuthPolicy.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-20.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNAuthPolicy : NSObject

@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *callbackUrl;
@property (nonatomic, copy) NSString *callbackBodyType;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic, assign) long long expires;
@property (nonatomic, assign) long long escape;

+ (NSString *)defaultToken;
+ (NSString *)tokenWithScope:(NSString *)scope;
+ (NSString *)generateImageTimeKey;
- (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey;

@end
