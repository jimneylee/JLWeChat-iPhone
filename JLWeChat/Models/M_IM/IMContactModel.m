//
//  IMContactModel.m
//  JLIM4iPhone
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "IMContactModel.h"

@implementation IMContactModel

///////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDataArray:(NSArray*)dataArray
{
    self = [super init];
    if (self) {
        [self updateDataArray:dataArray];
    }
    return self;
}

- (void)updateDataArray:(NSArray*)dataArray
{
    if (dataArray.count > 0) {
        self.unsortedArray = [NSMutableArray arrayWithCapacity:dataArray.count];
        for (XMPPUserCoreDataStorageObject *user in dataArray) {
            IMContactEntity* e = [[IMContactEntity alloc] initWithCoreDataUser:user];
            if (e) {
                [self.unsortedArray addObject:e];
            }
        }
        
        [self sort];
    }
}

@end
