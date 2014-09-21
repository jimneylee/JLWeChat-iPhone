//
//  JLPinyinSortItem.h
//  JLPinyinSort
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

@interface JLPinyinSortItem : NSObject

@property (nonatomic, copy)     NSString* name;
@property (nonatomic, copy)     NSString* sortString;   // 供排序所用字串
@property (nonatomic, assign)   unichar firstLetter;    // 首字母

- (NSString* )createSortString;

@end
