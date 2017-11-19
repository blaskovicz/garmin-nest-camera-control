using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Constants;

class LoadingDelegate extends Ui.BehaviorDelegate {
    function initialize() {
    	Logger.getInstance().info("ref=loading-delegate at=initialize");
        BehaviorDelegate.initialize();
    }

	// don't allow back button to be pressed during this action
	function onKey(ev) {
		return onBack();
	}
    function onBack() {
    	Logger.getInstance().info("ref=loading-delegate at=on-back");
        return true;
    }
}

class LoadingView extends BaseLayoutView {
	protected var timer;
	protected var dotNumber;
	function initialize() {
		self.ref = "loading-view";
		BaseLayoutView.initialize();
		dotNumber = 0;
		self.startTimer();	
	}

    function startTimer() {
    	self.timer = new Timer.Timer();
    	self.timer.start(self.method(:checkRequestProgress), 300, true);
    }
    
    // abort the loading dialog when the request is finished
    protected function popViewOnComplete() {
    	if (self.isComplete() && !self.poppingView) {
    		self.poppingView = true;
    		Logger.getInstance().info("ref=loading-view at=check-request-progress state-change=complete");
    		self.timer.stop();
    		Ui.popView(Ui.SLIDE_IMMEDIATE);
    		return true;
    	}
    	return false;
    }
    function checkRequestProgress() {
    	if (self.popViewOnComplete()) {
			return true;
    	}
    	if (self.dotNumber+1 == 3) {
    		self.dotNumber = 0;
    	} else {
    		self.dotNumber++;
    	}
    	Ui.requestUpdate();
    	return false;
    }
    
    protected function isComplete() {
    	var currentState = NestApi.getInstance().getState();
    	return (currentState == null || currentState[:state] == NestApi.StateRequestError || currentState[:state] == NestApi.StateRequestSuccess);
    }
    
	function onLayout(dc) {
		BaseLayoutView.onLayout(dc);
		return self.onUpdate(dc);
	}
    
	function onShow() {
		BaseLayoutView.onShow();
		Notify.enableBacklight();
		return true;
	}

    function onUpdate(dc) {
    	if (BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
    	if (self.popViewOnComplete()) {
    		return true;
    	}
		var currentState = NestApi.getInstance().getState();    	
    	var text = currentState != null && currentState.hasKey(:text) && currentState[:text] != null ? currentState[:text] : "Processing...";
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(self.width/2, self.offsetY + Constants.HEIGHT_FONT_TINY*2, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
		
		var pad = 24;
		var loadingOffsetY = self.offsetY + Constants.HEIGHT_FONT_TINY*3 + pad;
		var loadingOffsetX = self.width/2 - pad;
		for (var i = 0; i < 3; i++) {
			dc.method(i == self.dotNumber ? :fillCircle : :drawCircle).invoke(loadingOffsetX + pad*i, loadingOffsetY, 8);
		}
		// TODO draw loading dots / arc / timeout time
		return true;
	}
}

// vi:syntax=javascript filetype=javascript