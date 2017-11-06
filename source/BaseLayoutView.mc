// base class shared by all views in this app,
// providing some helper functionality
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;

var fontTinyHeight = Graphics.getFontHeight(Graphics.FONT_TINY);

class BaseLayoutView extends Ui.View {
	protected var width;
	protected var height;
	protected var offsetY;
	protected var ref;
	protected var pushingView;
	protected var toastTimeout;
	protected var toastPollerTimeout;

    function initialize() {
    	if (self.ref == null) {
    		self.ref = "base-layout-view";
    	}
   		Logger.getInstance().infoF("ref=$1$ at=initialize", [self.ref]);
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
    	Logger.getInstance().infoF("ref=$1$ at=on-show", [self.ref]);
    	self.pushingView = false;
    }

	// Update the view with new dynamic content
    function onUpdate(dc) {
    	// if child classes encounter or trigger a request, push a modal to the user
    	if (self.pushingView) {
    		return true;
    	}
    	
    	var currentState = NestApi.getInstance().getState();
    	var pollerState = NestApi.getInstance().getPollerState();
    	
    	// if we're using an ephemeral view, switch to the next ephemeral
    	// view instead of pushing it so pop works as expected.
    	var isErrorView = self.ref.equals("error-view");
    	var isLoadingView = !isErrorView && self.ref.equals("loading-view");
    	var isAnEphemeralView = isErrorView || isLoadingView;
    	
    	if (!isAnEphemeralView && currentState != null && currentState[:state] == NestApi.StateRequestError) {
    		Logger.getInstance().infoF("ref=$1$ at=on-update push-view=error-view", [self.ref]);
    		self.pushingView = true;
			self.pushView(new ErrorView(), new ErrorDelegate(), Ui.SLIDE_LEFT);
			return true;
		} else if (!isAnEphemeralView && currentState != null && currentState[:state] == NestApi.StateRequesting) {
    		Logger.getInstance().infoF("ref=$1$ at=on-update push-view=loading-view", [self.ref]);
    		self.pushingView = true;
			self.pushView(new LoadingView(), new LoadingDelegate(), Ui.SLIDE_LEFT);
			return true;
			// TODO flash success
		}
		
		Logger.getInstance().infoF("ref=$1$ at=on-update", [self.ref]);
    	self.pushingView = false;

    	// calculate new dimensions
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	
    	// clear screen
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setPenWidth(3);
    	
		// draw toast message if we have one, otherwise the normal header
		if (!isAnEphemeralView && currentState != null && currentState[:state] == NestApi.StateRequestSuccess && self.toastPollerTimeout == null) {
			self.drawToast(dc, Graphics.COLOR_DK_GREEN, "Success");
	    	self.startToastTimeout();
	    } else if (!isAnEphemeralView && pollerState != null && pollerState[:state] == NestApi.StateRequestError && self.toastTimeout == null) {
	    	self.drawToast(dc, Graphics.COLOR_RED, pollerState[:text]);
	    	self.startToastPollerTimeout();
		} else {
	    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
	    	dc.drawText(self.width/2, fontTinyHeight - 10, Graphics.FONT_TINY, "Garmin Nest", Graphics.TEXT_JUSTIFY_CENTER);
	    	dc.drawLine(0, fontTinyHeight*2 - 10, self.width, fontTinyHeight*2 - 10);
	    }

		// let children know where to start drawing
    	self.offsetY = fontTinyHeight*2 - 5;

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
    	return false;
    }
    
    function drawToast(dc, color, text) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, 0, self.width, fontTinyHeight*2 - 10);
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		dc.drawText(self.width/2, fontTinyHeight - 10, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawLine(0, fontTinyHeight*2 - 10, self.width, fontTinyHeight*2 - 10);
    }
    
    // TODO common toast queue
    function startToastTimeout() {
    	if (self.toastTimeout != null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=start-toast-timeout", [self.ref]);
    	// start our timer to cancel the toast after 3 seconds
    	self.toastTimeout = new Timer.Timer();
    	self.toastTimeout.start(self.method(:clearToast), 2500, false);
    }

    function startToastPollerTimeout() {
    	if (self.toastPollerTimeout != null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=start-toast-poller-timeout", [self.ref]);
    	// start our timer to cancel the toast after 3 seconds
    	self.toastPollerTimeout = new Timer.Timer();
    	self.toastPollerTimeout.start(self.method(:clearToastPoller), 2500, false);
    }
    
    function clearToast() {
    	if (self.toastTimeout == null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=clear-toast", [self.ref]);
    	self.toastTimeout.stop();
    	self.toastTimeout = null;
    	var currentState = NestApi.getInstance().getState();
    	if (currentState != null && currentState[:state] == NestApi.StateRequestSuccess) {
    		NestApi.getInstance().clearState();
    	}
    }

    function clearToastPoller() {
    	if (self.toastPollerTimeout == null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=clear-toast-poller", [self.ref]);
    	self.toastPollerTimeout.stop();
    	self.toastPollerTimeout = null;
    	var currentState = NestApi.getInstance().getPollerState();
    	if (currentState != null && currentState[:state] == NestApi.StateRequestError) {
    		NestApi.getInstance().clearPollerState();
    	}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	Logger.getInstance().infoF("ref=$1$ at=on-hide", [self.ref]);
    	self.clearToast();
    }
}