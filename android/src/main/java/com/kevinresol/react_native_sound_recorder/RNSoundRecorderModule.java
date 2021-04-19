package com.kevinresol.react_native_sound_recorder;

import android.media.MediaMetadataRetriever;
import android.media.MediaRecorder;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import java.util.Timer;
import java.util.TimerTask;


public class RNSoundRecorderModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private MediaRecorder mRecorder = null;
  private String mOutput = null;
  private boolean isRecording = false;
  private Timer timer;
  private int frameId = 0;

  private static final String OPTION_KEY_SOURCE = "source";
  private static final String OPTION_KEY_FORMAT = "format";
  private static final String OPTION_KEY_CHANNELS = "channels";
  private static final String OPTION_KEY_ENCODING_BIT_RATE = "encodingBitRate";
  private static final String OPTION_KEY_ENCODER = "encoder";
  private static final String OPTION_KEY_SAMPLE_RATE= "sampleRate";

  public RNSoundRecorderModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNSoundRecorder";
  }

  @Override
  public Map<String, Object> getConstants() {
    Map<String, Object> constants = new HashMap<>();
    constants.put("PATH_DOCUMENT", reactContext.getFilesDir().getAbsolutePath());
    constants.put("PATH_CACHE", reactContext.getCacheDir().getAbsolutePath());
    // constants.put("PATH_LIBRARY", "");

    constants.put("SOURCE_CAMCORDER", MediaRecorder.AudioSource.CAMCORDER);
    constants.put("SOURCE_MIC", MediaRecorder.AudioSource.MIC);
    constants.put("SOURCE_REMOTE_SUBMIX", MediaRecorder.AudioSource.REMOTE_SUBMIX);
    constants.put("SOURCE_VOICE_CALL", MediaRecorder.AudioSource.VOICE_CALL);
    constants.put("SOURCE_VOICE_COMMUNICATION", MediaRecorder.AudioSource.VOICE_COMMUNICATION);
    constants.put("SOURCE_VOICE_DOWNLINK", MediaRecorder.AudioSource.VOICE_DOWNLINK);
    constants.put("SOURCE_VOICE_RECOGNITION", MediaRecorder.AudioSource.VOICE_RECOGNITION);
    constants.put("SOURCE_VOICE_UPLINK", MediaRecorder.AudioSource.VOICE_UPLINK);

    constants.put("FORMAT_AAC_ADTS", MediaRecorder.OutputFormat.AAC_ADTS);
    constants.put("FORMAT_AMR_NB", MediaRecorder.OutputFormat.AMR_NB);
    constants.put("FORMAT_AMR_WB", MediaRecorder.OutputFormat.AMR_WB);
    constants.put("FORMAT_MPEG_4", MediaRecorder.OutputFormat.MPEG_4);
    constants.put("FORMAT_THREE_GPP", MediaRecorder.OutputFormat.THREE_GPP);
    constants.put("FORMAT_WEBM", MediaRecorder.OutputFormat.WEBM);

    constants.put("ENCODER_AAC", MediaRecorder.AudioEncoder.AAC);
    constants.put("ENCODER_AAC_ELD", MediaRecorder.AudioEncoder.AAC_ELD);
    constants.put("ENCODER_AMR_NB", MediaRecorder.AudioEncoder.AMR_NB);
    constants.put("ENCODER_AMR_WB", MediaRecorder.AudioEncoder.AMR_WB);
    constants.put("ENCODER_HE_AAC", MediaRecorder.AudioEncoder.HE_AAC);
    constants.put("ENCODER_VORBIS", MediaRecorder.AudioEncoder.VORBIS);

    return constants;
  }

  @ReactMethod
  public void start(String path, ReadableMap options, Promise promise) {
    if(mRecorder != null) {
      promise.reject("already_recording", "Already Recording");
      return;
    }

    // parse options
    int source = MediaRecorder.AudioSource.DEFAULT;
    if(options.hasKey(OPTION_KEY_SOURCE))
      source = options.getInt(OPTION_KEY_SOURCE);

    int format = MediaRecorder.OutputFormat.DEFAULT;
    if(options.hasKey(OPTION_KEY_FORMAT))
      format = options.getInt(OPTION_KEY_FORMAT);

    int channels = 1;
    if(options.hasKey(OPTION_KEY_CHANNELS))
      channels = options.getInt(OPTION_KEY_CHANNELS);

    int encodingBitRate = 64000;
    if(options.hasKey(OPTION_KEY_ENCODING_BIT_RATE))
      encodingBitRate = options.getInt(OPTION_KEY_ENCODING_BIT_RATE);

    int encoder = MediaRecorder.AudioEncoder.DEFAULT;
    if(options.hasKey(OPTION_KEY_ENCODER))
      encoder = options.getInt(OPTION_KEY_ENCODER);

    int sampleRate = 16000;
    if(options.hasKey(OPTION_KEY_SAMPLE_RATE))
      sampleRate = options.getInt(OPTION_KEY_SAMPLE_RATE);

    mOutput = path;
    mRecorder = new MediaRecorder();
    mRecorder.setAudioSource(source);
    mRecorder.setOutputFormat(format);
    mRecorder.setAudioChannels(channels);
    mRecorder.setOutputFile(path);
    mRecorder.setAudioEncodingBitRate(encodingBitRate);
    mRecorder.setAudioEncoder(encoder);
    mRecorder.setAudioSamplingRate(sampleRate);

    try {
      mRecorder.prepare();
      mRecorder.start();
      startTimer();
      frameId = 0;
      isRecording = true;
      promise.resolve(null);
    } catch (IOException e) {
      promise.reject("recording_failed", "Cannot record audio at path: " + path);
    } catch (IllegalStateException e) {
      promise.reject("recording_failed", "Microphone is already in use by another app.");
    }
  }

  @ReactMethod
  public void stop(Promise promise) {
    if(mRecorder == null) {
      promise.reject("not_recording", "Not Recording");
      return;
    }

    stopTimer();
    isRecording = false;

    try {
      mRecorder.stop();
    } catch (Exception e) {
      mRecorder.reset();
      mRecorder.release();
      mRecorder = null;
      promise.reject("stopping_failed", "Stop failed: " + e);
      return;
    }

    mRecorder.reset();
    mRecorder.release();
    mRecorder = null;

    MediaMetadataRetriever retriever = new MediaMetadataRetriever();
    retriever.setDataSource(mOutput);
    int duration = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));

    WritableMap response = Arguments.createMap();

    response.putInt("duration", duration);
    response.putString("path", mOutput);
    mOutput = null;

    promise.resolve(response);
  }

  @ReactMethod
  public void pause(Promise promise) {
    if(mRecorder == null) {
      promise.reject("not_recording", "Not Recording");
      return;
    }

    try {
      mRecorder.pause();
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject("pausing_failed", "Pause failed: " + e);
    }
  }

  @ReactMethod
  public void resume(Promise promise) {
    if(mRecorder == null) {
      promise.reject("not_recording", "Not Recording");
      return;
    }

    try {
      mRecorder.resume();
      promise.resolve(null);
    } catch (Exception e) {
      promise.reject("resuming_failed", "Resume failed: " + e);
    }

  }

  private void startTimer() {
    timer = new Timer();
    timer.scheduleAtFixedRate(new TimerTask() {
      @Override
      public void run() {

          WritableMap body = Arguments.createMap();
          body.putDouble("id", frameId++);

          int amplitude = mRecorder.getMaxAmplitude();
          if (amplitude == 0) {
            body.putInt("value", -160);
            body.putInt("rawValue", 0);
          } else {
            body.putInt("rawValue", amplitude);
            body.putInt("value", (int) (20 * Math.log(((double) amplitude) / 32767d)));
          }

          sendEvent("frame", body);
      }
    }, 0, 250);
  }

  private void stopTimer() {
    if (timer != null) {
      timer.cancel();
      timer.purge();
      timer = null;
    }
  }

  private void sendEvent(String eventName, Object params) {
    getReactApplicationContext()
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }


}
