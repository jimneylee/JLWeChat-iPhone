//
//  MKUploader.m
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-23.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMUploader.h"
#import <AFNetworking/AFNetworking.h>
#import <MUResponseSerializer.h>
#import "IMMacros.h"
#import "IMUIHelper.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import "IMCache.h"


#define IMAGE_TYPE_PNG      @"image/png"
#define IMAGE_TYPE_JPEG     @"image/jpeg"
#define SOUND_TYPE_AMR      @"sound/amr"

@interface MKUploadResponse : NSObject

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* errorCode;
@property (strong, nonatomic) NSString* msg;

@end

@implementation MKUploadResponse

- (NSDictionary *)propertyMap
{
    return @{
             @"return_url": @"url",
             @"code": @"errorCode",
             @"msg": @"msg"
             };
}

@end


@interface IMUploader ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* manager;

@end

@implementation IMUploader

+ (instancetype)uploader
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showAlert = YES;
        self.manager = [AFHTTPRequestOperationManager manager];
        [self.manager setResponseSerializer:[[MUResponseSerializer alloc] initWithResponseClass:[MKUploadResponse class]]];
    }
    return self;
}

- (void)uploadImage:(UIImage*)image url:(void (^)(NSString* url))block
{
    if (image) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSData* data = UIImageJPEGRepresentation(image, 0.8);
            [self uploadData:data type:IMAGE_TYPE_JPEG url:block];
        });
    }
}

- (void)uploadImageArray:(NSArray *)images url:(void (^)(UIImage* image, NSString* url))block
{
    for (UIImage* image in images) {
        [self uploadImage:image url:^(NSString *url) {
            block(image, url);
        }];
    }
}
- (void)uploadImageAsset:(ALAsset *)asset url:(void (^)(NSString* url))block
{
    if (asset) {
        CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
        UIImage* image = [UIImage imageWithCGImage:imageRef];
        [self uploadImage:image url:block];
    }
}
- (void)uploadImageAssets:(NSArray *)assets url:(void (^)(ALAsset* asset, NSString* url))block
{
    for (ALAsset* asset in assets) {
        [self uploadImageAsset:asset url:^(NSString *url) {
            block(asset, url);
        }];
    }
    
//    int count = (int)[assets count];
//    __block int i = 0;
//    NSMutableArray* urls = [NSMutableArray array];
//    __block void (^urlBlock)(NSString *url) ;
//    
//    @weakify(self);
//    @weakify(urlBlock);
//    urlBlock = ^(NSString *url) {
//        @strongify(self);
//        @strongify(urlBlock);
//        //
//        if (url) {
//            [urls addObject:url];
//            if (i++ && i < count) {
//                [self uploadImageAsset:assets[i] url:urlBlock];
//            }
//            else {
//                block(urls);
//            }
//        }
//        else {
//            block(nil);
//        }
//    };
//    
//    if (count > i) {
//        [self uploadImageAsset:assets[i] url:urlBlock];
//    }
}

- (void)uploadData:(NSData*)data type:(NSString*)type url:(void (^)(NSString* url))block
{
    if (!data) {
        return;
    }
    if (self.showAlert) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [IMUIHelper showWaitingMessage:@"上传中..."];
        });
    }

    NSMutableURLRequest *request = [[self.manager requestSerializer] requestWithMethod:@"GET"
                                                                        URLString:nil//[NSString stringWithFormat:@"%@%@", ADDRESS_PATH, MK_UPLOAD_URL]
                                                                       parameters:nil//[MKUtil signForURLParameter:nil]
                                                                            error:nil];
    request.HTTPMethod = @"POST";
    [request setValue:type forHTTPHeaderField: @"Content-Type"];
    
    /*
    NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithRequest:request
                                                                    fromData:data
                                                                    progress:nil
                                                           completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                               [MKUIHelper hideWaitingMessage:nil];
                                                               if (error) {
                                                                   NSLog(@"Error: %@", error);
                                                                   block(nil);
                                                               }
                                                               else {
                                                                   NSLog(@"Success: %@ %@", response, responseObject);
                                                                   MKUploadResponse* uploadRes = (MKUploadResponse*)responseObject;
                                                                   if (uploadRes.url) {
                                                                       [[MKCache sharedCache] cacheData:data
                                                                                             forRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uploadRes.url]]];
                                                                   }
                                                                   block(uploadRes.url);
                                                               }
                                                           }];
    [uploadTask resume];
     */
    [request setHTTPBody:data];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ %@", operation, responseObject);
        if (self.showAlert) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [IMUIHelper hideWaitingMessage:nil];
            });
        }
        
        MKUploadResponse* uploadRes = (MKUploadResponse*)responseObject;
        if (uploadRes.url) {
            [[IMCache sharedCache] cacheData:data
                                  forRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uploadRes.url]]];
        }
        block(uploadRes.url);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (self.showAlert) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [IMUIHelper hideWaitingMessage:nil];
            });
        }
        
        block(nil);
    }];
    [self.manager.operationQueue addOperation:operation];
}

@end
