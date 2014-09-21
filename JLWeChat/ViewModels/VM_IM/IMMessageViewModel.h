//
//  IMMessageViewModel.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "RVMViewModel.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.h"

@interface IMMessageViewModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@property (nonatomic, readonly) NSNumber *totalUnreadMessagesNum;

+ (instancetype)sharedViewModel;

- (void)decreaseTotalUnreadMessagesCountWithValue:(NSInteger)count;
- (BOOL)deleteRecentContactWithJid:(XMPPJID *)recentContactJId;
- (BOOL)resetUnreadMessagesCountForCurrentContact:(XMPPJID *)contactJid;

-(NSInteger)numberOfItemsInSection:(NSInteger)section;
-(XMPPMessageArchiving_Contact_CoreDataObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

-(void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;

@end
