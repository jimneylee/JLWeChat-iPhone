//
//  MKPaserdKeyword.m
//  JLOSChina
//
//  Created by jimneylee on 13-12-11.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "MKPaserdKeyword.h"

@implementation MKPaserdKeyword

- (instancetype)initWithKeyword:(NSString *)keyword atRange:(NSRange)range
{
    self = [super init];
    if (self) {
        self.keyword = keyword;
        self.range = range;
    }
    return self;
}

@end
