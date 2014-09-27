//
//  IMContactModel.h
//  JLWeChat
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "JLPinyinSortModel.h"
#import "IMContactEntity.h"

@interface IMContactModel : JLPinyinSortModel

- (instancetype)initWithDataArray:(NSArray*)dataArray;
- (void)updateDataArray:(NSArray*)dataArray;

@end
