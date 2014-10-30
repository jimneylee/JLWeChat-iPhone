//
//  IMAudioRecordView.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMAudioRecordViewDelegate;

@interface IMAudioRecordView : UIView

@property (nonatomic, weak) id<IMAudioRecordViewDelegate> delegate;

@end

@protocol IMAudioRecordViewDelegate <NSObject>

- (void)didFinishRecordingAudioWithUrlKey:(NSString *)urlKey time:(NSInteger)time;

@end