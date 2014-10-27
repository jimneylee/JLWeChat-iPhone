//
//  IMEmotionManager.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMEmotionManager.h"

#define EMOTION_PLIST @"emotion_icons.plist"

@interface IMEmotionManager()

@property (nonatomic, strong) NSArray* emotionsArray;

@end

@implementation IMEmotionManager

+ (instancetype)sharedManager
{
    static IMEmotionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
    });
    
    return _sharedManager;
}

- (NSArray *)emotionsArray
{
    if (!_emotionsArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:EMOTION_PLIST ofType:nil];
        NSArray* array = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray* entities = [NSMutableArray arrayWithCapacity:array.count];
        IMEmotionEntity* entity = nil;
        NSDictionary* dic = nil;
        for (int i = 0; i < array.count; i++) {
            dic = array[i];
            entity = [IMEmotionEntity entityWithDictionary:dic atIndex:i];
            [entities addObject:entity];
        }
        _emotionsArray = entities;
    }
    return _emotionsArray;
}

- (NSString*)imageNameForEmotionCode:(NSString*)code
{
    for (IMEmotionEntity* e in self.emotionsArray) {
        if ([e.code isEqualToString:code]) {
            return e.imageName;
        }
    }
    return nil;
}

- (NSString*)imageNameForEmotionName:(NSString*)name
{
    for (IMEmotionEntity* e in self.emotionsArray) {
        if ([e.name isEqualToString:name]) {
            return e.imageName;
        }
    }
    return nil;
}

- (BOOL)checkValidEmotion:(NSString *)emotionName
{
    if ([self imageNameForEmotionName:emotionName]) {
        return YES;
    }
    return NO;
}

- (BOOL)deleteEmotionInTextView:(UITextView *)textView atRange:(NSRange)range
{
    NSString *deleteString =[textView.text substringWithRange:range];
    
    if ([deleteString isEqualToString:@"]"]) {
        
        NSRange leftRange = [textView.text rangeOfString:@"[" options:NSBackwardsSearch];
        if (leftRange.length > 0) {
            
            NSRange emotionRange = NSMakeRange(leftRange.location, range.location - leftRange.location + 1);
            NSString *emotionName = [textView.text substringWithRange:emotionRange];
            
            if ([[IMEmotionManager sharedManager] checkValidEmotion:emotionName]) {
                
                NSMutableString *textString = [NSMutableString stringWithString:textView.text];
                [textString deleteCharactersInRange:emotionRange];
                textView.text = textString;
                textView.selectedRange = NSMakeRange(emotionRange.location, 0);
                
                return YES;
            }
        }
    }
    return NO;
}

@end
