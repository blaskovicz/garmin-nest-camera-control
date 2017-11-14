using Toybox.Attention;

// utility class to help with watch vibration, backlight, sounds
class Notify {
	static function vibrate(how) {
	    if (Attention has :vibrate) {
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