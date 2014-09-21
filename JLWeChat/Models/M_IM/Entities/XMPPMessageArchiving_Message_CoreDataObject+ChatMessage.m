//
//  XMPPMessageArchiving_Message_CoreDataObject+ChatMessage.m
//  JLIM4iPhone
//
//  Created by Lee jimney on 5/24/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import "XMPPMessageArchiving_Message_CoreDataObject+ChatMessage.h"
#import <objc/runtime.h>

static const char kChatMessageKey;
static const char kPrimitiveSectionIdentifier;

@interface XMPPMessageArchiving_Message_CoreDataObject ()

@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation XMPPMessageArchiving_Message_CoreDataObject (ChatMessage)


#pragma mark AssociatedObject

-(IMChatMessageBaseEntity *)chatMessage
{
    IMChatMessageBaseEntity *chatMessage = objc_getAssociatedObject(self, &kChatMessageKey);
    if (!chatMessage) {
        chatMessage = [IMChatMessageEntityFactory messageFromJSONString:self.body];
        chatMessage.isOutgoing = self.isOutgoing;
        if (chatMessage) {
            objc_setAssociatedObject(self, &kChatMessageKey, chatMessage, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return chatMessage;
}

-(void)setChatMessage:(IMChatMessageBaseEntity *)chatMessage
{
    objc_setAssociatedObject(self, &kChatMessageKey, chatMessage, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)primitiveSectionIdentifier
{
    return objc_getAssociatedObject(self, &kPrimitiveSectionIdentifier);
}

-(void)setPrimitiveSectionIdentifier:(NSString *)primitiveSectionIdentifier
{
    objc_setAssociatedObject(self, &kPrimitiveSectionIdentifier, primitiveSectionIdentifier, OBJC_ASSOCIATION_RETAIN);
}

// idea from apple sample code : DateSectionTitles
- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        tmp = [formatter stringFromDate:self.timestamp];
        
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"timestamp"];
}

@end
