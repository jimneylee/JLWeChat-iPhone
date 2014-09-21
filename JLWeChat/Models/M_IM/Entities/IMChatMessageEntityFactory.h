//
//  MKChatMessageEntity.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"

typedef NS_ENUM(NSUInteger, MKChatMessageType)
{
    MKChatMessageType_Text,
    MKChatMessageType_Image,
    MKChatMessageType_Voice,
    MKChatMessageType_News,
    MKChatMessageType_Unknown
};

@interface IMChatMessageBaseEntity : NSObject

@property (nonatomic, assign) MKChatMessageType type;
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

@interface IMChatMessageVoiceEntity : IMChatMessageBaseEntity

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, copy)   NSString *url;

@end

@interface IMChatMessageNewsEntity : IMChatMessageBaseEntity

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *intro;

@end


@interface IMChatMessageEntityFactory : NSObject

+ (IMChatMessageBaseEntity *)messageFromJSONString:(NSString *)JSONString;
+ (NSString *)recentContactLastMessageFromJSONString:(NSString *)JSONString;

@end
