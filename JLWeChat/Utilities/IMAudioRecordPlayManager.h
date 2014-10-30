//
//  IMAudioRecordPlayManager.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-26.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface IMAudioRecordPlayManager : NSObject

+ (instancetype)sharedManager;

- (void)playWithUrl:(NSString *)url;

- (void)startRecord;
- (void)stopRecordWithBlock:(void (^)(NSString *urlKey, NSInteger time))block;

@end
