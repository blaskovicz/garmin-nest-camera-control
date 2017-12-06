// base class shared by all views in this app,
// providing some helper functionality
using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Lang;
using Constants;

class BaseLayoutView extends Ui.View {
	protected var width;
	protected var height;
	protected var offsetY;
	protected var ref;
	protected var pushingView;
	protected var poppingView;
	protected var toastTimeout;
	protected var toastPollerTimeout;

    function initialize() {
    	View.initialize();
    	if (self.ref == null || "".equals(self.ref)) {
    		throw new InvalidArgumentError("BaseLayoutView: ref undefined");
    	}
   		Logger.getInstance().infoF("ref=$1$ at=initialize", [self.ref]);
   		self.pushingView = false;
   		self.poppingView = false; 
   		
   		// let children know where to start drawing
    	self.offsetY = Constants.HEIGHT_FONT_TINY*2 - 5;
    }
    
    protected function isAnEphemeralView() {
    	var isErrorView = self.ref.equals("error-view");
    	var isLoadingView = !isErrorView && self.ref.equals("loading-view");
    	return isErrorView || isLoadingView;
    }
    
    protected function handleAsyncView() {
    	// if we're using an ephemeral view, switch to the next ephemeral
    	// view instead of pushing it so pop works as expected.

    	var currentState = NestApi.getInstance().getState();
    	if (!self.isAnEphemeralView() && currentState != null && currentState[:state] == NestApi.StateRequestError) {
    		Logger.getInstance().infoF("ref=$1$ at=on-update push-view=error-view", [self.ref]);
    		self.pushingView = true;
			self.pushView(new ErrorView(), new ErrorDelegate(), Ui.SLIDE_LEFT);
			return true;
		} else if (!self.isAnEphemeralView() && currentState != null && currentState[:state] == NestApi.StateRequesting) {
    		Logger.getInstance().infoF("ref=$1$ at=on-update push-view=loading-view", [self.ref]);
    		self.pushingView = true;
			self.pushView(new LoadingView(), new LoadingDelegate(), Ui.SLIDE_LEFT);
			return true;
			// TODO flash success
		}
		return false;
    }

    // Load your resources here
    function onLayout(dc) {
    	View.onLayout(dc);
   		Logger.getInstance().infoF("ref=$1$ at=on-layout", [self.ref]);
   		return self.handleAsyncView();    
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	View.onShow();
    	Logger.getInstance().infoF("ref=$1$ at=on-show", [self.ref]);
    	self.pushingView = false;
    	self.poppingView = false;
    	return self.handleAsyncView();
    }

	// Update the view with new dynamic content
    function onUpdate(dc) {
    	View.onUpdate(dc);

    	// if child classes encounter or trigger a request, push a modal to the user
    	if (self.poppingView || self.pushingView || self.handleAsyncView()) {
    		return true;
    	}
    	
    	var currentState = NestApi.getInstance().getState();
    	var pollerState = NestApi.getInstance().getPollerState();
		
		Logger.getInstance().infoF("ref=$1$ at=on-update", [self.ref]);
    	self.pushingView = false;
    	self.poppingView = false;

    	// calculate new dimensions
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	
    	// clear screen
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	//dc.clear();
    	dc.setPenWidth(3);
    	
		// draw toast message if we have one, otherwise the normal header
		if (!self.isAnEphemeralView() && currentState != null && currentState[:state] == NestApi.StateRequestSuccess && self.toastPollerTimeout == null) {
			self.drawToast(dc, Graphics.COLOR_DK_GREEN, "Success");
	    	self.startToastTimeout();
	    } else if (!self.isAnEphemeralView() && pollerState != null && pollerState[:state] == NestApi.StateRequestError && self.toastTimeout == null) {
	    	self.drawToast(dc, Graphics.COLOR_RED, pollerState[:text]);
	    	self.startToastPollerTimeout();
		} else {
 	    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
 	    	dc.drawText(self.width/2,  Constants.HEIGHT_FONT_TINY - 10, Graphics.FONT_TINY, "Garmin Nest", Graphics.TEXT_JUSTIFY_CENTER);
 	    	dc.drawLine(0,  Constants.HEIGHT_FONT_TINY*2 - 10, self.width,  Constants.HEIGHT_FONT_TINY*2 - 10);
 	    }

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
    	return false;
    }
    
    function drawToast(dc, color, text) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, 0, self.width, Constants.HEIGHT_FONT_TINY*2 - 10);
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		dc.drawText(self.width/2, Constants.HEIGHT_FONT_TINY - 10, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawLine(0, Constants.HEIGHT_FONT_TINY*2 - 10, self.width, Constants.HEIGHT_FONT_TINY*2 - 10);
    }
    
    // TODO common toast queue
    function startToastTimeout() {
    	if (self.toastTimeout != null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=start-toast-timeout", [self.ref]);
    	// start our timer to cancel the toast after 3 seconds
    	self.toastTimeout = new Timer.Timer();
    	self.toastTimeout.start(self.method(:clearToast), 5000, false);
    	Notify.enableBacklight();
    	Notify.vibrate(:short);	
    }

    function startToastPollerTimeout() {
    	if (self.toastPollerTimeout != null) {
    		return;
    	}
    	Logger.getInstance().infoF("ref=$1$ at=start-toast-poller-timeout", [self.ref]);
    	// start our timer to cancel the toast after 3 seconds
    	self.toastPollerTimeout = new Timer.Timer();
    	self.toastPollerTimeout.start(self.method(:clearToastPoller), 5000, false);
		Notify.enableBacklight();
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
    	//View.onHide();
    	Logger.getInstance().infoF("ref=$1$ at=on-hide", [self.ref]);
    	self.clearToast();
    	self.clearToastPoller();
    	return false;
    }
}

// vi:syntax=javascript filetype=javascript