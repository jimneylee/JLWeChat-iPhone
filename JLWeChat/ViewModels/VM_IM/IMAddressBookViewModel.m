//
//  MKAddressBookViewModel.m
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMAddressBookViewModel.h"
#import "IMContactModel.h"
#import "IMManager.h"
#import <UIAlertView+RACSignalSupport.h>
#import "XMPPPresence+XEP_0172.h"
#import "IMMessageViewModel.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface IMAddressBookViewModel()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) RACSubject *updatedContentSignal;
@property (nonatomic, strong) IMContactModel *contactModel;

@end

@implementation IMAddressBookViewModel

+ (instancetype)sharedViewModel
{
    static IMAddressBookViewModel *_sharedViewModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedViewModel = [[self alloc ] init];
    });
    
    return _sharedViewModel;
}

- (void)dealloc
{
    [[IMManager sharedManager].xmppRoster removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[IMManager sharedManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[IMManager sharedManager] managedObjectContext_roster];

        [[IMManager sharedManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [[IMManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

        self.updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"%@ updatedContentSignal",
                                     NSStringFromClass([IMAddressBookViewModel class])];
        
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchAddressBook];
        }];
        
        // TODO:当完成正式的登录功能，此处需要同步考虑
        RAC(self, active) = [RACObserve([IMManager sharedManager], myJID) map:^id(id value) {
            if (value) {
                return @(YES);
            }
            return @(NO);
        }];
        
//        self.searchUserViewModel = [[MKVMSearchUser alloc] init];
//        
//        [RACObserve(self.searchUserViewModel, resultStr) subscribeNext:^(NSString *x) {
//            
//            if (x.integerValue > 0) {
//                MKDSearchEnity *user = self.searchUserViewModel.resultArray[0];
//                
//                // 更新sql中nickname
//                NSString *bareJidStr = [NSString stringWithFormat:@"%@@%@",
//                                        user.uname, [IMManager sharedManager].myJID.domain];
//                [MKNewFriendsViewModel updateNewFriendWithBareJidStr:bareJidStr nickname:user.nickname];
//            }
//        }];
//        
//        self.rosterAddtionlViewModel = [[MKRosterAddtionalViewModel alloc] init];
    }
    
    return self;
}

#pragma mark Private

- (void)fetchAddressBook
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch: %@", error);
    }
    else {
        NSArray *dataArray = [self.fetchedResultsController fetchedObjects];
        //if (dataArray.count > 0)
        {
            [self pickBothFriendFromRosterArray:dataArray];
        }
        
        [(RACSubject *)self.updatedContentSignal sendNext:nil];
    }
}

- (void)pickBothFriendFromRosterArray:(NSArray *)dataArray
{
    // 将等待验证的好友提取出来
    NSMutableArray *newDataArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    for (XMPPUserCoreDataStorageObject *user in dataArray) {
        if ([user.subscription isEqualToString:@"both"]) {
            [newDataArray addObject:user];
        }
    }
    
    // 已互相加为好友
    [self updateContactModelWithDataArray:newDataArray];
    
    // 添加新朋友、商家
    if (self.contactModel.sections.count > 0) {
        [self.contactModel.sections insertObject:@"#" atIndex:0];
        [self.contactModel.items insertObject:@[@"新的朋友"] atIndex:0];
        
    }
    else {
        [self.contactModel.sections addObject:@"#"];
        [self.contactModel.items addObject:@[@"新的朋友"]];
    }
}

- (void)updateContactModelWithDataArray:(NSArray *)dataArray
{
    if (dataArray.count > 0) {
        if (!self.contactModel) {
            self.contactModel = [[IMContactModel alloc] initWithDataArray:dataArray];
        }
        else {
            [self.contactModel updateDataArray:dataArray];
        }        
    }
    else {
        self.contactModel = [[IMContactModel alloc] init];
        self.contactModel.sections = [NSMutableArray array];
        self.contactModel.items = [NSMutableArray array];
    }
}

- (void)searchContactsWithKeyword:(NSString *)keyword
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSArray *sectionItems in self.contactModel.items) {
        for (IMContactEntity *entity in sectionItems) {
            if ([entity.sortString rangeOfString:keyword options:NSCaseInsensitiveSearch].length > 0
                || [entity.name rangeOfString:keyword options:NSCaseInsensitiveSearch].length > 0) {
                [resultArray addObject:entity.coreDataUser];
            }
        }
    }
    self.searchResultArray = resultArray;
}

