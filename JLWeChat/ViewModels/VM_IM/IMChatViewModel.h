//
//  IMMessageViewModel.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-21.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "RVMViewModel.h"
#import "IMManager.h"

/**
 *  消息聊天model
 *  分页获取数据实现原理和机制
 *  通过两个fetch控制器去分别获取历史消息和本次聊天内容
 *  当获取后，合并为总的数组，由于是降序，最新的信息在数组顶部
 *  反向显示数组的数据，section和row都需要反向考虑，逻辑有点憋屈
 */
@interface IMChatViewModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *fetchLaterSignal;
@property (nonatomic, readonly) RACSignal *fetchEarlierSignal;
@property (nonatomic, strong) XMPPJID *buddyJID;
@property (nonatomic, strong) NSMutableArray *earlierResultsSectionArray;
@property (nonatomic, strong) NSMutableArray *totalResultsSectionArray;

- (instancetype)initWithModel:(id)model;

- (NSInteger)numberOfSections;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (XMPPMessageArchiving_Message_CoreDataObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)fetchEarlierMessage;
- (void)fetchLaterMessage;

- (void)sendMessageWithText:(NSString *)text;
- (void)sendMessageWithImage:(UIImage *)image;
- (void)sendMessageWithVoiceTime:(NSInteger)time urlkey:(NSString *)urlkey;

@end
