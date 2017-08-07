
#import "RNSoundRecorder.h"
#import <AVFoundation/AVFoundation.h>

@implementation RNSoundRecorder {
    AVAudioRecorder* _recorder;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport
{
    return @{
        @"CACHE_PATH": [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        @"DOCUMENT_PATH": [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        @"LIBRARY_PATH": [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]
    };
}

RCT_EXPORT_METHOD(start:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if(_recorder && _recorder.isRecording) {
        reject(@"already_recording", @"Already Recording", nil);
        return;
    }
    
    NSNumber* _quality = [NSNumber numberWithInt:AVAudioQualityHigh];
    NSNumber* _encoding = [NSNumber numberWithInt:kAudioFormatMPEG4AAC];
    NSNumber* _channels = [NSNumber numberWithInt:1];
    NSNumber* _sampleRate = [NSNumber numberWithFloat:16000.0];

    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                      _quality, AVEncoderAudioQualityKey,
                      _encoding, AVFormatIDKey,
                      _channels, AVNumberOfChannelsKey,
                      _sampleRate, AVSampleRateKey,
                      nil];

    NSError* err = nil;

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if (err) {
        reject(@"init_session_error", [[err userInfo] description], err);
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];

    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    _recorder.delegate = self;

    if (err) {
        reject(@"init_recorder_error", [[err userInfo] description], err);
        return;
    }
    
    [_recorder prepareToRecord];
    [_recorder record];
    [session setActive:YES error:&err];
    
    if (err) {
        reject(@"session_set_active_error", [[err userInfo] description], err);
        return;
    }
    
    if(_recorder.isRecording) {
        resolve([NSNull null]);
    } else {
        reject(@"recording_failed", [@"Cannot record audio at path: " stringByAppendingString:[_recorder url].absoluteString], nil);
    }
    
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if(!_recorder || !_recorder.isRecording) {
        reject(@"not_recording", @"Not Recording", nil);
        return;
    }
    
    NSError* err = nil;
    
    [_recorder stop];
    _recorder = nil; // release it

    [[AVAudioSession sharedInstance] setActive:NO error:&err];
    
    if (err) {
        reject(@"session_set_active_error", [[err userInfo] description], err);
        return;
    }
    
    resolve([_recorder url].absoluteString);

}

@end
  
