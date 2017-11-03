using Toybox.Application as App;
using Toybox.Time;

static class Properties {
	static function getApp() {
		return App.getApp();
	}
	static function setNestAccessToken(token) {
		return getApp().setProperty("access_token", token);
	}
	static function getNestAccessToken() {
		return getApp().getProperty("access_token");
	}
	static function connectedToNest() {
		return getNestAccessToken() != null;
	}
	static function getCachedCameraState() {
		var state = getApp().getProperty("camera_state");
		if (state == null) {
			return null;
		}
		return null;
		// TODO decode time & data
		//return [];
	}
	static function setCachedCameraState(fetchTime, cameraInfoList) {
		if (fetchTime == null || cameraInfoList == null || cameraInfoList.size() == 0) {
			return;
		}
		/*
		var cameraListEncoded = "[";
		for (var i = 0; i < self.cameraList.size(); i++) {
			var item = self.cameraList[i];
			
		}
		cameraListEncoded += "]";
		var state = getApp().setProperty(
			"camera_state",
			Lang.format("fetch_time=$1$&camera_list=$2$", [fetchTime.value(), cameraListEncoded])
		);*/
	}
}