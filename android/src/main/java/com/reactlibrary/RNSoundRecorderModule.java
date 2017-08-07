
package com.reactlibrary;

import android.media.MediaRecorder;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class RNSoundRecorderModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private MediaRecorder mRecorder = null;
  private String mOutput = null;

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
    constants.put("DOCUMENT_PATH", reactContext.getFilesDir().getAbsolutePath());
    constants.put("CACHE_PATH", reactContext.getCacheDir().getAbsolutePath());
    // constants.put("LIBRARY_PATH", "");
    return constants;
  }
  
  @ReactMethod
  public void start(String path, Promise promise) {
    if(mRecorder != null) {
      promise.reject("already_recording", "Already Recording");
      return;
    }

    mOutput = path;
    mRecorder = new MediaRecorder();
    mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
    mRecorder.setAudioChannels(1); // Mono 1 Stereo 2
    mRecorder.setOutputFile(path);
    mRecorder.setAudioEncodingBitRate(8000);
    mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

    try {
      mRecorder.prepare();
      mRecorder.start();
      promise.resolve(null);
    } catch (IOException e) {
      promise.reject("recording_failed", "Cannot record audio at path: " + path);
    }
  }

  @ReactMethod
  public void stop(Promise promise) {
    if(mRecorder == null) {
      promise.reject("not_recording", "Not Recording");
      return;
    }

    mRecorder.stop();
    mRecorder.release();
    mRecorder = null;

    String output = mOutput;
    mOutput = null;

    promise.resolve(output);
  }

  

}