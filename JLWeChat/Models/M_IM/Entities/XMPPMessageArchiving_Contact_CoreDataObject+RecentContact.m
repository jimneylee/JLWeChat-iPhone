//
//  XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.m
//  JLIM4iPhone
//
//  Created by Lee jimney on 5/31/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import "XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.h"
#import <objc/runtime.h>
#import "IMChatC.h"

static const char kDisplayNameKey;
static const char kChatRecordKey;
static const char kUnreadMessagesKey;

@implementation XMPPMessageArchiving_Contact_CoreDataObject (RecentContact)

- (NSString *)displayName
{
    return objc_getAssociatedObject(self, &kDisplayNameKey);
}

-(void)setDisplayName:(NSString *)displayName
{
    objc_setAssociatedObject(self, &kDisplayNameKey, displayName, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)chatRecord
{
    return objc_getAssociatedObject(self, &kChatRecordKey);
}

-(void)setChatRecord:(NSString *)chatRecord
{
    objc_setAssociatedObject(self, &kChatRecordKey, chatRecord, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)unreadMessages
{
    NSNumber *unreadNum =  objc_getAssociatedObject(self, &kUnreadMessagesKey);
    if (!unreadNum) {
        NSString *contactUnreadMessageskey = [NSString stringWithFormat:@"%@%@",
                                              self.bareJidStr, self.streamBareJidStr];
        unreadNum = [[NSUserDefaults standardUserDefaults] objectForKey:contactUnreadMessageskey];
    }
    return unreadNum;
}

-(void)setUnreadMessages:(NSNumber *)unreadMessages
{
    objc_setAssociatedObject(self, &kUnreadMessagesKey, unreadMessages, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark Hooks

- (void)willInsertObject
{
	// If you extend XMPPMessageArchiving_Contact_CoreDataObject,
	// you can override this method to use as a hook to set your own custom properties.
    
    NSLog(@"willInsertObject");
    
//    if (!self.isChating) {
//        
//    }
    
    // TODO:
    // 有新的消息来，user表中+1，保存
    if (![self.mostRecentMessageOutgoing boolValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            XMPPUserCoreDataStorageObject *rosterUser =
            [[IMManager sharedManager].xmppRosterStorage userForJID:self.bareJid
                                                           xmppStream:[IMManager sharedManager].xmppStream
                                                 managedObjectContext:[IMManager sharedManager].managedObjectContext_roster];
            
            // 不是当前聊天，则需要修改未读消息数
            if (![[IMChatC currentBuddyJid] isEqualToJID:rosterUser.jid options:XMPPJIDCompareBare]) {
                
                rosterUser.unreadMessages = @1;
#if 1
                NSError *error = nil;
                if (![[IMManager sharedManager].managedObjectContext_roster save:&error]) {
                    NSLog(@"willInsertObject save error: %@", [error description]);
                }
#else
                // auto call storage save
#endif
            }
        });
    }
}

- (void)didUpdateObject
{
	// If you extend XMPPMessageArchiving_Contact_CoreDataObject,
	// you can override this method to use as a hook to update your own custom properties.
    
    NSLog(@"didUpdateObject");
    
//    if (!self.isChating) {
//
//        NSLog(@"unreadMessages = %@", self.unreadMessages);
//    }
    
    // 有新的消息来，user表中+1，保存
    if (![self.mostRecentMessageOutgoing boolValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            XMPPUserCoreDataStorageObject *rosterUser =
            [[IMManager sharedManager].xmppRosterStorage userForJID:self.bareJid
                                                           xmppStream:[IMManager sharedManager].xmppStream
                                                 managedObjectContext:[IMManager sharedManager].managedObjectContext_roster];
            
            // 不是当前聊天，则需要修改未读消息数
            if (![[IMChatC currentBuddyJid] isEqualToJID:rosterUser.jid options:XMPPJIDCompareBare]) {

                rosterUser.unreadMessages = [NSNumber numberWithInt:rosterUser.unreadMessages.intValue + 1];
    #if 1
                NSError *error = nil;
                if (![[IMManager sharedManager].managedObjectContext_roster save:&error]) {
                    NSLog(@"didUpdateObject save error: %@", [error description]);
                }
    #else
                // auto call storage save
    #endif
            }
        });
    }
}

@end
