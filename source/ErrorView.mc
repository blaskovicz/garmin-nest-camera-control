using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Constants;

class ErrorDelegate extends Ui.BehaviorDelegate {
    function initialize() {
    	Logger.getInstance().info("ref=error-delegate at=initialize");
        BehaviorDelegate.initialize();
    }

    function onKey(ev) {
        var key = ev.getKey();
        if (Ui.KEY_START == key || Ui.KEY_ENTER == key) {
        	return onBack();
        }
        return false;
    }
    
    // user pressed back, ok or enter.
    function onBack() {
    	Logger.getInstance().info("ref=error-delegate at=on-back");
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    	return true;
    }
}

class ErrorView extends BaseLayoutView {
	protected var iconExclamation;
	function initialize() {
		self.ref = "error-view";
		BaseLayoutView.initialize();
	}
	
	function onLayout(dc) {
		BaseLayoutView.onLayout(dc);
		self.iconExclamation = Ui.loadResource(Rez.Drawables.exclamationtriangle16);
		self.onUpdate(dc);
	}
	
	function onShow() {
		BaseLayoutView.onShow();
		NestApi.getInstance().stopTimer();
		Notify.enableBacklight();
		Notify.vibrate(:short);
	}

	function onUpdate(dc) {
    	if (BaseLayoutView.onUpdate(dc)) {
    		return true;
    	}
    	// TODO this blinks white text and then red after the transition - fix
		var currentState = NestApi.getInstance().getState();
		var text = currentState != null && currentState.hasKey(:text) && currentState[:text] != null ? currentState[:text] : "An error occurred.";
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		// TODO: wrap text to multiple lines for long errors
		dc.drawText(self.width/2, self.offsetY + Constants.HEIGHT_FONT_TINY*2, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawBitmap(self.width/2 - 8, self.offsetY + Constants.HEIGHT_FONT_TINY, self.iconExclamation);
		return true;
	}
	
	function onHide() {
		BaseLayoutView.onHide();
		NestApi.getInstance().clearState();
		NestApi.getInstance().startTimer();
	}
}

// vi:syntax=javascript filetype=javascript