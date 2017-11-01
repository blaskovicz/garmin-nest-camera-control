using Toybox.System;
using Toybox.WatchUi;

class GNCCInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
    	Logger.getInstance().info("ref=gncc-input-delegate at=initialize");
        InputDelegate.initialize();
    }
    function onKey(ev) {
    	Logger.getInstance().infoF("ref=gncc-input-delegate at=on-key event='$1$'", ev);
        //System.println(ev.getKey());         // e.g. KEY_MENU = 7
    }

    function onTap(ev) {
    	Logger.getInstance().infoF("ref=gncc-input-delegate at=on-tap event='$1$'", ev);
        //System.println(ev.getType());      // e.g. CLICK_TYPE_TAP = 0
    }

    function onSwipe(ev) {
    	Logger.getInstance().infoF("ref=gncc-input-delegate at=on-swipe event='$1$'", ev);
        //System.println(ev.getDirection()); // e.g. SWIPE_DOWN = 2
    }
}