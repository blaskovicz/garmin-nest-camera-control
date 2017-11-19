using Toybox.Attention;
using Toybox.System;

// utility class to help with watch vibration, backlight, sounds
class Notify {
	static function vibrate(how) {
	    if (Attention has :vibrate && System.getDeviceSettings().vibrateOn) {
	        var vibrateData = [
	            new Attention.VibeProfile(  25, 100 ),
	            new Attention.VibeProfile(  50, 100 ),
	            new Attention.VibeProfile(  25, 100 ),
	            new Attention.VibeProfile(  50, 100 ),
	            new Attention.VibeProfile(  25, 100 ),
	            new Attention.VibeProfile(  50, 100 )
          	];
	        Attention.vibrate(vibrateData);
        }
	}
	static function enableBacklight() {
		if (Attention has :backlight) {
			Attention.backlight(true);
		}
	}
	static function disableBacklight() {
		if (Attention has :backlight) {
			Attention.backlight(false);
		}
	}
}

// vi:syntax=javascript filetype=javascript