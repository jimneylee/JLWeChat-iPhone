//
//  MKContactEntity.h
//  SinaMBlog
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "JLPinyinSortItem.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface IMContactEntity : JLPinyinSortItem

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *coreDataUser;

- (instancetype)initWithCoreDataUser:(XMPPUserCoreDataStorageObject *)coreDataUser;
- (NSString* )getNameWithAt;

@end
