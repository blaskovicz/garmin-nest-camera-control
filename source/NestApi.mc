using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Time.Gregorian;
using Toybox.Communications as Comm;

var _api;

// Singleton NestApi:
//
// Delegate.onAction:
//	 NestApi.getInstance().doThing(args...)
// View.onUpdate:
//	 if (NestApi.getInstance().getErrorState() != null) {
//  	render error...
//	 } else {
//		render camera info...
//   }

// TODO: buffer, splay and retry request to handle BLE QUEUE FULL error (code -101)
static class NestApi {
	protected var camerasUpdatedAt;
	protected var timerStarted;
	protected var timer;
	protected var cameraList;
	protected var errorState;
	protected var connecting;
	static function getInstance() {
		if (_api == null) {
			_api = new NestApi();
		}
		return _api;
	}

	function initialize() {
		Logger.getInstance().info("ref=nest-api at=initialize");
		Comm.registerForOAuthMessages(self.method(:onOauthResponsePhase1));
		self.timerStarted = false;
		self.requestCameraStatus();
	}
	
	function getErrorState() {
		return self.errorState;
	}

    function requestCameraStatus() {
    	// if we haven't reach at least 1 minute from our last update, wait.
    	var now = Time.now();
    	var accessToken = Properties.getNestAccessToken();
    	if (accessToken == null || (self.camerasUpdatedAt != null && now.lessThan(self.camerasUpdatedAt.add(Gregorian.duration({:minutes => 1}))))) {
    		return;
    	}
    	Logger.getInstance().info("ref=nest-api at=request-camera-status");

    	self.errorState = null;
    	self.camerasUpdatedAt = now;    	
        Comm.makeWebRequest(
            "https://developer-api.nest.com/devices/cameras",
            null,
            {
            	:method => Comm.HTTP_REQUEST_METHOD_GET,
            	:headers => {
            		"Authorization" => Lang.format("Bearer $1$", [accessToken])
            	}
            },
        	self.method(:onCameraListResponse)
    	);
    }
    
    function onCameraListResponse(responseCode, data) {
    	Logger.getInstance().infoF("ref=nest-api at=on-camera-list-response response-code='$1$' data='$2$'", [responseCode, data]);
    	if (responseCode != 200) {
    		self.errorState = Lang.format("Failed to get cameras:\nCode $1$.", [responseCode]);
    	} else {
    		self.cameraList = data.values();
    	}
        Ui.requestUpdate();   	
    }
    
    function requestToggleStreaming(camera) {
    	var accessToken = Properties.getNestAccessToken();
    	if (accessToken == null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=nest-api at=request-toggle-streaming camera=$1$ to=$2$", [camera["device_id"], !camera["is_streaming"]]);    	
        Comm.makeWebRequest(
            Lang.format("https://developer-api.nest.com/devices/cameras/$1$", [camera["device_id"]]),
            { "is_streaming" => !camera["is_streaming"] }, // TODO verify this works on a real device - https://forums.garmin.com/forum/developers/connect-iq/145494
            {
            	:method => Comm.HTTP_REQUEST_METHOD_PUT,
            	:headers => {
            		"Authorization" => Lang.format("Bearer $1$", [accessToken]),
            		"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
            	}
            },
        	self.method(:onCameraEnableStreamingResponse)
    	);    
    }

    function onCameraEnableStreamingResponse(responseCode, data) {
    	Logger.getInstance().infoF("ref=nest-api at=on-camera-enable-streaming-response response-code='$1$' data='$2$'", [responseCode, data]);
    	if (responseCode != 200) {
    		self.errorState = Lang.format("Failed to update camera:\nCode $1$.", [responseCode]);
    	} else {
    		self.errorState = null;
    	}
    	Ui.requestUpdate();
    }

    function getCameraList() {
    	return self.cameraList;
    }
    
    function hasCameras() {
    	return self.cameraList != null && self.cameraList.size() > 0;
    }
    
    function getCamerasUpdatedAt() {
    	return self.camerasUpdatedAt;
    }
    
    function isConnected() {
    	return Properties.connectedToNest();
    }

    function startTimer() {
    	if (self.timerStarted) {
    		return;
    	}
    	Logger.getInstance().info("ref=nest-api at=start-timer");    	
    	self.timerStarted = true;
    	self.timer = new Timer.Timer();
    	self.timer.start(self.method(:requestCameraStatus), 60000, true);
    }
    
    function stopTimer() {
    	if (self.timer == null || !self.timerStarted) {
    		return;
		}
		Logger.getInstance().info("ref=nest-api at=stop-timer");
    	self.timer.stop();
    }
    
    // oauth flow based on https://github.com/garmin/connectiq-apps/blob/1a7588e4c85726518c6744213516c9988ebdf45e/apps/strava-api/source/StravaLogin.mc
    function requestOauthConnect() {
    	if (self.connecting) {
    		return;
    	}    	
    	Logger.getInstance().info("ref=nest-api at=request-oauth-connect");
    	self.connecting = true;
    	self.errorState = null;
    	Comm.makeOAuthRequest(
    		"https://home.nest.com/login/oauth2",
    		{
	    		//"scope" => "public",
	    		"redirect_uri" => "https://localhost",
	    		//"response_type" => "code",
	    		"client_id" => "",
	    		"state" => "TODO"
	    	},
    		"https://localhost",
    		Comm.OAUTH_RESULT_TYPE_URL,
    		// params in redirect, mapped to keys in response dictionary
    		{"code" => "code", "error" => "error", "state" => "state"}
    	);
    }

    // resp.responseCode non-http statuses documented in
    // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Communications.html
    function onOauthResponsePhase1(resp) {
    	if (!self.connecting) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=nest-api at=on-oauth-response-phase-1 response-code='$1$' data='$2$'", [resp.responseCode, resp.data]);
    	if (resp.data != null && resp.data["code"] != null && "TODO".equals(resp.data["state"])) {
    		self.requestAccessToken(resp.data["code"]);
    	} else if (resp.responseCode > 0) {
    		self.connecting = false;
    		self.errorState = Lang.format("Failed to authorize:\nCode $1$.", [resp.responseCode]);
    		Ui.requestUpdate();
    	}
    }

    function requestAccessToken(code) {
    	Logger.getInstance().infoF("ref=nest-api at=request-access-token code='$1$'", [code]);
        Comm.makeWebRequest(
            "https://api.home.nest.com/oauth2/access_token",
            {
            	"grant_type" => "authorization_code",
            	"redirect_uri" => "https://localhost",
            	"client_secret" => "",
            	"client_id" => "",
            	"code" => code
            },
            {
            	:method => Comm.HTTP_REQUEST_METHOD_POST
            },
        	self.method(:onOauthResponsePhase2)
    	);
    }

    function onOauthResponsePhase2(responseCode, data) {
    	Logger.getInstance().infoF("ref=nest-api at=on-oauth-response-phase-2 response-code='$1$' data='$2$'", [responseCode, data]);
        self.connecting = false;
        if(data != null) {
        	// TODO need to worry about if this gets revoked or needs a refresh for v2
		    Properties.setNestAccessToken(data["access_token"]);
		    self.requestCameraStatus();
        } else {
        	self.errorState = Lang.format("Failed to generate token:\nCode $1$.", [responseCode]);
        }
	    Ui.requestUpdate();        
    }
    
    function clearErrorState() {
    	self.errorState = null;    
    }
}
		