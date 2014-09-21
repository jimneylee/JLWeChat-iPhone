//
//  MKChatShareMoreView.h
//  JLIM4iPhone
//
//  Created by Lee jimney on 5/24/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import <Nimbus/NimbusLauncher.h>

@protocol MKChatShareMoreViewDelegate;

@interface IMChatShareMoreView : NILauncherView

@property (nonatomic, weak) id<MKChatShareMoreViewDelegate> shareMoreDelegate;

@end

@protocol MKChatShareMoreViewDelegate <NSObject>

@optional
- (void)didPickPhotoFromLibrary;
- (void)didPickPhotoFromCamera;

@end