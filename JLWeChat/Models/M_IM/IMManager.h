//
//  MKXMPPManager.h
//  IMModel
//
//  Created by jimneylee on 14-5-19.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <XMPPFramework/XMPPFramework.h>
#import "XMPPReconnect.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import <XMPPMessageArchiving.h>
#import <XMPPMessageArchivingCoreDataStorage.h>

@interface IMManager : NSObject

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (nonatomic, assign) BOOL customCertEvaluation;
@property (nonatomic, assign) BOOL isXmppConnected;
@property (nonatomic, assign) BOOL goToRegisterAfterConnected;

@property (nonatomic, strong) XMPPJID *myJID;

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
- (NSManagedObjectContext *)managedObjectContext_messageArchiving;

- (BOOL)connect;
- (void)connectThenLogin;
- (void)connectThenRegister;
- (BOOL)doLogin;
- (BOOL)doRegister;
- (void)disconnect;
- (void)sendChatMessage:(NSString *)plainMessage toJID:(XMPPJID *)jid;

- (void)goOnline;

@end
