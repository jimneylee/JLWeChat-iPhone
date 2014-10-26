//
//  IMVoiceRecordPlayManager.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-26.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMVoiceRecordPlayManager.h"

@interface IMVoiceRecordPlayManager()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioSession *audioSession;

@end

@implementation IMVoiceRecordPlayManager

+ (instancetype)sharedManager
{
    static IMVoiceRecordPlayManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
        [_sharedManager activeAudioSession];
    });
    
    return _sharedManager;
}

// 以扬声器模式播放声音
- (void)activeAudioSession
{
    self.audioSession = [AVAudioSession sharedInstance];    
    NSError *sessionError = nil;
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    if(!self.audioSession) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [self.audioSession setActive:YES error:nil];
    }
}
- (void)playWithUrl:(NSString *)url
{
    if (self.player) {
        if (self.player.isPlaying) {
            [self.player stop];
        }
        
        self.player.delegate = nil;
        self.player = nil;
    }
    
    NSString *fileName = [url lastPathComponent];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    NSURL *URL = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        URL = [NSURL fileURLWithPath:filePath];
    }
    else {
        URL = [NSURL URLWithString:url];
    }
    
    NSError *playerError = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:&playerError];
    if (self.player)  {
        self.player.delegate = self;
        [self.player play];
    }
    else {
        NSLog(@"Error creating player: %@", [playerError description]);
    }
}

@end
