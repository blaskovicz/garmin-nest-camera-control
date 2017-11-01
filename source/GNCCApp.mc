using Toybox.Application as App;

class GNCCApp extends App.AppBase {
    function initialize() {
    	//Logger.getInstance("DEBUG").info("HI");    
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function onBack() {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new GNCCView(), new GNCCInputDelegate() ];
    }
}