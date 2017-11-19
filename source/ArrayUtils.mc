class ArrayUtils {
	// helper methods for https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Lang/Array.html

	// add to back: returns new array
	static function push(target, item) {
		return target.add(item);
	}
	// remove from back: returns new array, and item removed, wrapped in a new array, respectively
	static function pop(target) {
		return [target.slice(0, -1), target.slice(-1, null)];
	}
	// remove from front: returns new array, and item removed, wrapped in a new array, respectively
	static function shift(target) {
		return [target.slice(1, null), target.slice(0, 1)];
	}
	// add to front: returns new array
	static function unshift(target, item) {
		var result = [item];
		for (var i = 0; i < target.size(); i++) {
			result.add(target[i]);
		}
		return result;
	}
}

// vi:syntax=javascript filetype=javascript