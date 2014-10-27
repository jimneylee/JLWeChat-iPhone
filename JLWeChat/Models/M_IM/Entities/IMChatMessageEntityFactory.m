//
//  IMChatMessageEntity.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMChatMessageEntityFactory.h"
#import "JLKeywordRegularParser.h"
#import "IMEmotionManager.h"

#pragma mark IMChatMessageBaseEntity

@implementation IMChatMessageBaseEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = IMChatMessageType_Unknown;
        self.isOutgoing = NO;
    }
    return self;
}

@end

#pragma mark IMChatMessageTextEntity

@implementation IMChatMessageTextEntity

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        self.text = text;
    }
    return self;
}

+ (NSString *)JSONStringFromText:(NSString *)text
{
    NSDictionary *jsonDic = @{@"type" : @"text",
                              @"data" : text};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions
                                                         error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"json->object error : %@", error);
        return nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// 识别出 表情 at某人 share软件(TODO:) 标签
- (void)parseAllKeywords
{
    if (IMChatMessageType_Text == self.type && self.text.length > 0) {
        if (!self.emotionRanges) {
            
            NSString *trimedString = self.text;
            self.emotionRanges = [JLKeywordRegularParser keywordRangesOfEmotionInString:self.text
                                                                           trimedString:&trimedString];
            self.text = trimedString;
            NSMutableArray* emotionImageNames = [NSMutableArray arrayWithCapacity:self.emotionRanges.count];
            
            for (JLPaserdKeyword *keyworkEntity in self.emotionRanges) {
                NSString* keyword = keyworkEntity.keyword;
                
                for (IMEmotionEntity *emotionEntity in [IMEmotionManager sharedManager].emotionsArray) {
                    if ([keyword isEqualToString:emotionEntity.name]) {
                        [emotionImageNames addObject:emotionEntity.imageName];
                        break;
                    }
                }
            }
            self.emotionImageNames = emotionImageNames;
        }
        
        // if body's keywords are all emotion and get empty string, just set a space
        // for nil return in NIAttributedLabel: - (CGSize)sizeThatFits:(CGSize)size
        if (!self.text.length) {
            self.text = @" ";
            if (!TTOSVersionIsAtLeast7()) {
                for (JLPaserdKeyword *keyword in self.emotionRanges) {
                    keyword.range = NSMakeRange(keyword.range.location + 1, keyword.range.length);
                }
            }
        }
    }
}

@end

#pragma mark IMChatMessageImageEntity

@implementation IMChatMessageImageEntity

+ (id)entityWithArray:(NSArray *)array
{
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        // TODO:暂时只考虑一张
        NSDictionary *dic = array[0];
        return [[self class] entityWithDictionary:dic];
    }
    return nil;
}

+ (id)entityWithDictionary:(NSDictionary *)dic
{
    if (dic) {
        IMChatMessageImageEntity *entity = [[IMChatMessageImageEntity alloc] init];
        entity.width = [dic[@"width"] floatValue];
        entity.height = [dic[@"height"] floatValue];
        entity.size = [dic[@"size"] floatValue];
        entity.url = dic[@"url"];
        return entity;
    }
    return nil;
}

+ (NSString *)JSONStringWithImageWidth:(CGFloat)width height:(CGFloat)height url:(NSString *)url
{
    // 暂时还是多图json格式，后面便于扩展
    NSDictionary *jsonDic = @{@"type"   : @"image",
                              @"data"   : @[@{
                                            @"width"  : [NSNumber numberWithFloat:width],
                                            @"height" : [NSNumber numberWithFloat:height],
                                            @"url"    :  url
                                            }]
                              };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions
                                                         error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"json->object error : %@", error);
        return nil;
    }
}

@end

#pragma mark IMChatMessageVoiceEntity

@implementation IMChatMessageVoiceEntity

+ (id)entityWithDictionary:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        IMChatMessageVoiceEntity *entity = [[IMChatMessageVoiceEntity alloc] init];
        entity.time = [dic[@"time"] integerValue];
        entity.url = dic[@"url"];
        return entity;
    }
    return nil;
}

