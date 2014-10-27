//
//  IMChatShareMoreView.h
//  JLWeChat
//
//  Created by Lee jimney on 5/24/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import <Nimbus/NimbusLauncher.h>

@protocol IMChatShareMoreViewDelegate;

@interface IMChatShareMoreView : NILauncherView

@property (nonatomic, weak) id<IMChatShareMoreViewDelegate> shareMoreDelegate;

@end

@protocol IMChatShareMoreViewDelegate <NSObject>

@optional
- (void)didPickPhotoFromLibrary;
- (void)didPickPhotoFromCamera;

@end