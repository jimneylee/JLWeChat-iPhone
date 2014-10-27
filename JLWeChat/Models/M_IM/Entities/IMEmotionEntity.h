//
//  IMEmotionEntity.h
//  JLWeChat
//
//  Created by jimney on 13-3-5.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMEmotionEntity : NSObject

+ (IMEmotionEntity *)entityWithDictionary:(NSDictionary*)dic atIndex:(int)index;

@property (nonatomic, copy) NSString* code;//for post, ex:[0]
@property (nonatomic, copy) NSString* name;//for parse, ex:[微笑]
@property (nonatomic, copy) NSString* imageName;//ex, Expression_1.png

@end

