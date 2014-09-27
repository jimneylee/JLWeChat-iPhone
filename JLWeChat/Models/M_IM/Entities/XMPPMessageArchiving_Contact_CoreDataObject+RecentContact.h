//
//  XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.h
//  JLWeChat
//
//  Created by Lee jimney on 5/31/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import "XMPPMessageArchiving_Contact_CoreDataObject.h"

@interface XMPPMessageArchiving_Contact_CoreDataObject (RecentContact)

@property (nonatomic, copy)   NSString *displayName;
@property (nonatomic, copy)   NSString *chatRecord;
@property (nonatomic, strong) NSNumber *unreadMessages;
@property (nonatomic, assign) BOOL isChating;

@end
