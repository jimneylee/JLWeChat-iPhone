//
//  RCKeywordsEntity.h
//  JLOSChina
//
//  Created by jimneylee on 13-12-11.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKPaserdKeyword : NSObject

@property (nonatomic, copy) NSString* keyword;
@property (nonatomic, assign) NSRange range;

- (instancetype)initWithKeyword:(NSString *)keyword atRange:(NSRange)range;

@end
