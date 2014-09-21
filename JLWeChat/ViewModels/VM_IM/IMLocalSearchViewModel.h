//
//  IMLocalSearchViewModel.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-31.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "RVMViewModel.h"
#import "IMManager.h"

/**
 *  本地搜索分为：
 *  通讯录联系人：用户号和昵称
 *  聊天记录：每个人对应几条记录
 */
@interface IMLocalSearchViewModel : RVMViewModel<UITableViewDataSource>

@property (nonatomic, readonly) RACSignal *updatedContentSignal;

- (void)searchWithkeywords:(NSString *)keywords;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
