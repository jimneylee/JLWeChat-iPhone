//
//  IMLocalSearchViewModel.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-31.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMLocalSearchViewModel.h"
#import "IMContactModel.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.h"

#import "IMContactCell.h"
#import "IMChatC.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface IMLocalSearchViewModel()<NSFetchedResultsControllerDelegate>

@property (nonatomic, copy)   NSString *keywords;
@property (nonatomic, strong) NSFetchedResultsController *contactFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedRecentResultsController;
@property (nonatomic, strong) NSFetchedResultsController *chatMessageFetchedResultsController;
@property (nonatomic, strong) NSArray *contactsResultArray;
@property (nonatomic, strong) NSMutableArray *chatMessagesResultArray;
@property (nonatomic, strong) NSMutableArray *sectionTitlesArray;
@property (nonatomic, strong) NSMutableArray *sectionResultsArray;

@end

@implementation IMLocalSearchViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.contactsResultArray = [NSMutableArray array];
        self.chatMessagesResultArray = [NSMutableArray array];
        self.sectionTitlesArray = [NSMutableArray array];
        self.sectionResultsArray = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark Public

- (void)searchWithkeywords:(NSString *)keywords
{
    [self.chatMessagesResultArray removeAllObjects];
    [self.sectionTitlesArray removeAllObjects];
    [self.sectionResultsArray removeAllObjects];
    
    self.keywords = keywords;
    [self fetchContacts];
    [self fetchRecentContact];

    if (self.contactsResultArray.count > 0) {
        [self.sectionTitlesArray addObject:@"联系人"];
        [self.sectionResultsArray addObject:self.contactsResultArray];
    }
    
    if (self.chatMessagesResultArray.count > 0) {
        [self.sectionTitlesArray addObject:@"聊天记录"];
        [self.sectionResultsArray addObject:self.chatMessagesResultArray];
    }
    
    [(RACSubject *)self.updatedContentSignal sendNext:nil];
}

#pragma mark Private

- (void)fetchContacts
{
    // predicate
    // [c]忽略大小写
    // TODO:后面考虑jid.user匹配，类似微信号的查找
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"displayName like[c] '*%@*'",
                                                                     self.keywords]];
    [self.contactFetchedResultsController.fetchRequest setPredicate:filterPredicate];
    
    NSError *error = nil;
    if (![self.contactFetchedResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch: %@", error);
    }
    else {
        self.contactsResultArray = [self.contactFetchedResultsController fetchedObjects];
    }
}

- (void)fetchRecentContact
{
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"streamBareJidStr = '%@'",
                                                                     [IMXMPPManager sharedManager].myJID.bare]];
    [self.fetchedRecentResultsController.fetchRequest setPredicate:filterPredicate];
    
    NSError *error = nil;
    if (![self.fetchedRecentResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch: %@", error);
    }
    else {
        [self searchChatMessage];
    }
}

- (void)searchChatMessage
{
    NSArray *array = [self.fetchedRecentResultsController fetchedObjects];
    if (array.count > 0) {
        for (XMPPMessageArchiving_Contact_CoreDataObject *coreDataContact in array) {
            [self fetchChatMessagesWithCoreDataContact:coreDataContact];
        }
    }
}

- (void)fetchChatMessagesWithCoreDataContact:(XMPPMessageArchiving_Contact_CoreDataObject *)coreDataContact
{
    NSPredicate *filterPredicate1 = [NSPredicate predicateWithFormat:
                                     [NSString stringWithFormat:@"bareJidStr = '%@'", coreDataContact.bareJid.bare]];
    NSPredicate *filterPredicate2 = [NSPredicate predicateWithFormat:
                                     [NSString stringWithFormat:@"messageStr like[c] '*%@*'", self.keywords]];
    NSArray *subPredicates = [NSArray arrayWithObjects:filterPredicate1, filterPredicate2, nil];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    [self.chatMessageFetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![self.chatMessageFetchedResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch: %@", error);
    }
    else {
        NSArray *resultArray = [self.chatMessageFetchedResultsController fetchedObjects];
        coreDataContact.chatRecord = [NSString stringWithFormat:@"%d条相关聊天记录", resultArray.count];
        if (resultArray.count > 0) {
            [self.chatMessagesResultArray addObject:coreDataContact];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)contactFetchedResultsController
{
	if (_contactFetchedResultsController == nil) {
        NSManagedObjectContext *moc = [[IMXMPPManager sharedManager] managedObjectContext_roster];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        // sort
		NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
		
		_contactFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:moc
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
	}
	
	return _contactFetchedResultsController;
}


- (NSFetchedResultsController *)fetchedRecentResultsController
{
	if (!_fetchedRecentResultsController) {
        NSManagedObjectContext *moc = [[IMXMPPManager sharedManager] managedObjectContext_messageArchiving];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		_fetchedRecentResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                              managedObjectContext:moc
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil];
		[_fetchedRecentResultsController setDelegate:self];
	}
	
	return _fetchedRecentResultsController;
}

- (NSFetchedResultsController *)chatMessageFetchedResultsController
{
	if (!_chatMessageFetchedResultsController) {
		NSManagedObjectContext *moc = [[IMXMPPManager sharedManager] managedObjectContext_messageArchiving];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
		                                          inManagedObjectContext:moc];
		[fetchRequest setEntity:entity];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"streamBareJidStr = '%@'",
                                                                         [IMXMPPManager sharedManager].myJID.bare]];
        [fetchRequest setPredicate:filterPredicate];
        
		_chatMessageFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                               managedObjectContext:moc
                                                                                 sectionNameKeyPath:nil
                                                                                          cacheName:nil];
	}
	
	return _chatMessageFetchedResultsController;
}

#pragma mark Public

-(NSInteger)numberOfSections
{
    return self.sectionTitlesArray.count;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitlesArray[section];
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.sectionResultsArray[section];
    return array.count;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSArray *array = self.sectionResultsArray[section];
    if (array.count > indexPath.row) {
        return [array objectAtIndex:indexPath.row];
    }
    
    return nil;
}

@end
