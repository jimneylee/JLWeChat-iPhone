//
//  IMMessageViewModel.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMChatViewModel.h"
#import "QiniuSDK.h"
#import "IMChatMessageEntityFactory.h"
#import "NSDate+IM.h"
#import "QNAuthPolicy.h"
#import "IMQNFileLoadUtil.h"
#import "IMCache.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#define PAGE_COUNT 10

@interface IMChatViewModel()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) RACSubject *fetchLaterSignal;
@property (nonatomic, strong) RACSubject *fetchEarlierSignal;

@property (nonatomic, strong) NSFetchedResultsController *fetchedEarlierResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedLaterResultsController;

@property (nonatomic, strong) NSManagedObjectContext *model;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;

@property (nonatomic, strong) NSDate *earlierDate;
@property (nonatomic, strong) NSDate *laterDate;
@property (nonatomic, assign) NSInteger newMessageCount;
@end

@implementation IMChatViewModel

-(instancetype)initWithModel:(id)model
{
    self = [super init];
    if (self) {
        self.model = model;

        self.fetchLaterSignal = [[RACSubject subject] setNameWithFormat:@"%@ fetchLaterSignal",
                                     NSStringFromClass([IMChatViewModel class])];
        
        self.fetchEarlierSignal = [[RACSubject subject] setNameWithFormat:@"%@ fetchEarlierSignal",
                                   NSStringFromClass([IMChatViewModel class])];
        
        self.totalResultsSectionArray = [NSMutableArray array];
        self.earlierResultsSectionArray = [NSMutableArray array];
        self.newMessageCount = 0;
    }
    
    return self;
}

-(void)updateFetchLaterDate
{
    if (self.fetchedLaterResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedLaterResultsController.sections lastObject];
        if (sectionInfo) {
            // 由于是降序，第一个日期最晚
            XMPPMessageArchiving_Message_CoreDataObject *laterMessage = [[sectionInfo objects] firstObject];
            if (laterMessage) {
                self.laterDate = laterMessage.timestamp;
            }
        }
    }
}

- (void)mergeAllFetchedResults
{
    @synchronized(self) {
        [self.totalResultsSectionArray removeAllObjects];
        
        // 合并当前聊天数组和历史数组
        if (self.fetchedLaterResultsController.sections.count) {
            [self.totalResultsSectionArray addObjectsFromArray:self.fetchedLaterResultsController.sections];
        }
        if (self.earlierResultsSectionArray.count) {
            [self.totalResultsSectionArray addObjectsFromArray:self.earlierResultsSectionArray];
        }
    }
}

- (NSMutableArray *)totalResultsSectionArray
{
    @synchronized(self) {
        return _totalResultsSectionArray;
    }
}

#pragma mark - Public Send

