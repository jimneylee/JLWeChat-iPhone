//
//  MKAddressBookViewModel.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "RVMViewModel.h"
#import "IMManager.h"

@interface IMAddressBookViewModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@property (nonatomic, strong)   NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong)   NSManagedObjectContext *model;
@property (nonatomic, strong)   NSArray *searchResultArray;
@property (nonatomic, strong)   NSNumber *unsubscribedCountNum;

+ (instancetype)sharedViewModel;

- (NSArray *)sectionIndexTitles;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)deleteUser:(XMPPUserCoreDataStorageObject *)user;
-(BOOL)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)searchContactsWithKeyword:(NSString *)keyword;

@end
