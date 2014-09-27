//
//  IMMessageViewModel.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMMainMessageViewModel.h"
#import "IMManager.h"
#import "IMMainMessageViewModel.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface IMMainMessageViewModel()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) RACSubject *updatedContentSignal;
@property (nonatomic, strong) NSManagedObjectContext *model;

@property (nonatomic, strong) NSFetchedResultsController *fetchedRecentResultsController;
@property (nonatomic, assign) NSNumber *totalUnreadMessagesNum;

@end

@implementation IMMainMessageViewModel

+ (instancetype)sharedViewModel
{
    static IMMainMessageViewModel *_sharedViewModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedViewModel = [[self alloc ] init];
    });
    
    return _sharedViewModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[IMManager sharedManager] managedObjectContext_messageArchiving];

        self.updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"%@ updatedContentSignal",
                                     NSStringFromClass([IMMainMessageViewModel class])];
        
        @weakify(self)
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchRecentContact];
        }];
        
        // TODO:当完成正式的登录功能，此处需要同步考虑
        RAC(self, active) = [RACObserve([IMManager sharedManager], myJID) map:^id(id value) {
            if (value) {
                return @(YES);
            }
            return @(NO);
        }];
    }
    
    return self;
}

#pragma mark Public

- (BOOL)resetUnreadMessagesCountForCurrentContact:(XMPPJID *)contactJid
{
    XMPPMessageArchiving_Contact_CoreDataObject *contact = nil;
    XMPPMessageArchiving_Contact_CoreDataObject *currentChatContact = nil;
    
    for (int i = 0; i < [self numberOfItemsInSection:0]; i++) {
        contact = [self objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([contactJid isEqualToJID:contact.bareJid options:XMPPJIDCompareBare]) {
            currentChatContact = contact;
            break;
        }
    }
    
    if (currentChatContact) {
        // 总数减去当前user的未读消息个数
        [self decreaseTotalUnreadMessagesCountWithValue:currentChatContact.unreadMessages.intValue];
        
        XMPPUserCoreDataStorageObject *rosterUser =
        [[IMManager sharedManager].xmppRosterStorage userForJID:currentChatContact.bareJid
                                                       xmppStream:[IMManager sharedManager].xmppStream
                                             managedObjectContext:[IMManager sharedManager].managedObjectContext_roster];
        rosterUser.unreadMessages = @0;
#if 1
        NSError *error = nil;
        if (![[IMManager sharedManager].managedObjectContext_roster save:&error]) {
            NSLog(@"resetCurrentContactUnreadMessagesCount save error: %@", [error description]);
        }
#else
        // auto call storage save
#endif
        
        currentChatContact.unreadMessages = rosterUser.unreadMessages;
        return YES;
    }
    return NO;
}

- (void)decreaseTotalUnreadMessagesCountWithValue:(NSInteger)count
{
    self.totalUnreadMessagesNum = [NSNumber numberWithInt:self.totalUnreadMessagesNum.intValue - count];
}

- (BOOL)deleteRecentContactWithJid:(XMPPJID *)recentContactJId
{
    XMPPMessageArchiving_Contact_CoreDataObject *recentContact =
    [[IMManager sharedManager].xmppMessageArchivingCoreDataStorage contactWithJid:recentContactJId
                                                                          streamJid:MY_JID
                                                               managedObjectContext:[IMManager sharedManager].managedObjectContext_messageArchiving];
    
    if (recentContact) {
        NSManagedObjectContext *context = [IMManager sharedManager].managedObjectContext_messageArchiving;
        [context deleteObject:recentContact];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        [self decreaseTotalUnreadMessagesCountWithValue:recentContact.unreadMessages.intValue];
        return YES;
    }
    return NO;
}

- (BOOL)deleteAllRecentContact
{
    NSManagedObjectContext *context = [IMManager sharedManager].managedObjectContext_messageArchiving;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject"
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
        
        self.totalUnreadMessagesNum = @0;
        
        return YES;
    }
    
    return NO;
}

#pragma mark Private

- (void)fetchRecentContact
{
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"streamBareJidStr = '%@'",
                                                                     [IMManager sharedManager].myJID.bare]];
    [self.fetchedRecentResultsController.fetchRequest setPredicate:filterPredicate];

    NSError *error = nil;
    if (![self.fetchedRecentResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch: %@", error);
    }
    else {
        [self updateUserDisplayName];
    }
}

- (void)updateUserDisplayName
{
    NSArray *array = [self.fetchedRecentResultsController fetchedObjects];
    NSInteger totalUnreadCount = 0;
    
    if (array.count > 0) {        
        XMPPUserCoreDataStorageObject *rosterUser = nil;
        for (XMPPMessageArchiving_Contact_CoreDataObject *contact in array) {
            
            // 优先考虑从default
            rosterUser =
            [[IMManager sharedManager].xmppRosterStorage userForJID:contact.bareJid
                                                           xmppStream:[IMManager sharedManager].xmppStream
                                                 managedObjectContext:[IMManager sharedManager].managedObjectContext_roster];
            
            contact.displayName = rosterUser.displayName;
            contact.unreadMessages = rosterUser.unreadMessages;
            
            totalUnreadCount = totalUnreadCount + contact.unreadMessages.intValue;
        }
        self.totalUnreadMessagesNum = [NSNumber numberWithInt:totalUnreadCount];
    }
    
    [(RACSubject *)self.updatedContentSignal sendNext:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedRecentResultsController
{
	if (!_fetchedRecentResultsController) {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject"
		                                          inManagedObjectContext:self.model];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		_fetchedRecentResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.model
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
		[_fetchedRecentResultsController setDelegate:self];
	}
	
	return _fetchedRecentResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent");
    //[(RACSubject *)self.updatedContentSignal sendNext:nil];
    [self updateUserDisplayName];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - DataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [self.fetchedRecentResultsController fetchedObjects].count;
}

-(XMPPMessageArchiving_Contact_CoreDataObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedRecentResultsController objectAtIndexPath:indexPath];
}

-(void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedRecentResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *context = [self.fetchedRecentResultsController managedObjectContext];
    
    if (object) {
        [context deleteObject:object];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

@end