- (void)fetchEarlierMessage
{
    if (!self.earlierDate) {
        self.earlierDate = [NSDate date];
    }
    
    [self setPredicateForFetchEarlierMessage];
    
    NSError *error = nil;
    if (![self.fetchedEarlierResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch earlier: %@", error);
    }
    else {
        NSIndexPath *indexPath = nil;
        NSArray *fetchedSections = self.fetchedEarlierResultsController.sections;
        if (fetchedSections.count > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [fetchedSections lastObject];
            if (sectionInfo) {
                // 由于是降序，最后一个日期最早
                XMPPMessageArchiving_Message_CoreDataObject *earlierMessage = [[sectionInfo objects] lastObject];
                if (earlierMessage) {
                    self.earlierDate = earlierMessage.timestamp;
                }
            }
            
            [self.earlierResultsSectionArray addObjectsFromArray:fetchedSections];
            
            // 合并当前聊天数组和历史数组
            [self mergeAllFetchedResults];
            
            sectionInfo = [fetchedSections firstObject];// 上一页的第一个section显示在上一页的底部
            if ([sectionInfo numberOfObjects] > 0) {
                indexPath = [NSIndexPath indexPathForRow:[sectionInfo numberOfObjects] - 1
                                               inSection:fetchedSections.count - 1];
            }
            [(RACSubject *)self.fetchEarlierSignal sendNext:indexPath];
        }
    }
    
    // 获取完历史消息，再获取最新信息，这样有新消息时，自动fetch
    [self fetchLaterMessage];
}

- (void)fetchLaterMessage
{
    if (!self.laterDate) {
        self.laterDate = [NSDate date];
    }
    
    [self setPredicateForFetchLaterMessage];
    
    NSError *error = nil;
    if (![self.fetchedLaterResultsController performFetch:&error]) {
        DDLogError(@"Error performing fetch later: %@", error);
    }
    else {
        if (self.fetchedLaterResultsController.sections.count > 0) {
            [(RACSubject *)self.fetchLaterSignal sendNext:nil];
            
            // 更新时间和查询条件
            [self updateFetchLaterDate];
            [self setPredicateForFetchLaterMessage];
        }
    }
}

- (void)sendMessageWithText:(NSString *)text
{
    if (text.length > 0) {
        NSString *JSONString = [IMChatMessageTextEntity JSONStringFromText:text];
        [[IMXMPPManager sharedManager] sendChatMessage:JSONString
                                               toJID:self.buddyJID];
    }
}

- (void)sendMessageWithImage:(UIImage *)image
{
    [IMQNFileLoadUtil uploadImage:image
              keyPrefix:self.buddyJID.user
          completeBlock:^(BOOL success, NSString *key, CGFloat width, CGFloat height) {
              // developer.qiniu.com/docs/v6/api/reference/fop/image/imageview2.html
              //
              if (key.length > 0) {
                  NSString *JSONString = [IMChatMessageImageEntity JSONStringWithImageWidth:width
                                                                                     height:height
                                                                                        url:QN_URL_FOR_KEY(key)];
                  if (JSONString.length > 0) {
                      [[IMXMPPManager sharedManager] sendChatMessage:JSONString
                                                               toJID:self.buddyJID];
                  }
              }
          }];
}

- (void)sendMessageWithAudioTime:(NSInteger)time urlkey:(NSString *)urlkey
{
    // TODO: 体验不太好，目前没有做到下载那样cell中多个语音异步上传，技术点
    //[IMUIHelper showWaitingMessage:@"语音发传中..."];
    __block MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.detailsLabelText = @"语音发传中...(%0.0)";
    [HUD show:YES];
    
    @weakify(self);
    [IMQNFileLoadUtil uploadFileWithUrlkey:urlkey
                             progressBlock:^(NSString *key, CGFloat progress) {
                                 HUD.detailsLabelText = [NSString stringWithFormat:@"语音发传中...(%.1f%%)", progress * 100];
                             }
                             completeBlock:^(BOOL success, NSString *key) {
                                 @strongify(self);
                                 if (success && key.length > 0) {
                                     //[IMUIHelper hideWaitingMessageImmediately];
                                     [HUD hide:YES];
                                     NSString *JSONString = [IMChatMessageAudioEntity JSONStringWithAudioTime:time
                                                                                                          url:QN_URL_FOR_KEY(key)];
                                     if (JSONString.length > 0) {
                                         [[IMXMPPManager sharedManager] sendChatMessage:JSONString
                                                                                  toJID:self.buddyJID];
                                     }
                                 }
                                 else {
                                     HUD.detailsLabelText = @"发送失败";
                                     HUD.mode = MBProgressHUDModeText;
                                     [HUD hide:YES afterDelay:HUD_ANIMATION_DRURATION];
                                     //[IMUIHelper hideWaitingMessage:@"发送失败"];
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPredicateForFetchEarlierMessage
{
    NSPredicate *filterPredicate1 = [NSPredicate predicateWithFormat:
                                     [NSString stringWithFormat:@"bareJidStr = '%@'", self.buddyJID.bare]];
    NSPredicate *filterPredicate2 = [NSPredicate predicateWithFormat:@"%K < %@", @"timestamp", self.earlierDate];
    NSArray *subPredicates = [NSArray arrayWithObjects:filterPredicate1, filterPredicate2, nil];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    [self.fetchedEarlierResultsController.fetchRequest setPredicate:predicate];
}

- (void)setPredicateForFetchLaterMessage
{
    NSPredicate *filterPredicate1 = [NSPredicate predicateWithFormat:
                                     [NSString stringWithFormat:@"bareJidStr = '%@'", self.buddyJID.bare]];
    NSPredicate *filterPredicate2 = [NSPredicate predicateWithFormat:@"timestamp > %@", self.laterDate];
    NSArray *subPredicates = [NSArray arrayWithObjects:filterPredicate1, filterPredicate2, nil];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    [self.fetchedLaterResultsController.fetchRequest setPredicate:predicate];
}

/**
 *  获取历史消息
 */
- (NSFetchedResultsController *)fetchedEarlierResultsController
{
	if (_fetchedEarlierResultsController == nil) {
		NSManagedObjectContext *moc = [[IMXMPPManager sharedManager] managedObjectContext_messageArchiving];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchLimit:PAGE_COUNT];
        
		_fetchedEarlierResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                               managedObjectContext:moc
                                                                                 sectionNameKeyPath:@"sectionIdentifier"
                                                                                          cacheName:nil];
        // 获取历史消息不需要设置代理
		//[_fetchedEarlierResultsController setDelegate:self];
	}
	
	return _fetchedEarlierResultsController;
}


- (NSFetchedResultsController *)fetchedLaterResultsController
{
	if (_fetchedLaterResultsController == nil) {
		NSManagedObjectContext *moc = [[IMXMPPManager sharedManager] managedObjectContext_messageArchiving];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchLimit:PAGE_COUNT];
        
		_fetchedLaterResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                             managedObjectContext:moc
                                                                               sectionNameKeyPath:@"sectionIdentifier"
                                                                                        cacheName:nil];
		[_fetchedLaterResultsController setDelegate:self];
	}
	
	return _fetchedLaterResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self mergeAllFetchedResults];
    [(RACSubject *)self.fetchLaterSignal sendNext:nil];
    
    // 更新时间和查询条件
    [self updateFetchLaterDate];
    [self setPredicateForFetchLaterMessage];
}

- (NSInteger)getRealSection:(NSInteger)section
{
    return [self numberOfSections] - section - 1;
}

#pragma makr - DataSource

-(NSInteger)numberOfSections
{
    return [self.totalResultsSectionArray count];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> theSection = [self.totalResultsSectionArray objectAtIndex:[self getRealSection:section]];
    NSString *dateString = [theSection name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [formatter dateFromString:dateString];
    
    return [date formatChatMessageDate];
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.totalResultsSectionArray[[self getRealSection:section]];
    return [sectionInfo numberOfObjects];
}

-(XMPPMessageArchiving_Message_CoreDataObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.totalResultsSectionArray[[self getRealSection:indexPath.section]];
    NSInteger realRow = [sectionInfo numberOfObjects] - indexPath.row - 1;// section 对应的object还是原数据

    return [sectionInfo objects][realRow];
}

-(void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.totalResultsSectionArray[[self getRealSection:indexPath.section]];
    NSInteger realRow = [sectionInfo numberOfObjects] - indexPath.row - 1;// section 对应的object还是原数据
    NSManagedObject *object =  [sectionInfo objects][realRow];
    
    NSManagedObjectContext *context = [self.fetchedLaterResultsController managedObjectContext];
    if (object) {
        [context deleteObject:object];
        
        NSError *error = nil;
        if ([context save:&error] == NO) {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

@end
