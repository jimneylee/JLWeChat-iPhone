//
//  MKImageCache.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface IMCache : NSCache <AFImageCache>

+ (IMCache*)sharedCache;
- (void)removeAllCache;
- (void)cacheData:(NSData*)data forRequest:(NSURLRequest *)request;
- (NSData *)cachedDataForRequest:(NSURLRequest *)request;

@end
