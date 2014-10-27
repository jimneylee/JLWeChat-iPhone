//
//  IMEmotionEntity.m
//  JLWeChat
//
//  Created by jimney on 13-3-5.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "IMEmotionEntity.h"

@implementation IMEmotionEntity

///////////////////////////////////////////////////////////////////////////////////////////////////
// imageName:001.png
// code:[0]
// name:[微笑]
+ (IMEmotionEntity *)entityWithDictionary:(NSDictionary*)dic atIndex:(int)index
{
	IMEmotionEntity* entity = [[IMEmotionEntity alloc] init];
    entity.name = dic[@"name"];
    entity.code = [NSString stringWithFormat:@"[%d]", index];//[dic objectForKey:@"code"];
	entity.imageName = [NSString stringWithFormat:@"Expression_%d.png", index+1];//[dic objectForKey:@"image"];
    
	return entity;
}

@end
