using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Time.Gregorian;
using Toybox.Communications as Comm;

var fontTinyHeight = Graphics.getFontHeight(Graphics.FONT_TINY);

class SummaryDelegate extends Ui.BehaviorDelegate {
	protected var summaryUi;
	protected var connecting;
    function initialize(summaryUi) {
    	Logger.getInstance().info("ref=sumary-delegate at=initialize");
    	self.summaryUi = summaryUi;
    	self.connecting = false;
        BehaviorDelegate.initialize();
        Comm.registerForOAuthMessages(self.method(:onOauthResponsePhase1));
    }

    function onKey(ev) {
        var key = ev.getKey();
        if (Ui.KEY_START != key && Ui.KEY_ENTER != key) {
        	return;
        }

    	Logger.getInstance().info("ref=sumary-delegate at=on-ok");
    	if (!Properties.connectedToNest()) {
    		self.connectToNest();
    	} else {
    		// Ui.pushView(new CameraListView(
    	}
    }

    // oauth flow based on https://github.com/garmin/connectiq-apps/blob/1a7588e4c85726518c6744213516c9988ebdf45e/apps/strava-api/source/StravaLogin.mc
    function connectToNest() {
    	if (self.connecting) {
    		return;
    	}    	
    	Logger.getInstance().info("ref=sumary-delegate at=connect-to-nest");
    	self.connecting = true;
    	self.summaryUi.setErrorState(null);
    	Comm.makeOAuthRequest(
    		"https://app75514099.auth0.com/authorize",
    		{
	    		"scope" => "public",
	    		"redirect_uri" => "https://localhost",
	    		"response_type" => "code",
	    		"client_id" => ""
	    	},
    		"https://localhost",
    		Comm.OAUTH_RESULT_TYPE_URL,
    		// params in redirect, mapped to keys in response dictionary
    		{"code" => "code", "error" => "error"}
    	);
    }

    // resp.responseCode non-http statuses documented in
    // https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/Communications.html
    function onOauthResponsePhase1(resp) {
    	if (!self.connecting) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=sumary-delegate at=on-oauth-response-phase-1 response-code='$1$' data='$2$'", [resp.responseCode, resp.data]);
    	if (resp.data != null && resp.data["code"] != null) {
    		self.requestAccessToken(resp.data["code"]);
    	} else if (resp.responseCode > 0) {
    		self.connecting = false;
    		self.summaryUi.setErrorState(Lang.format("Failed to authorize:\nCode $1$.", [resp.responseCode]));
    	}
    }

    function requestAccessToken(code) {
    	Logger.getInstance().infoF("ref=sumary-delegate at=request-access-token code='$1$'", [code]);
        Comm.makeWebRequest(
            "https://app75514099.auth0.com/oauth/token",
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
    	Logger.getInstance().infoF("ref=sumary-delegate at=on-oauth-response-phase-2 response-code='$1$' data='$2$'", [responseCode, data]);
        self.connecting = false;
        if(data != null) {
            Properties.setNestAccessToken(data["access_token"]); // TODO need to worry about if this guy gets revoked or needs a refresh: v2
            self.summaryUi.requestUpdate();
        } else {
        	self.summaryUi.setErrorState(Lang.format("Failed to generate token:\nCode $1$.", [responseCode]));
        }
    }    
}
   
class SummaryView extends Ui.View {
	protected var width;
	protected var height;
	protected var errorState;
	protected var cameraList; 
	protected var camerasUpdatedAt;
	protected var accessToken;
	protected var timer;

    function initialize() {
   		Logger.getInstance().info("ref=sumary-view at=initialize");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
   		Logger.getInstance().info("ref=sumary-view at=on-layout");    
        //setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	Logger.getInstance().info("ref=sumary-view at=on-show");
    	var cachedState = Properties.getCachedCameraState();
    	if (cachedState != null && cachedState.size() == 2) {
    		self.camerasUpdatedAt = cachedState[0];
    		self.cameraList = cachedState[1];
    	}
    	self.startUpdater();
		/* var message = "Continue?";
		var dialog = new Ui.Confirmation(message);
		Ui.pushView(
		    dialog,
		    new ConfirmationDelegate(),
		    WatchUi.SLIDE_IMMEDIATE
		);*/
    }
    
    function setErrorState(error) {
    	self.errorState = error;
    	Ui.requestUpdate();
    }

