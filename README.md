
# react-native-sound-recorder

No-hassle Sound Recorder for React Native.

#### There are existing libraries out in the wild

- https://github.com/MisterAlex95/react-native-record-sound
- https://github.com/jsierles/react-native-audio

#### Why reinvent the wheel?

At the time of writing, the above libaries are either inconsistent or incomplete.

For example, the same `startRecording` call returns a `Promise` on Android but `null` in iOS.

Or `stopRecording` doesn't give a promise/callback at all. So forcing user to do silly things like "wait for 1 second" in order to make sure file is well written to disk.

## Getting started

`$ npm install react-native-sound-recorder --save`

or

`$ yarn add react-native-sound-recorder`


**if RN >= 0.60.0**

Autolink should work

**if RN < 0.60.0**

### Mostly automatic installation

`$ react-native link react-native-sound-recorder`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sound-recorder` and add `RNSoundRecorder.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSoundRecorder.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.kevinresol.react_native_sound_recorder.RNSoundRecorderPackage;` to the imports at the top of the file
  - Add `new RNSoundRecorderPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-sound-recorder'
  	project(':react-native-sound-recorder').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-sound-recorder/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-sound-recorder')
  	```
## Permissions

**iOS**: Add the following entry to `Info.plist`:

```
<key>NSMicrophoneUsageDescription</key>
<string>This sample uses the microphone to record your speech and convert it to text.</string>
```

**Android**: Add the following entry to `AndroidManifest.xml`:

```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```


## Usage
```javascript
import SoundRecorder from 'react-native-sound-recorder';

// Note: You may need to request runtime permission(s) first.

SoundRecorder.start(SoundRecorder.PATH_CACHE + '/test.mp4')
	.then(function() {
		console.log('started recording');
	});

SoundRecorder.stop()
	.then(function(result) {
		console.log('stopped recording, audio file saved at: ' + result.path);
	});
	
```
  
  
## API
```haxe
function start(path:String, ?options:Object):Promise<Void>;
function stop():Promise<{path:String, duration:Int}>;
function pause():Promise<Void>;
function resume():Promise<Void>;
```

### Options:

iOS:

- `quality`:Enum (Check out the [constants][ios constants] prefixed with `"QUALITY_"`)
- `format`:Enum (Check out the [constants][ios constants] prefixed with `"FORMAT_"`)
- `bitRate`:Int, default: not set (will fail on iPhone5 if set)
- `channels`:Int (1 or 2), default: 1
- `sampleRate`:Int default: 16000

Android:

- `source`:Enum (Check out the [constants][android constants] prefixed with `"SOURCE_"`)
- `format`:Enum (Check out the [constants][android constants] prefixed with `"FORMAT_"`)
- `encoder`:Enum (Check out the [constants][android constants] prefixed with `"ENCODER_"`)
- `channels`:Int (1 or 2), default: 1
- `bitRate`:Int, default: 64000
- `sampleRate`:Int default: 16000

Note that the above enums are platform-specific.

### Path Constants

- PATH_CACHE 
- PATH_DOCUMENT 
- PATH_LIBRARY (N/A on Android)

[android constants]: https://github.com/kevinresol/react-native-sound-recorder/blob/master/android/src/main/java/com/kevinresol/react_native_sound_recorder/RNSoundRecorderModule.java#L40
[ios constants]: https://github.com/kevinresol/react-native-sound-recorder/blob/master/ios/RNSoundRecorder.m#L15
