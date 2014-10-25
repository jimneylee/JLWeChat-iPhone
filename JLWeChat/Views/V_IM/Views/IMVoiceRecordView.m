//
//  IMVoiceRecordView.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMVoiceRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import "IMUtil.h"
#import "IMCache.h"

@interface IMVoiceRecordView()

@property (nonatomic, strong) NSURL *recordFileURL;
//AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, copy) NSString *urlKey;

@end
@implementation IMVoiceRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(244, 244, 244);

        UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 120.f, 120.f)];
        [recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(startRecordVoiceAction) forControlEvents:UIControlEventTouchDown];
        [recordBtn addTarget:self action:@selector(stopRecord)
            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addSubview:recordBtn];
        
        recordBtn.layer.cornerRadius = recordBtn.width / 2.f;
        recordBtn.backgroundColor = [UIColor blueColor];
        
        recordBtn.center = CGPointMake(self.width / 2, self.height / 2);
        
//        self.recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(!session) {
            NSLog(@"Error creating session: %@", [sessionError description]);
        }
        else {
            [session setActive:YES error:nil];
        }
    }
    return self;
}

- (void)startRecordVoiceAction
{
//    [recordBtn setTitle:@"录音中" forState:UIControlStateNormal];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [IMUtil generateVoiceTimeKey];
    NSString *path = [cacheDir stringByAppendingPathComponent:fileName];
    self.urlKey = fileName;
    self.recordFileURL = [NSURL fileURLWithPath:path];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileURL settings:nil error:nil];
    [self.recorder prepareToRecord];
    [self.recorder record];
}

- (void)stopRecord
{
    [self.recorder stop];
    
    // delegate to send record
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRecordingVoiceWithUrlKey:time:)]) {
        [self.delegate didFinishRecordingVoiceWithUrlKey:self.urlKey time:self.recorder.currentTime];
    }
}

@end
