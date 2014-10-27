//
//  IMChatMessageEntity.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"

typedef NS_ENUM(NSUInteger, IMChatMessageType)
{
    IMChatMessageType_Text,
    IMChatMessageType_Image,
    IMChatMessageType_Voice,
    IMChatMessageType_News,
    IMChatMessageType_Unknown
};

@interface IMChatMessageBaseEntity : NSObject

@property (nonatomic, assign) IMChatMessageType type;
@property (nonatomic, assign) BOOL isOutgoing;

@end

@interface IMChatMessageTextEntity : IMChatMessageBaseEntity

@property (nonatomic, copy)   NSString  *text;
@property (nonatomic, strong) NSArray   *emotionRanges;
@property (nonatomic, strong) NSArray   *emotionImageNames;

- (instancetype)initWithText:(NSString *)text;
- (void)parseAllKeywords;

+ (NSString *)JSONStringFromText:(NSString *)text;

@end

@interface IMChatMessageImageEntity : IMChatMessageBaseEntity

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, copy)   NSString *url;

+ (NSString *)JSONStringWithImageWidth:(CGFloat)width height:(CGFloat)height url:(NSString *)url;

@end

@interface IMChatMessageAudioEntity : IMChatMessageBaseEntity

@property (nonatomic, assign) NSInteger time;
@property (nonatomic, copy)   NSString *url;

+ (id)entityWithDictionary:(NSDictionary *)dic;
+ (NSString *)JSONStringWithAudioTime:(NSInteger)time url:(NSString *)url;
// 在entity中下载，避免cell复用引起crash
- (void)playAudioWithProgressBlock:(void (^)(CGFloat progress))progressBlock;

@end

@interface IMChatMessageNewsEntity : IMChatMessageBaseEntity

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *intro;

@end


@interface IMChatMessageEntityFactory : NSObject

+ (IMChatMessageBaseEntity *)messageFromJSONString:(NSString *)JSONString;
+ (NSString *)recentContactLastMessageFromJSONString:(NSString *)JSONString;

@end
