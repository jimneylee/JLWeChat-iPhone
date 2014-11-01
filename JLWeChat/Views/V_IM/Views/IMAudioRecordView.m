//
//  IMAudioRecordView.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMAudioRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import "IMQNFileLoadUtil.h"
#import "IMCache.h"
#import "IMAudioRecordPlayManager.h"

@interface IMAudioRecordView()

@property (nonatomic, strong) UIButton *recordBtn;

@end

@implementation IMAudioRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(244, 244, 244);

        UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 120.f, 120.f)];
        [recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(startRecordVoiceAction)
            forControlEvents:UIControlEventTouchDown];
        [recordBtn addTarget:self action:@selector(stopRecord)
            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addSubview:recordBtn];
        
        recordBtn.layer.cornerRadius = recordBtn.width / 2.f;
        recordBtn.backgroundColor = [UIColor blueColor];
        recordBtn.center = CGPointMake(self.width / 2, self.height / 2);
        
        self.recordBtn = recordBtn;
    }
    return self;
}

- (void)startRecordVoiceAction
{
    [self.recordBtn setTitle:@"录音中..." forState:UIControlStateNormal];
    self.recordBtn.backgroundColor = [UIColor greenColor];
    
    [[IMAudioRecordPlayManager sharedManager] startRecord];
}

- (void)stopRecord
{
    [self.recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    self.recordBtn.backgroundColor = [UIColor blueColor];
    
    [[IMAudioRecordPlayManager sharedManager] stopRecordWithBlock:^(NSString *urlKey, NSInteger time) {
        if (time >0 && self.delegate && [self.delegate respondsToSelector:@selector(didFinishRecordingAudioWithUrlKey:time:)]) {
            [self.delegate didFinishRecordingAudioWithUrlKey:urlKey time:(NSInteger)time];
        }
    }];
}

@end
