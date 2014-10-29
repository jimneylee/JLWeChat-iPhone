//
//  IMUtil.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMUtil : NSObject

// yyyy-MM-dd-HH-mm-ss.jpg
+ (NSString *)generateImageTimeKey;

// yyyy-MM-dd-HH-mm-ss.voice
+ (NSString *)generateVoiceTimeKey;

//upload file with urlkey
+ (void)uploadFileWithUrlkey:(NSString *)urlkey
               completeBlock:(void (^)(BOOL success,  NSString *key))completeBlock;

// download file with url
+ (void)downloadFileWithUrl:(NSString*)url
              progressBlock:(void (^)(CGFloat progress))progressBlock
              completeBlock:(void (^)(BOOL success, NSError *error))completeBlock;

@end
