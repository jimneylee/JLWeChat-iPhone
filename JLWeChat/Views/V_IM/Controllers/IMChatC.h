//
//  MKChatC.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-20.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPPJID;
@class XMPPMessageArchiving_Contact_CoreDataObject;

@interface IMChatC : UIViewController

+ (XMPPJID *)currentBuddyJid;
+ (void)setCurrentBuddyJid:(XMPPJID *)jid;

- (instancetype)initWithBuddyJID:(XMPPJID *)buddyJID buddyName:(NSString *)buddyName;

@end
