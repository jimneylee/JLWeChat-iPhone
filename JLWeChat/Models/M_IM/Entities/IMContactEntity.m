//
//  MKContactEntity.m
//  SinaMBlog
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "IMContactEntity.h"
#import "pinyin.h"

@implementation IMContactEntity

///////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithCoreDataUser:(XMPPUserCoreDataStorageObject *)coreDataUser
{
    self = [super init];
    if (self) {
        self.coreDataUser = coreDataUser;
        self.name = coreDataUser.displayName;
        
        if (self.name.length > 0) {
            self.sortString = [self createSortString];
        }
    }

    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString* )getNameWithAt
{
    return [NSString stringWithFormat:@"@%@", self.name];
}

@end
