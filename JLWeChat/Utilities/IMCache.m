//
//  IMImageCache.m
//  JLWeChat
//
//  Created by john on 14-5-22.
//  Copyright (c) 2014年 john. All rights reserved.
//

#import "IMCache.h"

@interface IMCache ()

@property(nonatomic,strong) NSString *cacheDir;

- (NSString*)IMImageCacheKeyFromURLRequest:(NSURLRequest *)request;

@end


@implementation IMCache

+ (IMCache*)sharedCache
{
    static IMCache *_sharedCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedCache = [[IMCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sharedCache removeAllObjects];
        }];
    });
    
    return _sharedCache;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request
{
    NSData* data = [self cachedDataForRequest:request];
    if (data) {
        return [UIImage imageWithData:data];
    }
    return nil;
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        NSData* data = UIImagePNGRepresentation(image);
        [self cacheData:data forRequest:request];
    }
}

- (void)cacheData:(NSData*)data forRequest:(NSURLRequest *)request
{
    NSAssert([NSThread isMainThread], @"Not on main thread");
    NSString *md5 = [self IMImageCacheKeyFromURLRequest:request];
    
    [self setObject:data forKey:md5];
    NSString *path = [self.cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat",md5]];
    [data writeToFile:path atomically:YES];
}

- (NSData *)cachedDataForRequest:(NSURLRequest *)request
{
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    NSAssert([NSThread isMainThread], @"Not on main thread");
    NSString *md5 = [self IMImageCacheKeyFromURLRequest:request];
    NSData* data = [self objectForKey:md5];
    if (!data) {
        NSString *path = [self.cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat",md5]];
        data = [NSData dataWithContentsOfFile:path];
        if(data) {
            [self setObject:data forKey:md5];
        }
    }
    
	return data;
}

- (NSData *)cachedDataForUrlKey:(NSString *)urlKey
{
    NSData* data = [self objectForKey:urlKey];
    if (!data) {
        NSString *path = [self.cacheDir stringByAppendingPathComponent:urlKey];
        data = [NSData dataWithContentsOfFile:path];
        if(data) {
            [self setObject:data forKey:urlKey];
        }
    }
    
	return data;
}

- (void)removeAllCache
{
    [self removeAllObjects];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *items = [fileManager contentsOfDirectoryAtPath:self.cacheDir error:nil];
    for (NSString *item in items)
    {
        NSString *path = [self.cacheDir stringByAppendingPathComponent:item];
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
    }
}

- (NSString *) IMImageCacheKeyFromURLRequest:(NSURLRequest *)request
{
    NSString* urlStr = [[request URL] absoluteString];
    return urlStr;
}

@end
