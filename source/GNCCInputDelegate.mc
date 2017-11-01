using Toybox.System;
using Toybox.WatchUi;

class GNCCInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }
    function onKey(keyEvent) {
        System.println(keyEvent.getKey());         // e.g. KEY_MENU = 7
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
    }
}