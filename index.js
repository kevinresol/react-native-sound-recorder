
import { NativeModules } from 'react-native';

const { RNSoundRecorder } = NativeModules;

var start = RNSoundRecorder.start;
RNSoundRecorder.start = function(path, options) {
	if(options == null) options = {};
	return start(path, options);
}

export default RNSoundRecorder;
