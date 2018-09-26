using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Communications as Comm;
using Toybox.System;
using Constants;

class SummaryDelegate extends Ui.BehaviorDelegate {
	protected var summaryUi;
    function initialize(summaryUi) {
    	Logger.getInstance().info("ref=summary-delegate at=initialize");
    	self.summaryUi = summaryUi;
        BehaviorDelegate.initialize();
    }

    function onKey(ev) {
        var key = ev.getKey();
        if (Ui.KEY_START != key && Ui.KEY_ENTER != key) {
        	return false;
        }

    	Logger.getInstance().info("ref=summary-delegate at=on-ok");
    	if (!NestApi.getInstance().isConnected()) {
    		NestApi.getInstance().requestOauthConnect();
    		return true;
    	} else if (NestApi.getInstance().hasCameras()) {
    		var view = new CameraListView();
    		Ui.pushView(view, new CameraListDelegate(view), Ui.SLIDE_LEFT);
    		return true;
    	} else {
    		NestApi.getInstance().requestCameraStatus();
    	}
    	return false;
    }
}
   
class SummaryView extends BaseLayoutView {
	protected var iconTimes;
	protected var iconCheck;
	protected var iconExclamation;
	protected var iconPhone;
	protected var iconRefresh;

    function initialize() {
    	self.ref = "summary-view";
        BaseLayoutView.initialize();
    }
    
    function onLayout(dc) {
    	if (BaseLayoutView.onLayout(dc)) {
    		return true;
    	}
    	self.iconTimes = Ui.loadResource(Rez.Drawables.times16);
    	self.iconCheck = Ui.loadResource(Rez.Drawables.check16);
    	self.iconExclamation = Ui.loadResource(Rez.Drawables.exclamationtriangle16);
    	self.iconPhone = Ui.loadResource(Rez.Drawables.phonesquare16);
    	self.iconRefresh = Ui.loadResource(Rez.Drawables.refresh16);
    	//return self.onUpdate(dc);
    	return true;
    }
    
    function onUpdate(dc) {
    	if(BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
    	return self.drawSummary(dc);
    }
    
    function drawSummary(dc) {
    	if (NestApi.getInstance().isConnected()) {
    		self.drawCameraInfo(dc);
    	} else {
	    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, self.offsetY + Constants.HEIGHT_FONT_TINY, Graphics.FONT_MEDIUM, "Not connected.", Graphics.TEXT_JUSTIFY_CENTER);
			
			dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, self.offsetY + Constants.HEIGHT_FONT_TINY*3, Graphics.FONT_TINY, "Press 'OK' to connect.", Graphics.TEXT_JUSTIFY_CENTER);
		}
		return true;
    }
    
    function drawCameraInfo(dc) {
    	var cameraList = NestApi.getInstance().getCameraList();
    	var camerasUpdatedAt = NestApi.getInstance().getCamerasUpdatedAt();
    	if (!NestApi.getInstance().hasCameras()) {
	    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, self.offsetY + Constants.HEIGHT_FONT_TINY, Graphics.FONT_TINY, "No cameras found.\nAre you the\nNest Home owner?", Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, self.offsetY, Graphics.FONT_SMALL, "Camera Status:", Graphics.TEXT_JUSTIFY_CENTER);
    		
    		var status = {"Online" => 0, "Live" => 0};
    		for (var i = 0; i < cameraList.size(); i++) {
    			var item = cameraList[i];
    			if (item["is_online"]) {
    				status["Online"]++;
    			}
    			if (item["is_streaming"]) {
    				status["Live"]++;
    			}
    		}
    		
    		// online means connected to nest cloud, streaming means digitally taking pictures
    		var statuses = status.keys();
    		for (var i = 0; i < statuses.size(); i++) {
    			var icon;
    			var statusText;
    			var statusKey = statuses[i];
    			
	    		if (status[statusKey] != cameraList.size()) {
	    			icon = self.iconTimes;
	    			// eg: 1 of 2 online
		    		statusText = Lang.format(
	    				"$1$ of $2$ $3$",
	    				[status[statusKey], cameraList.size(), statusKey]
	    			);
	    			dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
	    		} else {
	    			icon = self.iconCheck;
	    			// eg: 1 online
		    		statusText = Lang.format(
	    				"$1$ $2$",
	    				[status[statusKey], statusKey]
	    			);
	    			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
	    		}

	    		var textDimensions = dc.getTextDimensions(statusText, Graphics.FONT_SMALL);
    			var iconOffsetX = textDimensions[0] / 2 + 16 + 5;
    			var iconOffsetY = (textDimensions[1] - 16)/ 2;
    			var currentOffsetY = self.offsetY + (i+2)*Constants.HEIGHT_FONT_TINY;
    			
    			dc.drawBitmap(self.width/2 - iconOffsetX, currentOffsetY + iconOffsetY, icon);
	    		dc.drawText(
	    			self.width/2,
	    			currentOffsetY,
	    			Graphics.FONT_SMALL,
	    			statusText,
	    			Graphics.TEXT_JUSTIFY_CENTER
	    		);
    		}
   		}
    	
    	if (camerasUpdatedAt != null) {
	    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
	    	var deltaSeconds = Time.now().subtract(camerasUpdatedAt).value();
	    	// hours, mins, seconds
	    	var hours = 0;
	    	while(deltaSeconds >= 3600) { // seconds per hour
	    		deltaSeconds -= 3600;
	    		hours++;
	    	}
	    	var mins = 0; 
	    	while(deltaSeconds >= 60) { // seconds per min
	    		deltaSeconds -= 60;
	    		mins++;
	    	}
	    	// deltaSeconds is now leftover seconds
	    	var updateText = "";
	    	if (hours > 0) {
	    		updateText = updateText + hours.format("%d") + "h";
	    	} else if (mins > 0) {
	    		updateText = updateText + mins.format("%d") + "m";
	    	} else if (deltaSeconds > 30) {
	    		updateText = updateText + deltaSeconds.format("%d") + "s";
	    	}

	    	if (updateText.equals("")) {
	    		updateText = "just now";
	    	} else {
	    		updateText = updateText + " ago";
	    	}
	    	
    		var textDimensions = dc.getTextDimensions(updateText, Graphics.FONT_XTINY);
			var iconOffsetX = textDimensions[0] / 2 + 16 + 5;
			var iconOffsetY = (textDimensions[1] - 16)/ 2;
	    	dc.drawBitmap(self.width/2 - iconOffsetX, iconOffsetY + self.height - Constants.HEIGHT_FONT_TINY*2, self.iconRefresh);
	    	dc.drawText(
	    		self.width/2,
	    		self.height - Constants.HEIGHT_FONT_TINY*2,
	    		Graphics.FONT_XTINY,
	    		updateText, 
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
		if (!System.getDeviceSettings().phoneConnected) {
	    	dc.drawBitmap(self.width/2-16, self.height-25, self.iconPhone);
	    	dc.drawBitmap(self.width/2, self.height-25, self.iconExclamation);
		} else {
	    	var currentState = NestApi.getInstance().getPollerState();
	    	if (currentState != null && currentState[:state] == NestApi.StateRequesting) {
	    		dc.drawBitmap(self.width/2-8, self.height-25, self.iconPhone);
	    	}
	    }
    }
}

// vi:syntax=javascript filetype=javascript