import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Application.Storage;
import Toybox.Math;
import Toybox.Lang;

class Fenix7WatchFaceView extends WatchUi.WatchFace {

    private var isAwake as Lang.Boolean = true;
    
    // Metallic slate-cyan palette
    private var colorMetallicTick as Lang.Number = 0x3EA3B8;
    private var colorWhite as Lang.Number = 0xFFFFFF;
    private var colorDarkGray as Lang.Number = 0x4A5568;
    private var colorBlack as Lang.Number = 0x000000;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onShow() as Void {
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;

        // 1. Clear background to solid black
        dc.setColor(colorBlack, colorBlack);
        dc.clear();

        // 2. Draw 6 Metallic Divider Ticks at EXACTLY 1, 3, 5, 7, 9, 11 o'clock
        drawPerimeterTicks(dc, cx, cy);

        // 3. Draw 6 Perimeter Data Fields centered in each sector along the rim
        drawPerimeterData(dc, cx, cy);

        // 4. Draw Upper Section (Current Temp, Elevation, Min/Max + Weather icon, Sun Event)
        drawUpperSection(dc, cx, cy);

        // 5. Draw Center Main Time (Centered Hours + Minutes + Seconds/Rest Bar)
        drawMainTime(dc, cx, cy);

        // 6. Draw Lower Section (Intensity, HR, Today Steps, 7-Day RHR)
        drawLowerSection(dc, cx, cy);
    }

    // --- 1. Metallic Divider Ticks at EXACTLY 1, 3, 5, 7, 9, 11 o'clock ---
    private function drawPerimeterTicks(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        dc.setColor(colorMetallicTick, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);

        var rOuter = (cx * 0.96).toNumber();
        var rInner = (cx * 0.86).toNumber();

        // Radial ticks at 1, 5, 7, 11 o'clock
        var tickHours = [1, 5, 7, 11];
        for (var i = 0; i < tickHours.size(); i++) {
            var rad = (tickHours[i] * 30.0) * Math.PI / 180.0;
            var x1 = (cx + rInner * Math.sin(rad)).toNumber();
            var y1 = (cy - rInner * Math.cos(rad)).toNumber();
            var x2 = (cx + rOuter * Math.sin(rad)).toNumber();
            var y2 = (cy - rOuter * Math.cos(rad)).toNumber();
            dc.drawLine(x1, y1, x2, y2);
        }

        // 9 o'clock tick: Left horizontal bar at the rim (270°)
        dc.fillRectangle(cx - rOuter, cy - 2, (rOuter - rInner), 4);

        // 3 o'clock position: Right horizontal (90°)
        // In Rest Mode: Metallic tick bar at the rim
        if (!isAwake) {
            dc.fillRectangle(cx + rInner, cy - 2, (rOuter - rInner), 4);
        }
    }

    // --- 2. Perimeter Data Fields along the rim ---
    private function drawPerimeterData(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var owmSpeed = Storage.getValue("OwmWindSpeed") as Lang.Number?;
        var owmDeg = Storage.getValue("OwmWindDeg") as Lang.Number?;
        var pop = Storage.getValue("OwmPop") as Lang.Number?;
        var rain1h = Storage.getValue("OwmRain1h") as Lang.Float?;
        var tzOffset = Storage.getValue("IsraelTimezoneOffset") as Lang.Number?;

        if (pop == null) { pop = 100; }
        if (rain1h == null) { rain1h = 0.0; }

        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);

