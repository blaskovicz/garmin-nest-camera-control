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
}