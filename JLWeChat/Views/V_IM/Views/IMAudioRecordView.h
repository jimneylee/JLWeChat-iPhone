//
//  IMVoiceRecordView.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMVoiceRecordViewDelegate;

@interface IMAudioRecordView : UIView

@property (nonatomic, weak) id<IMVoiceRecordViewDelegate> delegate;

@end

@protocol IMVoiceRecordViewDelegate <NSObject>

- (void)didFinishRecordingVoiceWithUrlKey:(NSString *)urlKey time:(NSInteger)time;

@end