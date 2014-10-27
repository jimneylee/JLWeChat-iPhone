//
//  IMImageCache.h
//  JLWeChat
//
//  Created by john on 14-5-22.
//  Copyright (c) 2014年 john. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface IMCache : NSCache <AFImageCache>

+ (IMCache*)sharedCache;
- (void)removeAllCache;
- (void)cacheData:(NSData*)data forRequest:(NSURLRequest *)request;
- (NSData *)cachedDataForUrlKey:(NSString *)urlKey;
- (NSData *)cachedDataForRequest:(NSURLRequest *)request;

@end