        // 12 o'clock (Top): Wind (e.g. "13 NW")
        var windStr = ActivityHistoryHelper.getWindString(owmSpeed, owmDeg);
        dc.drawText(cx, 10, Graphics.FONT_XTINY, windStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 2 o'clock (Top Right): Precipitation (e.g. "100% 0mm")
        var precipStr = Lang.format("$1$% $2$mm", [pop, rain1h.format("%.0f")]);
        dc.drawText((cx * 1.44).toNumber(), (cy * 0.30).toNumber(), Graphics.FONT_XTINY, precipStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 10 o'clock (Top Left): Israel Time (e.g. "ISR 10:07")
        var isrStr = ActivityHistoryHelper.getIsraelTimeString(tzOffset);
        dc.drawText((cx * 0.56).toNumber(), (cy * 0.30).toNumber(), Graphics.FONT_XTINY, isrStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 8 o'clock (Bottom Left): Weekly Cycling KM (e.g. "BIKE 9.0")
        var bikeKm = ActivityHistoryHelper.getWeeklyCyclingKm();
        var bikeStr = Lang.format("BIKE $1$", [bikeKm.format("%.1f")]);
        dc.drawText((cx * 0.54).toNumber(), (cy * 1.62).toNumber(), Graphics.FONT_XTINY, bikeStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 6 o'clock (Bottom): Date (e.g. "MON AUG 17")
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week.toUpper(), info.month.toUpper(), info.day]);
        dc.drawText(cx, (cy * 1.80).toNumber(), Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 4 o'clock (Bottom Right): Weekly Steps (e.g. "STEP 7.3k")
        var weeklySteps = ActivityHistoryHelper.getWeeklySteps();
        var weeklyStepsStr = Lang.format("STEP $1$", [ActivityHistoryHelper.formatStepsShort(weeklySteps)]);
        dc.drawText((cx * 1.46).toNumber(), (cy * 1.62).toNumber(), Graphics.FONT_XTINY, weeklyStepsStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // --- 3. Upper Section ---
    private function drawUpperSection(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var owmTemp = Storage.getValue("OwmTemp") as Lang.Number?;
        var owmTempMin = Storage.getValue("OwmTempMin") as Lang.Number?;
        var owmTempMax = Storage.getValue("OwmTempMax") as Lang.Number?;
        var owmSunrise = Storage.getValue("OwmSunrise") as Lang.Number?;
        var owmSunset = Storage.getValue("OwmSunset") as Lang.Number?;
        var owmCondition = Storage.getValue("OwmCondition") as Lang.String?;
        var lastLat = Storage.getValue("LastLat") as Lang.Float?;
        var lastLon = Storage.getValue("LastLon") as Lang.Float?;

        var curTemp = (owmTemp != null) ? owmTemp : 18;
        var minTemp = (owmTempMin != null) ? owmTempMin : 17;
        var maxTemp = (owmTempMax != null) ? owmTempMax : 21;

        // Current Temp (Center, under wind) - Clean FONT_TINY
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (cy * 0.23).toNumber(), Graphics.FONT_TINY, curTemp.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var rowY = (cy * 0.49).toNumber();
        var iconY = rowY - 6;
        var textY = rowY + 3;

        var colLeftX = (cx * 0.58).toNumber();
        var colMidX = cx;
        var colRightX = (cx * 1.42).toNumber();

        // Left Column: Elevation + Mountain Icon
        VectorIcons.drawMountain(dc, colLeftX, iconY, colorWhite);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colLeftX, textY, Graphics.FONT_XTINY, ActivityHistoryHelper.getCurrentElevation().toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // Center Column: Dynamic Weather Icon from OWM + Min/Max Temp
        VectorIcons.drawWeatherCondition(dc, colMidX, iconY, owmCondition, colorWhite);
        var minMaxStr = Lang.format("$1$/$2$", [maxTemp, minTemp]);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, textY, Graphics.FONT_XTINY, minMaxStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Right Column: Next Sun Event + Sun Icon
        var sunEvent = SunCalc.getNextSunEvent(lastLat, lastLon, owmSunrise, owmSunset);
        VectorIcons.drawSunHorizon(dc, colRightX, iconY, colorWhite);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colRightX, textY, Graphics.FONT_XTINY, sunEvent.get(:nextEventTime) as Lang.String, Graphics.TEXT_JUSTIFY_CENTER);

        // Vertical Dividers (Grey)
        dc.setColor(colorDarkGray, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        var div1X = (cx * 0.79).toNumber();
        var div2X = (cx * 1.21).toNumber();
        dc.drawLine(div1X, iconY - 5, div1X, textY + 16);
        dc.drawLine(div2X, iconY - 5, div2X, textY + 16);
    }

    // --- 4. Center Main Time (Centred Horizontally) ---
    private function drawMainTime(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var clockTime = System.getClockTime();
        var hourStr = clockTime.hour.format("%02d");
        var minStr = clockTime.min.format("%02d");

        var font = Graphics.FONT_NUMBER_HOT;
        var hourW = dc.getTextWidthInPixels(hourStr, font);
        var minW = dc.getTextWidthInPixels(minStr, font);
        var gap = 4;
        var totalW = hourW + gap + minW;

        // Perfectly centered horizontally on the display
        var startX = cx - (totalW / 2);
        var timeY = (cy * 0.69).toNumber();

        // Hours: Solid White
        OutlinedFontRenderer.drawSolidTimeText(dc, startX, timeY, font, hourStr, colorWhite, Graphics.TEXT_JUSTIFY_LEFT);

        // Minutes: Outlined Hollow White with black center
        var minX = startX + hourW + gap;
        OutlinedFontRenderer.drawOutlinedTimeText(dc, minX, timeY, font, minStr, colorWhite, colorBlack, 2, Graphics.TEXT_JUSTIFY_LEFT);

        // Seconds in Active Mode - Aligned Right at the 3 o'clock Outer Rim
        if (isAwake) {
            var secStr = clockTime.sec.format("%02d");
            var secX = (cx * 1.93).toNumber();
            var secY = cy - 7;
            dc.setColor(colorMetallicTick, Graphics.COLOR_TRANSPARENT);
            dc.drawText(secX, secY, Graphics.FONT_XTINY, secStr, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    // --- 5. Lower Section ---
    private function drawLowerSection(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var rowY = (cy * 1.20).toNumber();
        var textY = rowY;
        var iconY = rowY + 16;

        var colLeftX = (cx * 0.58).toNumber();
        var colMidX = cx;
        var colRightX = (cx * 1.42).toNumber();

        // Left Column: Weekly Intensity Minutes + Intensity Icon
        var intensityMins = ActivityHistoryHelper.getWeeklyIntensityMinutes();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colLeftX, textY, Graphics.FONT_XTINY, intensityMins.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawIntensityIcon(dc, colLeftX, iconY, colorWhite);

        // Center Column: Current Heart Rate + Heart ECG Icon
        var curHR = ActivityHistoryHelper.getCurrentHeartRate();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, textY, Graphics.FONT_XTINY, curHR.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawHeartWithPulse(dc, colMidX, iconY, colorWhite);

        // Right Column: Today's Steps + Footsteps Icon
        var actInfo = ActivityMonitor.getInfo();
        var todaySteps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 7300;
        var stepsStr = ActivityHistoryHelper.formatStepsShort(todaySteps);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colRightX, textY, Graphics.FONT_XTINY, stepsStr, Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawFootsteps(dc, colRightX, iconY, colorWhite);

        // Vertical Dividers (Grey)
        dc.setColor(colorDarkGray, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        var div1X = (cx * 0.79).toNumber();
        var div2X = (cx * 1.21).toNumber();
        dc.drawLine(div1X, textY - 2, div1X, iconY + 8);
        dc.drawLine(div2X, textY - 2, div2X, iconY + 8);

        // Bottom Center Under Heart Icon: 7-Day Average Resting Heart Rate
        var rhr = ActivityHistoryHelper.get7DayAverageRHR();
        var rhrY = (cy * 1.46).toNumber();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, rhrY, Graphics.FONT_XTINY, rhr.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
