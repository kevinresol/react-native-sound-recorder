
import { NativeModules, NativeAppEventEmitter, Platform } from 'react-native';

const { RNSoundRecorder } = NativeModules;

var start = RNSoundRecorder.start;
var stop = RNSoundRecorder.stop;

RNSoundRecorder.start = function(path, options) {
	if(options == null) options = {};

    if (this.frameSubscription) {
      this.frameSubscription.remove()
    }

    if(Platform.OS == 'android'){
       this.frameSubscription = NativeAppEventEmitter.addListener(
        'frame',
        data => {
          if (this.onNewFrame) {
            this.onNewFrame(data)
          }
        }
      )
    }

	return start(path, options);

}

RNSoundRecorder.stop = function() {

    if (this.frameSubscription) {
      this.frameSubscription.remove()
    }

	return stop();

}



export default RNSoundRecorder;
