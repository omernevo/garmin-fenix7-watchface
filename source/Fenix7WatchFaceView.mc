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

        // 3. Draw 6 Curved Perimeter Data Fields at 12, 2, 4, 6, 8, 10 o'clock
        drawPerimeterData(dc, cx, cy);

        // 4. Draw Upper Section (OWM Temp, Elevation, Min/Max, Sun Event)
        drawUpperSection(dc, cx, cy);

        // 5. Draw Center Main Time (Solid Hours + Outlined Minutes + Seconds/Rest Bar)
        drawMainTime(dc, cx, cy);

        // 6. Draw Lower Section (Intensity, HR, Today Steps, 7-Day RHR)
        drawLowerSection(dc, cx, cy);
    }

    // --- 1. Metallic Divider Ticks at EXACTLY 1, 3, 5, 7, 9, 11 o'clock ---
    private function drawPerimeterTicks(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        dc.setColor(colorMetallicTick, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);

        var rOuter = (cx * 0.95).toNumber();
        var rInner = (cx * 0.85).toNumber();

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
        dc.fillRectangle(cx - rOuter, cy - 2, (rOuter - rInner), 5);

        // 3 o'clock position: Right horizontal (90°)
        if (!isAwake) {
            dc.fillRectangle(cx + rInner, cy - 2, (rOuter - rInner), 5);
        }
    }

    // --- 2. Curved Perimeter Data Fields centered at 12, 2, 4, 6, 8, 10 o'clock ---
    private function drawPerimeterData(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var owmSpeed = Storage.getValue("OwmWindSpeed") as Lang.Number?;
        var owmDeg = Storage.getValue("OwmWindDeg") as Lang.Number?;
        var pop = Storage.getValue("OwmPop") as Lang.Number?;
        var rain1h = Storage.getValue("OwmRain1h") as Lang.Float?;
        var tzOffset = Storage.getValue("IsraelTimezoneOffset") as Lang.Number?;

        if (pop == null) { pop = 100; }
        if (rain1h == null) { rain1h = 0.0; }

        var rimRadius = (cx * 0.88).toNumber();

        // Top half sectors (isBottom = false)
        // 12 o'clock (0°): Wind
        var windStr = ActivityHistoryHelper.getWindString(owmSpeed, owmDeg);
        drawCurvedClockText(dc, windStr, cx, cy, rimRadius, 0.0, Graphics.FONT_TINY, colorWhite, false);

        // 2 o'clock (60°): Precipitation
        var precipStr = Lang.format("$1$% $2$mm", [pop, rain1h.format("%.0f")]);
        drawCurvedClockText(dc, precipStr, cx, cy, rimRadius, 60.0, Graphics.FONT_TINY, colorWhite, false);

        // 10 o'clock (300°): Israel Time
        var isrStr = ActivityHistoryHelper.getIsraelTimeString(tzOffset);
        drawCurvedClockText(dc, isrStr, cx, cy, rimRadius, 300.0, Graphics.FONT_TINY, colorWhite, false);

        // Bottom half sectors (isBottom = true: reads left-to-right right-side-up)
        // 8 o'clock (240°): Weekly Cycling KM
        var bikeKm = ActivityHistoryHelper.getWeeklyCyclingKm();
        var bikeStr = Lang.format("BIKE $1$", [bikeKm.format("%.1f")]);
        drawCurvedClockText(dc, bikeStr, cx, cy, rimRadius, 240.0, Graphics.FONT_TINY, colorWhite, true);

        // 6 o'clock (180°): Date
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week.toUpper(), info.month.toUpper(), info.day]);
        drawCurvedClockText(dc, dateStr, cx, cy, rimRadius, 180.0, Graphics.FONT_TINY, colorWhite, true);

        // 4 o'clock (120°): Weekly Steps
        var weeklySteps = ActivityHistoryHelper.getWeeklySteps();
        var weeklyStepsStr = Lang.format("STEP $1$", [ActivityHistoryHelper.formatStepsShort(weeklySteps)]);
        drawCurvedClockText(dc, weeklyStepsStr, cx, cy, rimRadius, 120.0, Graphics.FONT_TINY, colorWhite, true);
    }

    // High-Precision Clockwise Curved Text Helper (with Left-to-Right Bottom orientation)
    private function drawCurvedClockText(dc as Graphics.Dc, text as Lang.String, cx as Lang.Number, cy as Lang.Number, radius as Lang.Number, clockAngleDeg as Lang.Float, font as Graphics.FontDefinition, color as Lang.Number, isBottomHalf as Lang.Boolean) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var charArray = text.toCharArray();
        var numChars = charArray.size();
        if (numChars == 0) { return; }

        var charAngularWidth = 0.095;
        var totalAngle = numChars * charAngularWidth;
        var centerRad = clockAngleDeg * Math.PI / 180.0;

        if (!isBottomHalf) {
            var startAngle = centerRad - (totalAngle / 2.0);
            for (var i = 0; i < numChars; i++) {
                var midAngle = startAngle + (i + 0.5) * charAngularWidth;
                var x = (cx + radius * Math.sin(midAngle)).toNumber();
                var y = (cy - radius * Math.cos(midAngle)).toNumber();
                var chStr = charArray[i].toString();
                dc.drawText(x, y, font, chStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else {
            var startAngle = centerRad + (totalAngle / 2.0);
            for (var i = 0; i < numChars; i++) {
                var midAngle = startAngle - (i + 0.5) * charAngularWidth;
                var x = (cx + radius * Math.sin(midAngle)).toNumber();
                var y = (cy - radius * Math.cos(midAngle)).toNumber();
                var chStr = charArray[i].toString();
                dc.drawText(x, y, font, chStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }

    // --- 3. Upper Section ---
    private function drawUpperSection(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var owmTemp = Storage.getValue("OwmTemp") as Lang.Number?;
        var owmTempMin = Storage.getValue("OwmTempMin") as Lang.Number?;
        var owmTempMax = Storage.getValue("OwmTempMax") as Lang.Number?;
        var owmSunrise = Storage.getValue("OwmSunrise") as Lang.Number?;
        var owmSunset = Storage.getValue("OwmSunset") as Lang.Number?;
        var lastLat = Storage.getValue("LastLat") as Lang.Float?;
        var lastLon = Storage.getValue("LastLon") as Lang.Float?;

        var curTemp = (owmTemp != null) ? owmTemp : 18;
        var minTemp = (owmTempMin != null) ? owmTempMin : 17;
        var maxTemp = (owmTempMax != null) ? owmTempMax : 21;

        // Current Temp (Center, under wind) - Font size matches other metric values
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (cy * 0.26).toNumber(), Graphics.FONT_SMALL, curTemp.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var rowY = (cy * 0.51).toNumber();
        var iconY = rowY - 10;
        var textY = rowY;

        var colLeftX = (cx * 0.65).toNumber();
        var colMidX = cx;
        var colRightX = (cx * 1.35).toNumber();

        // Left Column: Elevation + Mountain Icon
        VectorIcons.drawMountain(dc, colLeftX, iconY, colorWhite);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colLeftX, textY, Graphics.FONT_SMALL, ActivityHistoryHelper.getCurrentElevation().toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // Center Column: Min/Max Temp + Weather Icon
        VectorIcons.drawWeatherCloud(dc, colMidX, iconY, colorWhite);
        var minMaxStr = Lang.format("$1$/$2$", [maxTemp, minTemp]);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, textY, Graphics.FONT_SMALL, minMaxStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Right Column: Next Sun Event + Sun Icon
        var sunEvent = SunCalc.getNextSunEvent(lastLat, lastLon, owmSunrise, owmSunset);
        VectorIcons.drawSunHorizon(dc, colRightX, iconY, colorWhite);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colRightX, textY, Graphics.FONT_SMALL, sunEvent.get(:nextEventTime) as Lang.String, Graphics.TEXT_JUSTIFY_CENTER);

        // Vertical Dividers (Grey)
        dc.setColor(colorDarkGray, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        var div1X = (cx * 0.83).toNumber();
        var div2X = (cx * 1.17).toNumber();
        dc.drawLine(div1X, iconY - 4, div1X, textY + 18);
        dc.drawLine(div2X, iconY - 4, div2X, textY + 18);
    }

    // --- 4. Center Main Time ---
    private function drawMainTime(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var clockTime = System.getClockTime();
        var hourStr = clockTime.hour.format("%02d");
        var minStr = clockTime.min.format("%02d");

        var font = Graphics.FONT_NUMBER_HOT;
        var timeY = (cy * 0.68).toNumber();

        // Hours: Solid White (Large)
        var hourX = (cx * 0.77).toNumber();
        OutlinedFontRenderer.drawSolidTimeText(dc, hourX, timeY, font, hourStr, colorWhite, Graphics.TEXT_JUSTIFY_RIGHT);

        // Minutes: Outlined Hollow White (Large)
        var minX = (cx * 0.81).toNumber();
        OutlinedFontRenderer.drawOutlinedTimeText(dc, minX, timeY, font, minStr, colorWhite, colorBlack, 3, Graphics.TEXT_JUSTIFY_LEFT);

        // Seconds in Active Mode - Aligned Right at the 3 o'clock Outer Rim
        if (isAwake) {
            var secStr = clockTime.sec.format("%02d");
            var secX = (cx * 1.95).toNumber();
            var secY = cy - 8;
            dc.setColor(colorMetallicTick, Graphics.COLOR_TRANSPARENT);
            dc.drawText(secX, secY, Graphics.FONT_TINY, secStr, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    // --- 5. Lower Section ---
    private function drawLowerSection(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var rowY = (cy * 1.20).toNumber();
        var textY = rowY;
        var iconY = rowY + 20;

        var colLeftX = (cx * 0.65).toNumber();
        var colMidX = cx;
        var colRightX = (cx * 1.35).toNumber();

        // Left Column: Weekly Intensity Minutes + Intensity Icon
        var intensityMins = ActivityHistoryHelper.getWeeklyIntensityMinutes();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colLeftX, textY, Graphics.FONT_SMALL, intensityMins.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawIntensityIcon(dc, colLeftX, iconY, colorWhite);

        // Center Column: Current Heart Rate + Heart ECG Icon
        var curHR = ActivityHistoryHelper.getCurrentHeartRate();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, textY, Graphics.FONT_SMALL, curHR.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawHeartWithPulse(dc, colMidX, iconY, colorWhite);

        // Right Column: Today's Steps + Footsteps Icon
        var actInfo = ActivityMonitor.getInfo();
        var todaySteps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 7300;
        var stepsStr = ActivityHistoryHelper.formatStepsShort(todaySteps);
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colRightX, textY, Graphics.FONT_SMALL, stepsStr, Graphics.TEXT_JUSTIFY_CENTER);
        VectorIcons.drawFootsteps(dc, colRightX, iconY, colorWhite);

        // Vertical Dividers (Grey)
        dc.setColor(colorDarkGray, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        var div1X = (cx * 0.83).toNumber();
        var div2X = (cx * 1.17).toNumber();
        dc.drawLine(div1X, textY - 2, div1X, iconY + 8);
        dc.drawLine(div2X, textY - 2, div2X, iconY + 8);

        // Bottom Center Under Heart Icon: 7-Day Average Resting Heart Rate
        var rhr = ActivityHistoryHelper.get7DayAverageRHR();
        var rhrY = (cy * 1.50).toNumber();
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, rhrY, Graphics.FONT_SMALL, rhr.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
