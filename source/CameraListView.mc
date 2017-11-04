using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Communications as Comm;
using Toybox.Lang;

class CameraListDelegate extends Ui.BehaviorDelegate {
	protected var listUi;
	protected var page;
    function initialize(listUi) {
    	Logger.getInstance().info("ref=camera-list-delegate at=initialize");
    	self.listUi = listUi;
    	self.page = 0;
        BehaviorDelegate.initialize();
    }
    
    function onKey(ev) {
        var key = ev.getKey();
        Logger.getInstance().infoF("ref=camera-list-delegate at=on-key key=$1$", [key]);
        if (key == Ui.KEY_START || key == Ui.KEY_ENTER) {
			var camera = NestApi.getInstance().getCameraList()[self.page];
			NestApi.getInstance().requestToggleStreaming(camera);
        } else if (key == Ui.KEY_DOWN) {
            return onNextPage();
        } else if (key == Ui.KEY_UP) {
            return onPreviousPage();
        }
    }
    
    function onPreviousPage() {
    	if (self.page == 0) {
    		return;    
    	}
    	self.page = self.page - 1;
    	self.listUi.setPage(self.page);
    }

    function onNextPage() {
    	if (!NestApi.getInstance().hasCameras() || NestApi.getInstance().getCameraList().size()-1 == self.page) {
    		return;
    	}
    	self.page = self.page + 1;
    	self.listUi.setPage(self.page);
    }
}

class CameraListView extends Ui.View {
	protected var width;
	protected var height;
	protected var errorState;
	protected var page;

    function initialize() {
   		Logger.getInstance().info("ref=camera-list-view at=initialize");
   		self.page = 0;
        View.initialize();
    }

    function onShow() {
    	Logger.getInstance().info("ref=camera-list-view at=on-show");
    }
    
    function setPage(page) {
    	self.page = page;
    	Ui.requestUpdate();
    }

    function onUpdate(dc) {
    	Logger.getInstance().info("ref=camera-list-view at=on-update");
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    	
    	dc.drawLine(0, fontTinyHeight*2, width, fontTinyHeight*2);
    	dc.drawText(self.width/2, fontTinyHeight, Graphics.FONT_TINY, "Garmin Nest", Graphics.TEXT_JUSTIFY_CENTER);
    	
    	if (NestApi.getInstance().getErrorState() != null) {
	    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(self.width/2, fontTinyHeight*3, Graphics.FONT_TINY, NestApi.getInstance().getErrorState(), Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
			self.drawCameraList(dc, fontTinyHeight*2);
		}	
    	return true;      	
	}
	
	function drawCameraList(dc, yOffset) {
    	var cameraList = NestApi.getInstance().getCameraList();
    	if (!NestApi.getInstance().hasCameras()) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_SMALL, "No cameras found.", Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
    		// divide remaining space up into 5 parts; 70% for 3 camera rows, 30% for page selectors
    		var selectHeight = ((self.height - yOffset)/100 * 30)/2;
    		
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		
    		// scroll up
    		if (self.page != 0) {
    			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	    		dc.fillPolygon([
	    			[self.width/2, yOffset + 10],
	    			[self.width/2 - selectHeight/2, yOffset + selectHeight + 10],
	    			[self.width/2 + selectHeight/2, yOffset + selectHeight + 10]
	    		]);
    		}
    		
    		// selectable rows
    		yOffset = yOffset + selectHeight + 10;
    		var rowHeight = (self.height - selectHeight - 10 - yOffset)/3;
    		for (var i = self.page; i < cameraList.size() && i < self.page+3; i++) {
    			var j = i - self.page;
    			var camera = cameraList[i];
    			var currentOffset = yOffset - 10 + rowHeight*(j+1);
    			if (j != 0) {
    				dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    			} else {
    				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    			}
    			dc.drawText(self.width/2, currentOffset-rowHeight/2-10, Graphics.FONT_TINY, (camera["is_streaming"] ? "(live) " : "") + camera["name"], Graphics.TEXT_JUSTIFY_CENTER);
	    		dc.drawLine(0, currentOffset, width, currentOffset);
	    	}

    		// scroll down
    		if (self.page != cameraList.size()-1) {
    			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	    		dc.fillPolygon([
	    			[self.width/2 - selectHeight/2, self.height - selectHeight - 10],
	    			[self.width/2 , self.height - 10],			
	    			[self.width/2 + selectHeight/2, self.height  - selectHeight - 10]
	    		]);
	    	}
    	}
    }

    function onHide() {
    	Logger.getInstance().info("ref=camera-list-view at=on-hide");
    	NestApi.getInstance().clearErrorState();
    }
}