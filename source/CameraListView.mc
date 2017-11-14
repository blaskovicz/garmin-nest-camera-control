using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Communications as Comm;
using Toybox.Lang;
using Env;

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
        return false;
    }
    
    function onPreviousPage() {
    	if (self.page == 0) {
    		return true;
    	}
    	self.page = self.page - 1;
    	self.listUi.setPage(self.page);
    	return true;
    }

    function onNextPage() {
    	if (!NestApi.getInstance().hasCameras() || NestApi.getInstance().getCameraList().size()-1 == self.page) {
    		return true;
    	}
    	self.page = self.page + 1;
    	self.listUi.setPage(self.page);
    	return true;
    }
}

class CameraListView extends BaseLayoutView {
	protected var page;
	protected var iconTimes;
	protected var iconCheck;
    function initialize() {
   		self.ref = "camera-list-view";
   		self.page = 0;
        BaseLayoutView.initialize();
    }
    
    function onShow() {
    	BaseLayoutView.onShow();
    	self.iconTimes = Ui.loadResource(Rez.Drawables.times16);
    	self.iconCheck = Ui.loadResource(Rez.Drawables.check16);
    }

    function setPage(page) {
    	self.page = page;
    	Ui.requestUpdate();
    }

	// TODO i think the camera view should own the controller (delegate) 
	// and also handle the case where the item list size changes while reloading
    function onUpdate(dc) {
    	if(BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
		self.drawCameraList(dc);
		return true;	
	}
	
	function drawCameraList(dc) {
		var yOffset = self.offsetY;
    	var cameraList = NestApi.getInstance().getCameraList();
    	if (!NestApi.getInstance().hasCameras()) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    		dc.drawText(self.width/2, yOffset, Graphics.FONT_SMALL, "No cameras found.", Graphics.TEXT_JUSTIFY_CENTER);
    	} else {
    		// divide remaining space up into 5 parts; 70% for 3 camera rows, 30% for page selectors
    		var selectHeight = ((self.height - yOffset)/100 * 20)/2;
    		
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
    				dc.setColor(!camera["is_online"] ? Graphics.COLOR_DK_RED : Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
    			} else {
    				// selected item
    				dc.setColor(!camera["is_online"] ? Graphics.COLOR_RED : Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    			}
    			var icon = camera["is_streaming"] ? self.iconCheck : self.iconTimes;
    			var textDimensions = dc.getTextDimensions(camera["name"], Graphics.FONT_XTINY);
    			var iconOffsetX = textDimensions[0] / 2 + 16 + 5;
    			var iconOffsetY = (textDimensions[1] - 16)/ 2;

    			dc.drawBitmap(self.width/2 - iconOffsetX, currentOffset-rowHeight/2-10 + iconOffsetY , icon);
    			dc.drawText(self.width/2, currentOffset-rowHeight/2-10, Graphics.FONT_XTINY, camera["name"], Graphics.TEXT_JUSTIFY_CENTER);
    			if (j == 0) {
    				// selected item
    				dc.setPenWidth(3);
    			}
	    		dc.drawLine(0, currentOffset, self.width, currentOffset);
	    		dc.setPenWidth(1);
	    	}

    		// scroll down
    		if (self.page != cameraList.size()-1) {
    			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	    		dc.fillPolygon([
	    			[self.width/2 - selectHeight/2, self.height - selectHeight - 10],
	    			[self.width/2 , self.height - 10],			
	    			[self.width/2 + selectHeight/2, self.height - selectHeight - 10]
	    		]);
	    	}
    	}
    }
}