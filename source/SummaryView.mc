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
    	}
    }
}
   
class SummaryView extends BaseLayoutView {
    function initialize() {
    	self.ref = "summary-view";
        BaseLayoutView.initialize();
    }

    function onUpdate(dc) {
    	if(BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
    	self.drawSummary(dc);
    }
    
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
    		var onlineCount = 0;
    		var streamCount = 0;
    		for (var i = 0; i < cameraList.size(); i++) {
    			var item = cameraList[i];
    			if (item["is_online"]) {
    				onlineCount++;
    			}
    			if (item["is_streaming"]) {
    				streamCount++;
    			}
    		}
    		if (onlineCount != cameraList.size()) {
    			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    		} else {
    			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
    		}
    		
    		// online means connected to nest cloud, streaming means digitally taking pictures
    		dc.drawText(self.width/2, self.offsetY+2*fontTinyHeight, Graphics.FONT_SMALL, Lang.format("$1$/$2$ Online", [onlineCount, cameraList.size()]), Graphics.TEXT_JUSTIFY_CENTER);
    		dc.drawText(self.width/2, self.offsetY+3*fontTinyHeight, Graphics.FONT_SMALL, Lang.format("$1$/$2$ Live", [streamCount, cameraList.size()]), Graphics.TEXT_JUSTIFY_CENTER);
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
