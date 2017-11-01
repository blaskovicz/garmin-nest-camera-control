using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics;

class GNCCView extends Ui.View {
	var width;
	var height;

    function initialize() {
   		Logger.getInstance().info("ref=gncc-view at=initialize");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
   		Logger.getInstance().info("ref=gncc-view at=on-layout");    
        //setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	Logger.getInstance().info("ref=gncc-view at=on-show");  
		/* var message = "Continue?";
		var dialog = new Ui.Confirmation(message);
		Ui.pushView(
		    dialog,
		    new ConfirmationDelegate(),
		    WatchUi.SLIDE_IMMEDIATE
		);*/
    }

    // Update the view
    function onUpdate(dc) {
    	Logger.getInstance().info("ref=gncc-view at=on-update");
    	self.width = dc.getWidth();
    	self.height = dc.getHeight();
    	 
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    	var fontHeight = Graphics.getFontHeight(Graphics.FONT_LARGE);
    	var fontYMiddle = height/2 - fontHeight/2;
    	dc.drawLine(0, fontYMiddle, width, fontYMiddle);
    	dc.drawText(width/2, fontYMiddle, Graphics.FONT_LARGE, "HELLO WORLD!", Graphics.TEXT_JUSTIFY_CENTER);
    	dc.drawLine(0, fontYMiddle+fontHeight, width, fontYMiddle+fontHeight);
        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	Logger.getInstance().info("ref=gncc-view at=on-hide");  
    }
}