// 网络获取nickname
- (void)searchUserInfoForBareJidStr:(NSString *)bareJidStr
{
    XMPPJID *jid = [XMPPJID jidWithString:bareJidStr];
//    self.searchUserViewModel.searchword = jid.user;
//    [self.searchUserViewModel.subscribeCommand execute:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (!_fetchedResultsController) {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:self.model];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.model
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
		[_fetchedResultsController setDelegate:self];
	}
	
	return _fetchedResultsController;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *dataArray = [controller fetchedObjects];
    [self pickBothFriendFromRosterArray:dataArray];
    [(RACSubject *)self.updatedContentSignal sendNext:nil];
}

#pragma mark - DataSource

- (NSArray *)sectionIndexTitles
{
    return [self.contactModel sections];
}

-(NSInteger)numberOfSections
{
    return [[self.contactModel sections] count];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if ([[self.contactModel sections] count] > section) {
        return [[self.contactModel sections] objectAtIndex:section];
    }
    return nil;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section
{
    if ([self.contactModel items].count > section) {
       NSArray *array = [[self.contactModel items] objectAtIndex:section];
        return array.count;
    }
    return 0;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.contactModel items].count > indexPath.section) {
        NSArray *array = [[self.contactModel items] objectAtIndex:indexPath.section];
        if (array.count > indexPath.row) {
            
            id object = array[indexPath.row];
            if ([object isKindOfClass:[IMContactEntity class]]) {
                IMContactEntity *contact = (IMContactEntity *)object;
                return contact.coreDataUser;
            }
            else if ([object isKindOfClass:[NSString class]]) {
                return object;
            }
        }
    }
    return nil;
}

- (BOOL)deleteUser:(XMPPUserCoreDataStorageObject *)user
{
    if (user) {
        NSManagedObjectContext *context = [IMManager sharedManager].managedObjectContext_roster;
        [context deleteObject:user];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)deleteAllRoster
{
    NSManagedObjectContext *context = [IMManager sharedManager].managedObjectContext_roster;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *objects = [context executeFetchRequest:fetchRequest error:NULL];
    if (objects.count > 0) {
        
        for (NSManagedObject *managedObject in objects) {
            [context deleteObject:managedObject];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }
        return YES;
    }
    
    return NO;
}

// no use
-(BOOL)deleteObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contactModel.items.count > indexPath.section) {
        NSMutableArray *aItems = (NSMutableArray *)self.contactModel.items[indexPath.section];
        if (aItems.count > indexPath.row) {
            [aItems removeObjectAtIndex:indexPath.row];
            return YES;
        }
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"%@: %@ \n%@", THIS_FILE, THIS_METHOD, iq);
    
#if 0
    // <query xmlns="jabber:iq:roster"></query>
    NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:roster"];
    if (query) {
        NSArray *items = [query elementsForName:@"item"];
        
        // 如果通讯录为空，清空本地通讯录，清空最近联系人
        if (items.count == 0) {
            [self deleteAllRoster];
            [self deleteAllRecentContact];
        }
    }
