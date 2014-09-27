//
//  XMPPMessageArchiving_Message_CoreDataObject+ChatMessage.h
//  JLWeChat
//
//  Created by Lee jimney on 5/24/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "IMChatMessageEntityFactory.h"

@interface XMPPMessageArchiving_Message_CoreDataObject (ChatMessage)

// chatMessage 可能为MKChatMessageTextEntity MKChatMessageImageEntity ..
@property (nonatomic, strong) IMChatMessageBaseEntity *chatMessage;

- (NSString *)sectionIdentifier;

@end
