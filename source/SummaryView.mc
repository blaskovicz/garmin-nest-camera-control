using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Communications as Comm;

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
        	return;
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
    }
}
   
class SummaryView extends BaseLayoutView {
	protected var iconTimes;
	protected var iconCheck;
    function initialize() {
    	self.ref = "summary-view";
        BaseLayoutView.initialize();
    }

    function onShow() {
    	BaseLayoutView.onShow();
    	self.iconTimes = Ui.loadResource(Rez.Drawables.times16);
    	self.iconCheck = Ui.loadResource(Rez.Drawables.check16);
    }

    function onUpdate(dc) {
    	if(BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
    	self.drawSummary(dc);
    }
    
    // TODO: render an error if we can't contact the nest api
    function drawSummary(dc) {
    	if (NestApi.getInstance().isConnected()) {
    		self.drawCameraInfo(dc);
    	} else {
	    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, self.offsetY + fontTinyHeight, Graphics.FONT_MEDIUM, "Not connected.", Graphics.TEXT_JUSTIFY_CENTER);
			
			dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, self.offsetY + fontTinyHeight*3, Graphics.FONT_TINY, "Press 'OK' to connect.", Graphics.TEXT_JUSTIFY_CENTER);
		}
    }
    
    function drawCameraInfo(dc) {
    	var cameraList = NestApi.getInstance().getCameraList();
    	var camerasUpdatedAt = NestApi.getInstance().getCamerasUpdatedAt();
    	if (!NestApi.getInstance().hasCameras()) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, self.offsetY, Graphics.FONT_SMALL, "No cameras found.", Graphics.TEXT_JUSTIFY_CENTER);
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
    			
	    		if (status[statuses[i]] != cameraList.size()) {
	    			icon = self.iconTimes;
	    			// eg: 1 of 2 online
		    		statusText = Lang.format(
	    				"$1$ of $2$ $3$",
	    				[status[statuses[i]], cameraList.size(), statuses[i]]
	    			);
	    			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	    		} else {
	    			icon = self.iconCheck;
	    			// eg: 1 online
		    		statusText = Lang.format(
	    				"$1$ $2$",
	    				[status[statuses[i]], statuses[i]]
	    			);
	    			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
	    		}

    			
	    		var textDimensions = dc.getTextDimensions(statusText, Graphics.FONT_SMALL);
    			var iconOffsetX = textDimensions[0] / 2 + 16 + 5;
    			var iconOffsetY = (textDimensions[1] - 16)/ 2;
    			var currentOffsetY = self.offsetY + (i+2)*fontTinyHeight;
    			
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
	    	var t = Gregorian.info(camerasUpdatedAt, Time.FORMAT_SHORT);
	    	dc.drawText(
	    		self.width/2,
	    		self.height - fontTinyHeight*2,
	    		Graphics.FONT_XTINY,
	    		Lang.format("Updated $1$:$2$:$3$", [t.hour.format("%02d"), t.min.format("%02d"), t.sec.format("%02d")]), 
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
    }
}
