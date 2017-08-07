
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
        @"PATH_CACHE": [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        @"PATH_DOCUMENT": [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        @"PATH_LIBRARY": [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject],
        
        @"FORMAT_LinearPCM": @(kAudioFormatLinearPCM),
        @"FORMAT_AC3": @(kAudioFormatAC3),
        @"FORMAT_60958AC3": @(kAudioFormat60958AC3),
        @"FORMAT_AppleIMA4": @(kAudioFormatAppleIMA4),
        @"FORMAT_MPEG4AAC": @(kAudioFormatMPEG4AAC),
        @"FORMAT_MPEG4CELP": @(kAudioFormatMPEG4CELP),
        @"FORMAT_MPEG4HVXC": @(kAudioFormatMPEG4HVXC),
        @"FORMAT_MPEG4TwinVQ": @(kAudioFormatMPEG4TwinVQ),
        @"FORMAT_MACE3": @(kAudioFormatMACE3),
        @"FORMAT_MACE6": @(kAudioFormatMACE6),
        @"FORMAT_ULaw": @(kAudioFormatULaw),
        @"FORMAT_ALaw": @(kAudioFormatALaw),
        @"FORMAT_QDesign": @(kAudioFormatQDesign),
        @"FORMAT_QDesign2": @(kAudioFormatQDesign2),
        @"FORMAT_QUALCOMM": @(kAudioFormatQUALCOMM),
        @"FORMAT_MPEGLayer1": @(kAudioFormatMPEGLayer1),
        @"FORMAT_MPEGLayer2": @(kAudioFormatMPEGLayer2),
        @"FORMAT_MPEGLayer3": @(kAudioFormatMPEGLayer3),
        @"FORMAT_TimeCode": @(kAudioFormatTimeCode),
        @"FORMAT_MIDIStream": @(kAudioFormatMIDIStream),
        @"FORMAT_ParameterValueStream": @(kAudioFormatParameterValueStream),
        @"FORMAT_AppleLossless": @(kAudioFormatAppleLossless),
        @"FORMAT_MPEG4AAC_HE": @(kAudioFormatMPEG4AAC_HE),
        @"FORMAT_MPEG4AAC_LD": @(kAudioFormatMPEG4AAC_LD),
        @"FORMAT_MPEG4AAC_ELD": @(kAudioFormatMPEG4AAC_ELD),
        @"FORMAT_MPEG4AAC_ELD_SBR": @(kAudioFormatMPEG4AAC_ELD_SBR),
        @"FORMAT_MPEG4AAC_HE_V2": @(kAudioFormatMPEG4AAC_HE_V2),
        @"FORMAT_MPEG4AAC_Spatial": @(kAudioFormatMPEG4AAC_Spatial),
        @"FORMAT_AMR": @(kAudioFormatAMR),
        @"FORMAT_Audible": @(kAudioFormatAudible),
        @"FORMAT_iLBC": @(kAudioFormatiLBC),
        @"FORMAT_DVIIntelIMA": @(kAudioFormatDVIIntelIMA),
        @"FORMAT_MicrosoftGSM": @(kAudioFormatMicrosoftGSM),
        @"FORMAT_AES3": @(kAudioFormatAES3),
        @"FORMAT_AMR_WB": @(kAudioFormatAMR_WB),
        @"FORMAT_EnhancedAC3": @(kAudioFormatEnhancedAC3),
        @"FORMAT_MPEG4AAC_ELD_V2": @(kAudioFormatMPEG4AAC_ELD_V2),
        
        @"QUALITY_MAX": @(AVAudioQualityMax),
        @"QUALITY_MIN": @(AVAudioQualityMin),
        @"QUALITY_LOW": @(AVAudioQualityLow),
        @"QUALITY_MEDIUM": @(AVAudioQualityMedium),
        @"QUALITY_HIGH": @(AVAudioQualityHigh)
        
    };
}

RCT_EXPORT_METHOD(start:(NSString *)path
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if(_recorder && _recorder.isRecording) {
        reject(@"already_recording", @"Already Recording", nil);
        return;
    }
    
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    
    // https://developer.apple.com/documentation/coreaudio/core_audio_data_types/1572096-audio_data_format_identifiers
    NSNumber* format = [options objectForKey:@"format"];
    if(!format) format = @(kAudioFormatMPEG4AAC);
    [settings setObject:format forKey:AVFormatIDKey];
    
    NSNumber* channels = [options objectForKey:@"channels"];
    if(!channels) channels = @1;
    [settings setObject:channels forKey:AVNumberOfChannelsKey];
    
    NSNumber* bitRate = [options objectForKey:@"bitRate"];
    if(bitRate) [settings setObject:bitRate forKey:AVEncoderBitRateKey];
    
    NSNumber* sampleRate = [options objectForKey:@"sampleRate"];
    if(!sampleRate) sampleRate = @16000;
    [settings setObject:sampleRate forKey:AVSampleRateKey];
    
    NSNumber* quality = [options objectForKey:@"quality"];
    if(!quality) quality = @(AVAudioQualityMax);
    [settings setObject:quality forKey:AVEncoderAudioQualityKey];
    
    
    
    NSError* err = nil;

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:&err];
    
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
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:NO error:&err];
    
    if (err) {
        reject(@"session_set_active_error", [[err userInfo] description], err);
        return;
    }
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&err];
    
    if (err) {
        reject(@"reset_session_error", [[err userInfo] description], err);
        return;
    }
    
    resolve([_recorder url].absoluteString);

}

@end
  
