using Toybox.Application as App;
using Toybox.Time;
using Toybox.Lang;

// TODO migration strategy if data changes, maybe namespace like /v1, /v1/access_token
static class Properties {
	static function getApp() {
		return App.getApp();
	}
	static function setNestAccessToken(token) {
		if (!(token instanceof Lang.String)) {
			throw new InvalidArgumentError("expected access_token to be Toybox.Lang.String");
		}
		Logger.getInstance().info("ref=properties at=set-nest-access-token");
		getApp().setProperty("access_token", token);
	}
	static function clearAll() {
		Logger.getInstance().warn("ref=properties at=clear-all");
		getApp().clearProperties();
	}
	static function getNestAccessToken() {
		return getApp().getProperty("access_token");
	}
	static function connectedToNest() {
		return getNestAccessToken() != null;
	}
	static function getCameraList() {
		var cameraList = getApp().getProperty("camera_list");
		if (cameraList == null) {
			return null;
		}
		Logger.getInstance().info("ref=properties at=get-camera-list");
		return cameraList;
	}
	static function setCameraList(cameraList) {
		if (!(cameraList instanceof Lang.Array)) {
			throw new InvalidArgumentError("expected camera_list to be Toybox.Lang.Array");
		}
		for(var i = 0; i < cameraList.size(); i++) {
			if(!(cameraList[i] instanceof Lang.Dictionary)) {
				throw new InvalidArgumentError(Lang.format("expected camera_list[$1$] to be Toybox.Lang.Dictionary", [i]));
			}
		}
		Logger.getInstance().info("ref=properties at=set-camera-list");
		getApp().setProperty("camera_list", cameraList);
	}
	static function getCamerasUpdatedAt() {
		var time = getApp().getProperty("cameras_updated_at");
		if (time == null) {
			return null;
		}
		Logger.getInstance().info("ref=properties at=get-cameras-updated-at");
		return new Time.Moment(time);
	}
	static function setCamerasUpdatedAt(time) {
		if (!(time instanceof Time.Moment)) {
			throw new InvalidArgumentError("expected cameras_updated_at to be Toybox.Time.Moment");
		}
		Logger.getInstance().info("ref=properties at=set-cameras-updated-at");
		getApp().setProperty("cameras_updated_at", time.value());
	}
}

// vi:syntax=javascript filetype=javascript