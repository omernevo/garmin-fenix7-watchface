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

        // 2. Draw 6 Metallic Divider Ticks at EXACTLY 1, 3, 5, 7, 9, 11 o'clock on outer rim
        drawPerimeterTicks(dc, cx, cy);

        // 3. Draw 6 Perimeter Data Fields in a clean ring around the watchface
        drawPerimeterData(dc, cx, cy);

        // 4. Draw Upper Section (Current Temp, Elevation, Min/Max + Weather icon, Sun Event)
        drawUpperSection(dc, cx, cy);

        // 5. Draw Center Main Time (Centered Hours + Outlined Minutes + Seconds/Rest Bar)
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

        // Radial ticks at 1, 5, 7, 11 o'clock (30°, 150°, 210°, 330°)
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
        // In Rest Mode: Metallic horizontal tick bar at the rim
        if (!isAwake) {
            dc.fillRectangle(cx + rInner, cy - 2, (rOuter - rInner), 4);
        }
    }

    // --- 2. Perimeter Data Fields centered within the 6 sectors around the rim ---
    private function drawPerimeterData(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var owmSpeed = Storage.getValue("OwmWindSpeed") as Lang.Number?;
        var owmDeg = Storage.getValue("OwmWindDeg") as Lang.Number?;
        var pop = Storage.getValue("OwmPop") as Lang.Number?;
        var rain1h = Storage.getValue("OwmRain1h") as Lang.Float?;
        var tzOffset = Storage.getValue("IsraelTimezoneOffset") as Lang.Number?;

        if (pop == null) { pop = 100; }
        if (rain1h == null) { rain1h = 0.0; }

        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);

        // 12 o'clock Sector (Top): Wind (e.g. "13 NW")
        var windStr = ActivityHistoryHelper.getWindString(owmSpeed, owmDeg);
        dc.drawText(cx, 14, Graphics.FONT_XTINY, windStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 2 o'clock Sector (Top-Right): Precipitation (e.g. "100% 0mm")
        var precipStr = Lang.format("$1$% $2$mm", [pop, rain1h.format("%.0f")]);
        dc.drawText(206, 60, Graphics.FONT_XTINY, precipStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 10 o'clock Sector (Top-Left): Israel Time (e.g. "ISR 10:07")
        var isrStr = ActivityHistoryHelper.getIsraelTimeString(tzOffset);
        dc.drawText(54, 60, Graphics.FONT_XTINY, isrStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 8 o'clock Sector (Bottom-Left): Weekly Cycling KM (e.g. "BIKE 9.0")
        var bikeKm = ActivityHistoryHelper.getWeeklyCyclingKm();
        var bikeStr = Lang.format("BIKE $1$", [bikeKm.format("%.1f")]);
        dc.drawText(54, 200, Graphics.FONT_XTINY, bikeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 6 o'clock Sector (Bottom): Date (e.g. "MON AUG 17")
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week.toUpper(), info.month.toUpper(), info.day]);
        dc.drawText(cx, 244, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 4 o'clock Sector (Bottom-Right): Weekly Steps (e.g. "STEP 7.3k")
        var weeklySteps = ActivityHistoryHelper.getWeeklySteps();
        var weeklyStepsStr = Lang.format("STEP $1$", [ActivityHistoryHelper.formatStepsShort(weeklySteps)]);
        dc.drawText(206, 200, Graphics.FONT_XTINY, weeklyStepsStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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

        // Current Temp (Center, under wind)
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 34, Graphics.FONT_TINY, curTemp.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var iconY = 56;
        var textY = 66;

        var colLeftX = 84;
        var colMidX = cx;
        var colRightX = 176;

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
        dc.drawLine(108, iconY - 4, 108, textY + 14);
        dc.drawLine(152, iconY - 4, 152, textY + 14);
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
        var timeY = 88;

        // Hours: Solid White
        OutlinedFontRenderer.drawSolidTimeText(dc, startX, timeY, font, hourStr, colorWhite, Graphics.TEXT_JUSTIFY_LEFT);

        // Minutes: Outlined Hollow White with black center
        var minX = startX + hourW + gap;
        OutlinedFontRenderer.drawOutlinedTimeText(dc, minX, timeY, font, minStr, colorWhite, colorBlack, 2, Graphics.TEXT_JUSTIFY_LEFT);

        // Seconds in Active Mode - Aligned Right at the 3 o'clock Outer Rim
        if (isAwake) {
            var secStr = clockTime.sec.format("%02d");
            dc.setColor(colorMetallicTick, Graphics.COLOR_TRANSPARENT);
            dc.drawText(234, cy, Graphics.FONT_XTINY, secStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // --- 5. Lower Section ---
    private function drawLowerSection(dc as Graphics.Dc, cx as Lang.Number, cy as Lang.Number) as Void {
        var textY = 158;
        var iconY = 174;

        var colLeftX = 84;
        var colMidX = cx;
        var colRightX = 176;

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
        dc.drawLine(108, textY - 2, 108, iconY + 8);
        dc.drawLine(152, textY - 2, 152, iconY + 8);

        // Bottom Center Under Heart Icon: 7-Day Average Resting Heart Rate
        var rhr = ActivityHistoryHelper.get7DayAverageRHR();
        var rhrY = 194;
        dc.setColor(colorWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(colMidX, rhrY, Graphics.FONT_XTINY, rhr.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}
