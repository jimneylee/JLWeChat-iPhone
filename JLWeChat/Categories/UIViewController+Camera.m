//
//  UIViewController+Camera.m
//  JLWeChat
//
//  Created by John on 14-5-3.
//  Copyright (c) 2014年 John. All rights reserved.
//

#import "UIViewController+Camera.h"
#import "UIImageAdditions.h"
#import <objc/runtime.h>
#import "IMUIHelper.h"
#import <ReactiveCocoa/UIActionSheet+RACSignalSupport.h>

static const void *CameraBlock1 = &CameraBlock1;
static const char kAllowsEditingKey;

@implementation UIViewController (Camera)

@dynamic cameraBlock;

- (void)setCameraBlock:(CameraBlock)cameraBlock
{
    objc_setAssociatedObject(self, CameraBlock1, cameraBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CameraBlock)cameraBlock
{
    return objc_getAssociatedObject(self, CameraBlock1);
}

-(void)setAllowsEditing:(BOOL)allowsEditing
{
    objc_setAssociatedObject(self, &kAllowsEditingKey, [NSNumber numberWithBool:allowsEditing], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)allowsEditing
{
    NSNumber* allowsEditingNumber = objc_getAssociatedObject(self, &kAllowsEditingKey);
    if (!allowsEditingNumber) {
        return NO;
    }
    else {
        return [allowsEditingNumber boolValue];
    }
}


- (void)takeMultiPhoto:(CameraBlock)block maxNum:(int)max
{
    UIActionSheet* mySheet = [[UIActionSheet alloc]
                              initWithTitle:@"选择照片"
                              delegate:self
                              cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                              otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    [[mySheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
        if ([indexNumber intValue] == 0) {
            [self photoFromCamera:block allowsEditing:NO];
        } else if([indexNumber intValue] == 1){
            [self multiPhotoFromLibrary:block maxNum:max];
        }
        else
        {
            
        }
    }];
    [mySheet showInView:self.view];
}

- (void)takeOnePhoto:(CameraBlock)block allowsEditing:(BOOL)allowsEditing
{
    UIActionSheet* mySheet = [[UIActionSheet alloc]
                              initWithTitle:@"选择照片"
                              delegate:self
                              cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                              otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    [[mySheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
        if ([indexNumber intValue] == 0) {
            [self photoFromCamera:block allowsEditing:allowsEditing];
        } else if ([indexNumber intValue] == 1){
            [self photoFromLibrary:block allowsEditing:allowsEditing];
        }
    }];
    [mySheet showInView:self.view];
}

- (void)photoFromCamera:(CameraBlock)block allowsEditing:(BOOL)allowsEditing
{
    self.cameraBlock = block;
    self.allowsEditing = allowsEditing;
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = allowsEditing;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePickerController.delegate = self;
    [IMUIHelper configAppearenceForNavigationBar:imagePickerController.navigationBar];
    [self.navigationController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)photoFromLibrary:(CameraBlock)block allowsEditing:(BOOL)allowsEditing
{
    self.cameraBlock = block;
    self.allowsEditing = allowsEditing;
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = self.allowsEditing;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePickerController.delegate = self;
    [IMUIHelper configAppearenceForNavigationBar:imagePickerController.navigationBar];
    [self.navigationController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)multiPhotoFromLibrary:(CameraBlock)block maxNum:(int)max
{
    self.cameraBlock = block;
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }
    else {
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.title = @"选择图片";
        if (max > 1) {
            imagePickerController.allowsMultipleSelection = YES;
            imagePickerController.maximumNumberOfSelection = max;
        }
        
        UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - 



- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    @weakify(self);
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        self.cameraBlock([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
    }];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSMutableArray* array = [NSMutableArray array];
    for (ALAsset* asset in assets) {
        UIImage* image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        if (image) {
            [array addObject:image];
        }
    }
    @weakify(self);
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        self.cameraBlock(array);
    }];
}

#pragma mark - UIImagePicker

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        self.cameraBlock(nil);
    }];
}

- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* original_image = nil;
    if (self.allowsEditing) {
        original_image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else {
        original_image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    CGRect rect = [original_image convertRect:CGRectMake(0, 0, 600, 600) withContentMode:UIViewContentModeScaleAspectFit];
    UIImage* image = [original_image transformWidth:rect.size.width height:rect.size.height rotate:YES];
    
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        //;
        @strongify(self);
        self.cameraBlock(image);
    }];
}

@end
