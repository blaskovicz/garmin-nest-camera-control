using Toybox.WatchUi as Ui;
using Toybox.Graphics;

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
	function initialize() {
		self.ref = "loading-view";
		BaseLayoutView.initialize();
		self.startTimer();	
	}

    function startTimer() {
    	self.timer = new Timer.Timer();
    	self.timer.start(self.method(:checkRequestProgress), 1000, true);
    }
    
    // abort the loading dialog when the request is finished
    function checkRequestProgress() {
    	var currentState = NestApi.getInstance().getState();
    	if (currentState == null || currentState[:state] == NestApi.StateRequestError || currentState[:state] == NestApi.StateRequestSuccess) {
    		Logger.getInstance().info("ref=loading-view at=check-request-progress state-change=complete");
    		self.timer.stop();
    		Ui.popView(Ui.SLIDE_IMMEDIATE);
    	}
    }
    
	function onShow() {
		BaseLayoutView.onShow();
		Notify.enableBacklight();
	}

    function onUpdate(dc) {
    	if (BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
		var currentState = NestApi.getInstance().getState();    	
    	var text = currentState != null && currentState.hasKey(:text) && currentState[:text] != null ? currentState[:text] : "Processing...";
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(self.width/2, self.offsetY + fontTinyHeight*2, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
		// TODO draw loading dots / arc / timeout time
	}
	
	function onHide() {
		BaseLayoutView.onHide();
		Notify.disableBacklight();
	}
}
