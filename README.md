
# react-native-sound-recorder

## Getting started

`$ npm install react-native-sound-recorder --save`

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
  - Add `import com.reactlibrary.RNSoundRecorderPackage;` to the imports at the top of the file
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

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNSoundRecorder.sln` in `node_modules/react-native-sound-recorder/windows/RNSoundRecorder.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Cl.Json.RNSoundRecorder;` to the usings at the top of the file
  - Add `new RNSoundRecorderPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNSoundRecorder from 'react-native-sound-recorder';

// TODO: What do with the module?
RNSoundRecorder;
```
  