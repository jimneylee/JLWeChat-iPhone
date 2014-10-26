//
//  IMVoiceRecordPlayManager.h
//  JLWeChat
//
//  Created by jimneylee on 14-10-26.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface IMVoiceRecordPlayManager : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;

+ (instancetype)sharedManager;

- (void)playWithUrl:(NSString *)url;

@end
