using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Communications as Comm;

var fontTinyHeight = Graphics.getFontHeight(Graphics.FONT_TINY);

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
    	} else if (NestApi.getInstance().hasCameras()) {
    		var view = new CameraListView();
    		Ui.pushView(view, new CameraListDelegate(view), Ui.SLIDE_IMMEDIATE);
    	}
    }
}
   
class SummaryView extends Ui.View {
	protected var width;
	protected var height;

    function initialize() {
   		Logger.getInstance().info("ref=summary-view at=initialize");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
   		//Logger.getInstance().info("ref=summary-view at=on-layout");    
        //setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	Logger.getInstance().info("ref=summary-view at=on-show");
    	//var cachedState = Properties.getCachedCameraState();
    	//if (cachedState != null && cachedState.size() == 2) {
    	//	self.camerasUpdatedAt = cachedState[0];
    	//	self.cameraList = cachedState[1];
    	//}
		/* var message = "Continue?";
		var dialog = new Ui.Confirmation(message);
		Ui.pushView(
		    dialog,
		    new ConfirmationDelegate(),
		    WatchUi.SLIDE_IMMEDIATE
		);*/
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
    	Logger.getInstance().info("ref=summary-view at=on-update");
    	self.drawSummary(dc);
    }
    
    function drawSummary(dc) {
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	 
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    	
    	dc.drawLine(0, fontTinyHeight*2, self.width, fontTinyHeight*2);
    	dc.drawText(self.width/2, fontTinyHeight, Graphics.FONT_TINY, "Garmin Nest", Graphics.TEXT_JUSTIFY_CENTER);
    	
    	if (NestApi.getInstance().getErrorState() != null) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, fontTinyHeight*3, Graphics.FONT_TINY, NestApi.getInstance().getErrorState(), Graphics.TEXT_JUSTIFY_CENTER);		
    	} else {
	    	if (NestApi.getInstance().isConnected()) {
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
    	var cameraList = NestApi.getInstance().getCameraList();
    	var camerasUpdatedAt = NestApi.getInstance().getCamerasUpdatedAt();
    	if (!NestApi.getInstance().hasCameras()) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_SMALL, "No cameras found.", Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_SMALL, "Camera Status:", Graphics.TEXT_JUSTIFY_CENTER);
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
    		dc.drawText(self.width/2, yOffset+2*fontTinyHeight, Graphics.FONT_SMALL, Lang.format("$1$/$2$ Online", [onlineCount, cameraList.size()]), Graphics.TEXT_JUSTIFY_CENTER);
    		dc.drawText(self.width/2, yOffset+3*fontTinyHeight, Graphics.FONT_SMALL, Lang.format("$1$/$2$ Live", [streamCount, cameraList.size()]), Graphics.TEXT_JUSTIFY_CENTER);
    	}
    	
    	if (camerasUpdatedAt != null) {
	    	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
	    	var t = Gregorian.info(camerasUpdatedAt, Time.FORMAT_SHORT);
	    	dc.drawText(
	    		self.width/2,
	    		self.height - 2*Graphics.getFontHeight(Graphics.FONT_TINY),
	    		Graphics.FONT_XTINY,
	    		Lang.format("Updated $1$:$2$:$3$", [t.hour.format("%02d"), t.min.format("%02d"), t.sec.format("%02d")]), 
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
    }
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	Logger.getInstance().info("ref=summary-view at=on-hide");
    	NestApi.getInstance().clearErrorState();
    	//Properties.setCachedCameraState(self.camerasUpdatedAt, self.cameraList);
    }
}
