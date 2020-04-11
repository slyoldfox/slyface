using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Lang;
using Toybox.ActivityMonitor;

class slyfaceView extends WatchUi.WatchFace {

	var is24Hour = true;
    function initialize() {
	//Get 24 Setting from watch
		var settings = System.getDeviceSettings();
		is24Hour = settings.is24Hour;		    
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    	dc.clear();
    	
    	var deviceSettings = System.getDeviceSettings();

        //var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var width = dc.getWidth()/2;
        drawTime( dc, width );	
        drawCaloriesAndSteps(dc, deviceSettings, width, 165);
        drawBattery(dc, width, 210);
        /*
        var view = View.findDrawableById("TimeLabel");
        view.setText(timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        */
    }
    
    hidden function drawTime( dc, width ) {
	    var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var ampm = "";
        
        if (!is24Hour)
        {
            //handle midnight and noon, which return as 0
            hour = clockTime.hour % 12 == 0 ? 12 : clockTime.hour % 12 ;
            ampm = clockTime.hour >= 12 && clockTime.hour < 24 ? " PM" : " AM";
        }
        
        var min = Lang.format("$1$", [clockTime.min.format("%02d")]);
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.drawText( width, 5,Graphics.FONT_TINY, Lang.format( "$1$ $2$ $3$", [today.day_of_week, today.day, today.month ] ), Graphics.TEXT_JUSTIFY_CENTER);        	
        dc.drawText( width, 32, Graphics.FONT_NUMBER_THAI_HOT, Lang.format("$1$", [hour.format("%02d")]), Graphics.TEXT_JUSTIFY_RIGHT);
        
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawText( width, 32, Graphics.FONT_NUMBER_THAI_HOT, min, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText( width + 80, 85, Graphics.FONT_TINY, ampm, Graphics.TEXT_JUSTIFY_LEFT);
    }

	hidden function drawCaloriesAndSteps( dc, deviceSettings, width, offset ) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        var activityInfo = ActivityMonitor.getInfo();
        var activitySteps = activityInfo.steps;
        if( activitySteps != null ) {
        	var distance;
        	if(deviceSettings.distanceUnits==System.UNIT_STATUTE) {
				distance=(activityInfo.distance/160934.0).format("%.2f")+" mi";
			} else {
				distance=(activityInfo.distance/(100000.0)).format("%.2f")+" km";
			} 
        	dc.drawText( width, offset - 30,Graphics.FONT_TINY, Lang.format(" $1$ steps — " + distance, [activitySteps]), Graphics.TEXT_JUSTIFY_CENTER);        	
        } else {
            dc.drawText( width, offset - 30,Graphics.FONT_TINY, "unknown steps", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
         
		var calories = activityInfo.calories;
        if( calories != null ) {
        	dc.drawText( width, offset, Graphics.FONT_TINY, Lang.format(" $1$ kcal", [calories]), Graphics.TEXT_JUSTIFY_CENTER);        	
        } else {
            dc.drawText( width, offset, Graphics.FONT_TINY, "unknown kcal", Graphics.TEXT_JUSTIFY_CENTER);
        }
	}

	hidden function drawBattery( dc, width, offset ) {
        var Battery = Toybox.System.getSystemStats().battery;               
        if( Battery >= 10 ) {
	        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else {
	        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);        
        }

        var BatteryStr = Lang.format(" $1$% ", [Battery.toLong()]);
        dc.drawText( width, offset,Graphics.FONT_TINY, BatteryStr, Graphics.TEXT_JUSTIFY_CENTER);
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
