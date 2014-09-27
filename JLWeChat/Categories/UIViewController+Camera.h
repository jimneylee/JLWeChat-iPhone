//
//  UIViewController+Camera.h
//  JLWeChat
//
//  Created by John on 14-5-3.
//  Copyright (c) 2014年 John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QBImagePickerController/QBImagePickerController.h>

typedef void (^CameraBlock)(id object);

@interface UIViewController (Camera) <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate>

@property (strong, nonatomic) CameraBlock cameraBlock;
@property (assign, nonatomic) BOOL allowsEditing;

- (void)takeOnePhoto:(CameraBlock)block allowsEditing:(BOOL)allowsEditing;
- (void)takeMultiPhoto:(CameraBlock)block maxNum:(int)max;

- (void)photoFromCamera:(CameraBlock)block allowsEditing:(BOOL)allowsEditing;
- (void)photoFromLibrary:(CameraBlock)block allowsEditing:(BOOL)allowsEditing;
- (void)multiPhotoFromLibrary:(CameraBlock)block maxNum:(int)max;

@end
