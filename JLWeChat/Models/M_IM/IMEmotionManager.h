//
//  MKEmotionManager.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMEmotionEntity.h"

@interface IMEmotionManager : NSObject

+ (instancetype)sharedManager;

- (NSArray *)emotionsArray;
- (NSString *)imageNameForEmotionCode:(NSString*)code;
- (NSString *)imageNameForEmotionName:(NSString*)name;
- (BOOL)checkValidEmotion:(NSString *)emotionName;
- (BOOL)deleteEmotionInTextView:(UITextView *)textView atRange:(NSRange)range;

@end
