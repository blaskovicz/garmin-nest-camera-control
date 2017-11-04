using Toybox.Application as App;

class GNCCApp extends App.AppBase {
    function initialize() {
    	Logger.getInstance().info("ref=gncc-app at=initialize");
        AppBase.initialize();
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
    	var view = new SummaryView();
        return [ view, new SummaryDelegate(view) ];
    }
}