#endif
    
	return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	NSLog(@"%@: %@ \n%@", THIS_FILE, THIS_METHOD, presence);
    
    // 别人请求加为好友
    //<presence xmlns="jabber:client" from="ljj@121.41.129.248" to="lee@121.41.129.248" type="subscribe"></presence>
    if ([[presence type] isEqualToString:@"subscribe"]) {
//        XMPPUserCoreDataStorageObject *user = [[IMManager sharedManager].xmppRosterStorage
//                                               userForJID:[presence from]
//                                               xmppStream:[IMManager sharedManager].xmppStream
//                                               managedObjectContext:[[IMManager sharedManager] managedObjectContext_roster]];
//        if (!user)
        {
            NSString *body = [NSString stringWithFormat:@"%@要加你为好友", [[presence from] user]];
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"好友邀请"
                                                                    message:body
                                                                   delegate:self
                                                          cancelButtonTitle:@"拒绝"
                                                          otherButtonTitles:@"接受", nil];
                [alertView show];
                
                [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
                    if ([x intValue] == 0) {
                        [[[IMManager sharedManager] xmppRoster] rejectPresenceSubscriptionRequestFrom:[presence from]];
                    }
                    else {
                        [[[IMManager sharedManager] xmppRoster] acceptPresenceSubscriptionRequestFrom:[presence from]
                                                                                       andAddToRoster:YES];
                    }
                }];
            }
        }
    }
    
    // 对方取消加好友请求
    else if ([[presence type] isEqualToString:@"unsubscribe"]) {
        
    }
    
    // 对方接受加好友
    //<presence from="fff@192.168.0.84" to="yj26599@192.168.0.84" type="subscribed"></presence>
    
    else if ([[presence type] isEqualToString:@"subscribed"]) {
        
    }
    
    // 对方取消好友关系
    //<presence xmlns="jabber:client" from="aaa@192.168.0.84" to="yj26599@192.168.0.84" type="unsubscribed"></presence>

    else if ([[presence type] isEqualToString:@"unsubscribed"]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            // 删除最近联系人
            if ([[IMMessageViewModel sharedViewModel] deleteRecentContactWithJid:[XMPPJID jidWithString:[presence fromStr]]]) {
                NSLog(@"deleteRecentContact:%@", [XMPPJID jidWithString:[presence fromStr]]);
            }
            
            for (XMPPUserCoreDataStorageObject *user in self.fetchedResultsController.fetchedObjects) {
                if ([user.jid isEqualToJID:[presence from] options:XMPPJIDCompareBare]) {
                    if ([self deleteUser:user]) {
                        NSLog(@"deleteUser:%@", user.jid.bare);
                    }
                }
            }
        });
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    NSLog(@"%@: %@ \n %@", THIS_FILE, THIS_METHOD, item);
    
    // idea copy from - (void)handleRosterItem:(NSXMLElement *)item xmppStream:(XMPPStream *)stream;
    
    //  <item jid="yj63025@61.160.250.138" name="&#x738B;&#x5927;&#x867E;" ask="subscribe" subscription="none"></item>
    
    NSXMLElement *copyItem = [item copy];
    NSString *jidStr = [copyItem attributeStringValueForName:@"jid"];
    NSString *subscription = [copyItem attributeStringValueForName:@"subscription"];
    
    // <item jid="uuu@192.168.0.84" subscription="both"></item>
    if ([subscription isEqualToString:@"both"]) {
        
    }
    else if ([subscription isEqualToString:@"remove"]) {
        // 这边不需要处理，发送subscribe请求是无法删除的，留着只是为了跟saprk调试
        //[MKNewFriendsViewModel deleteNewFriendWithBareJidStr:jidStr];
#if 0
        dispatch_async(dispatch_get_main_queue(), ^{
            // 删除最近联系人，此处通过api del_roster接口
            if ([[IMMessageViewModel sharedViewModel] deleteRecentContactWithJid:[XMPPJID jidWithString:jidStr]]) {
                NSLog(@"deleteRecentContact:%@", [XMPPJID jidWithString:jidStr]);
            }
            
            XMPPUserCoreDataStorageObject *user = [[IMManager sharedManager].xmppRosterStorage
                                                   userForJID:[XMPPJID jidWithString:jidStr]
                                                   xmppStream:[IMManager sharedManager].xmppStream
                                                   managedObjectContext:MK_MOC];
            if ([self deleteUser:user]) {
                NSLog(@"deleteUser:%@", user.jid.bare);
            }
        });
#endif
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // 别人请求加为好友
    //  <item jid="yj63025@61.160.250.138" name="&#x738B;&#x5927;&#x867E;" ask="subscribe" subscription="none"></item>
    
	//<presence xmlns="jabber:client" id="XWyMu-52" to="aaa@192.168.0.84" type="subscribe" from="uuu@192.168.0.84"></presence>
	XMPPUserCoreDataStorageObject *user = [[IMManager sharedManager].xmppRosterStorage
                                           userForJID:[presence from]
                                           xmppStream:[IMManager sharedManager].xmppStream
                                           managedObjectContext:[[IMManager sharedManager] managedObjectContext_roster]];
    if (!user) {
        NSString *body = [NSString stringWithFormat:@"%@要加你为好友", [[presence from] user]];
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"好友邀请"
                                                                message:body
                                                               delegate:self
                                                      cancelButtonTitle:@"拒绝"
                                                      otherButtonTitles:@"接受", nil];
			[alertView show];
            
            [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
                if ([x intValue] == 0) {
                    [[[IMManager sharedManager] xmppRoster] rejectPresenceSubscriptionRequestFrom:[presence from]];
                }
                else {
                    [[[IMManager sharedManager] xmppRoster] acceptPresenceSubscriptionRequestFrom:[presence from]
                                                                                     andAddToRoster:YES];
                }
            }];
		}
    }
}

@end
