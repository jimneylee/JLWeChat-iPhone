//
//  IMVoiceRecordPlayManager.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-26.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMAudioRecordPlayManager.h"
#import "IMUtil.h"

@interface IMAudioRecordPlayManager()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSURL *recordFileURL;
@property (nonatomic, copy)   NSString *recordUrlKey;

@end

@implementation IMAudioRecordPlayManager

+ (instancetype)sharedManager
{
    static IMAudioRecordPlayManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
        [_sharedManager activeAudioSession];
    });
    
    return _sharedManager;
}

// 开启始终以扬声器模式播放声音
- (void)activeAudioSession
{
    self.session = [AVAudioSession sharedInstance];
    NSError *sessionError = nil;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    if(!self.session) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [self.session setActive:YES error:nil];
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

- (void)startRecord
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [IMUtil generateVoiceTimeKey];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    self.recordUrlKey = fileName;
    self.recordFileURL = [NSURL fileURLWithPath:filePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileURL settings:nil error:nil];
    [self.recorder prepareToRecord];
    [self.recorder record];
}

- (void)stopRecordWithBlock:(void (^)(NSString *urlKey, NSInteger time))block
{
    [self.recorder stop];
#if 0
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:self.recordFileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
#else
    // 暂时通过AVAudioPlayer获取音频时长，后面用更合理的方法替换，定时器是一个不优美、不准确的解决方式
    NSTimeInterval duration = 0;
    NSError *playerError = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileURL
                                                                        error:&playerError];
    if (audioPlayer)  {
        duration = audioPlayer.duration;
    }
    else {
        NSLog(@"Error creating player: %@", [playerError description]);
    }
#endif
    block(self.recordUrlKey, (NSInteger)(ceilf(duration)));
}

@end
