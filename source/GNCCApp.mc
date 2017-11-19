using Toybox.Application as App;

// Getting started links:
// * https://developer.garmin.com/connect-iq/programmers-guide/monkey-c/
// * https://developer.garmin.com/connect-iq/programmers-guide/user-interface/
// * https://developer.garmin.com/downloads/connect-iq/monkey-c/doc/Toybox/WatchUi.html
class GNCCApp extends App.AppBase {
	protected var entryView;
    function initialize() {
    	Logger.getInstance().info("ref=gncc-app at=initialize");
        AppBase.initialize();
        if (entryView == null) {
	    	var view = new SummaryView();
	        entryView = [ view, new SummaryDelegate(view) ];
        }
    }

    // onStart() is called on application start up
    function onStart(state) {
    	Logger.getInstance().info("ref=gncc-app at=on-start");
    	NestApi.getInstance().startTimer();    	
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	Logger.getInstance().infoF("ref=gncc-app at=on-stop state=$1$", state);
    	NestApi.getInstance().stopTimer();
    }
    
    function onBack() {
    	Logger.getInstance().info("ref=gncc-app at=on-back");
    }

    // Return the initial view of your application here
    function getInitialView() {
    	Logger.getInstance().info("ref=gncc-app at=get-initial-view");
		return entryView;
    }
}

// vi:syntax=javascript filetype=javascript