+ (NSString *)JSONStringWithVoiceTime:(NSInteger)time url:(NSString *)url
{
    // 暂时还是多图json格式，后面便于扩展
    NSDictionary *jsonDic = @{@"type"   : @"voice",
                              @"data"   : @{
                                            @"time"  : [NSNumber numberWithInteger:time],
                                            @"url"    :  url
                                            }
                              };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions
                                                         error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"json->object error : %@", error);
        return nil;
    }
}


@end

#pragma mark IMChatMessageNewsEntity

@implementation IMChatMessageNewsEntity

@end

#pragma mark IMChatMessageEntityFactory

@implementation IMChatMessageEntityFactory

+ (id)objectFromJSONString:(NSString *)JSONString
{
    if (JSONString) {
        NSError *error = nil;
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                   options:kNilOptions
                                                                     error:&error];
        if (error) {
            NSLog(@"message body json error : %@", error);
            
            JSONObject = @{@"type" : @"text",
                           @"data" : @"NOT a json string"};
        }
        return JSONObject;
    }
    return nil;
}

+ (IMChatMessageBaseEntity *)messageFromJSONString:(NSString *)JSONString
{
    id JSONObject = [IMChatMessageEntityFactory objectFromJSONString:JSONString];
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        id message = [IMChatMessageEntityFactory entityWithDictionary:JSONObject];
        return message;
    }
    
    return nil;
}

+ (id)entityWithDictionary:(NSDictionary *)dic
{
    if (dic) {
        NSString *typeStr = dic[@"type"];
        IMChatMessageBaseEntity *messageEntity = nil;
        IMChatMessageType type = [IMChatMessageEntityFactory typeFromString:typeStr];
        
        switch (type) {
            case IMChatMessageType_Text:
            {
                messageEntity = [[IMChatMessageTextEntity alloc] initWithText:dic[@"data"]];
                break;
            }
                
            case IMChatMessageType_Image:
            {
                messageEntity = [IMChatMessageImageEntity entityWithArray:dic[@"data"]];
                break;
            }
                
            case IMChatMessageType_Voice:
            {
                messageEntity = [IMChatMessageVoiceEntity entityWithDictionary:dic[@"data"]];
                break;
            }
                
            case IMChatMessageType_News:
                break;

            default:
                break;
        }
        messageEntity.type = type;
        return messageEntity;
    }
    return nil;
}

+ (IMChatMessageType)typeWithDictionary:(NSDictionary *)dic
{
    NSString *typeStr = dic[@"type"];
    return [IMChatMessageEntityFactory typeFromString:typeStr];
}

+ (IMChatMessageType)typeFromString:(NSString *)typeStr
{
    IMChatMessageType type = IMChatMessageType_Unknown;
    if (typeStr.length > 0) {
        if ([typeStr isEqualToString:@"text"]) {
            type = IMChatMessageType_Text;
        }
        else if ([typeStr isEqualToString:@"image"]) {
            type = IMChatMessageType_Image;
        }
        else if ([typeStr isEqualToString:@"voice"]) {
            type = IMChatMessageType_Voice;
        }
        else if ([typeStr isEqualToString:@"news"]) {
            type = IMChatMessageType_News;
        }
    }
    return type;
}

+ (NSString *)recentContactLastMessageFromJSONString:(NSString *)JSONString
{
    id object = [IMChatMessageEntityFactory messageFromJSONString:JSONString];
    NSString *lastMessage = @"";
    
    if ([object isKindOfClass:[IMChatMessageTextEntity class]]) {
        lastMessage = ((IMChatMessageTextEntity *)object).text;
    }
    else if ([object isKindOfClass:[IMChatMessageImageEntity class]]) {
        lastMessage = @"[图片]";
    }
    else if ([object isKindOfClass:[IMChatMessageVoiceEntity class]]) {
        lastMessage = @"[语音]";
    }
    else if ([object isKindOfClass:[IMChatMessageNewsEntity class]]) {
        lastMessage = ((IMChatMessageNewsEntity *)object).title;
    }
    
    return lastMessage;
}

@end
