//
//  JLPinyinSortModel.m
//  JLPinyinSort
//
//  Created by jimney on 13-3-12.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "JLPinyinSortModel.h"
#import "JLPinyinSortItem.h"

#define SORT_DEBUG 0

@implementation JLPinyinSortModel

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sort
{
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* items = [NSMutableArray array];
    NSMutableArray* aItems = nil;
#if SORT_DEBUG
    NSLog(@"================before====================");
    for (SMSectionItemBaseEntity* e in self.unsortedArray) {
        NSLog(@"%@", e.name);
    }
#endif
    
    NSArray* sortedArray = [self.unsortedArray sortedArrayUsingSelector:@selector(compare:)];
    
#if SORT_DEBUG
    NSLog(@"=================after sort=====================");
    
    for (SMSectionItemBaseEntity* e in sortedArray) {
        NSLog(@"%@", e.name);
    }
#endif
    // step1、初始生成26 + 1个sections和items
    // step2、根据每个话题首字母，插入对应的数组aItems中
    // step3、删除没有元素的数组aItems和section
    
    // step1
    for (unichar c = 'A'; c <= 'Z'; c++) {
        [sections addObject:[NSString stringWithFormat:@"%c", c]];
        [items addObject:[NSMutableArray array]];
    }
    [sections addObject:@"#"];
    [items addObject:[NSMutableArray array]];
    
    // step2
    int index = 0;
    for (JLPinyinSortItem* e in sortedArray) {
        if (e.firstLetter >= 'A' && e.firstLetter <= 'Z') {
            index = e.firstLetter - 'A';
            aItems = [items objectAtIndex:index];
            [aItems addObject:e];
        }
        else {
            aItems = [items objectAtIndex:items.count - 1];
            [aItems addObject:e];
        }
    }
    
    // step3
    NSMutableArray* newSections = [NSMutableArray array];
    NSMutableArray* newItems = [NSMutableArray array];
    aItems = nil;
    for (int i = 0; i < items.count; i++) {
        aItems = [items objectAtIndex:i];
        if (aItems.count > 0) {
            [newSections addObject:[sections objectAtIndex:i]];
            [newItems addObject:aItems];
        }
    }
    
    self.sections = newSections;
    self.items = newItems;
    
#if SORT_DEBUG
    NSLog(@"=================after section===============");
    for (NSArray* array in self.items) {
        NSLog(@"________________________________________");
        for (SMSectionItemBaseEntity* e in array) {
            NSLog(@"%@", e.name);
        }
    }
    NSLog(@"=================end======================");
#endif
}
@end