    // Update the view
    function onUpdate(dc) {
    	// views:
    	// 1) not connected to nest
    	// 2) camera summary
    	// 3) camera list
    	// 4) toggle camera
    	// 5) loading
    	// 6) error
    	Logger.getInstance().info("ref=sumary-view at=on-update");
    	self.drawSummary(dc);
    }
    
    function drawSummary(dc) {
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	 
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    	
    	dc.drawLine(0, fontTinyHeight*2, width, fontTinyHeight*2);
    	dc.drawText(self.width/2, fontTinyHeight, Graphics.FONT_TINY, "Garmin Nest", Graphics.TEXT_JUSTIFY_CENTER);
    	
    	if (self.errorState != null) {
	    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, fontTinyHeight*3, Graphics.FONT_TINY, self.errorState, Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
	    	if (Properties.connectedToNest()) {
	    		self.requestCameraStatus();
	    		self.drawCameraInfo(dc, fontTinyHeight*2);
	    	} else {
		    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
				dc.drawText(self.width/2, fontTinyHeight*3, Graphics.FONT_MEDIUM, "Not connected.", Graphics.TEXT_JUSTIFY_CENTER);
				
				dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
				dc.drawText(self.width/2, fontTinyHeight*5, Graphics.FONT_TINY, "Press 'OK' to connect.", Graphics.TEXT_JUSTIFY_CENTER);
			}
		}	
    	return true;    	
    }
    
    function drawCameraInfo(dc, yOffset) {
    	if (self.cameraList == null || self.cameraList.size == 0) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_MEDIUM, "No cameras found.", Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_MEDIUM, "Camera Status:", Graphics.TEXT_JUSTIFY_CENTER);
    		var onlineCount = 0;
    		for (var i = 0; i < self.cameraList.size(); i++) {
    			var item = self.cameraList[i];
    			if (item["online"]) {
    				onlineCount++;
    			}
    		}
    		if (onlineCount != self.cameraList.size) {
    			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    		} else {
    			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
    		}
    		dc.drawText(self.width/2, yOffset+2*fontTinyHeight, Graphics.FONT_MEDIUM, Lang.format("$1$/$2$ Online", [onlineCount, self.cameraList.size()]), Graphics.TEXT_JUSTIFY_CENTER);
    	}
    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    	var t = Gregorian.info(self.camerasUpdatedAt, Time.FORMAT_SHORT);
    	dc.drawText(
    		self.width/2,
    		self.height - 2*Graphics.getFontHeight(Graphics.FONT_TINY),
    		Graphics.FONT_XTINY,
    		Lang.format("Updated $1$:$2$:$3$", [t.hour.format("%02d"), t.min.format("%02d"), t.sec.format("%02d")]), 
			Graphics.TEXT_JUSTIFY_CENTER
		);
    }
    
    function requestCameraStatus() {
    	// if we haven't reach at least 1 minute from our last update, wait.
    	var now = Time.now();
    	var accessToken = Properties.getNestAccessToken();
    	if (accessToken == null || (self.camerasUpdatedAt != null && now.lessThan(self.camerasUpdatedAt.add(Gregorian.duration({:minutes => 1}))))) {
    		return;
    	}
    	Logger.getInstance().info("ref=sumary-view at=request-camera-status");

    	self.errorState = null;
    	self.camerasUpdatedAt = now;    	
        Comm.makeWebRequest(
            "https://jsonbin.io/b/59fbcbc79e2ce4576af3eb88",
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
    	Logger.getInstance().infoF("ref=sumary-view at=on-camera-list-response response-code='$1$' data='$2$'", [responseCode, data]);
    	if (responseCode != 200) {
    		self.setErrorState(Lang.format("Failed to get cameras:\nCode $1$.", [responseCode]));
    		return;
    	}
    	self.cameraList = data;
        Ui.requestUpdate();   	
    }
    
    function startUpdater() {
    	self.timer = new Timer.Timer();
    	self.timer.start(self.method(:requestCameraStatus), 60000, true);
    }
    
    function stopUpdater() {
    	if (self.timer == null) {
    		return;
		}
    	self.timer.stop();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	Logger.getInstance().info("ref=sumary-view at=on-hide");
    	self.stopUpdater();
    	Properties.setCachedCameraState(self.camerasUpdatedAt, self.cameraList);
    }
}
