import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Position;
import Toybox.Weather;
import Toybox.Lang;

class SunCalc {

    // Returns a Dictionary {:nextEventTime => "HH:MM", :isSunset => Boolean}
    static function getNextSunEvent(lastLat as Lang.Float?, lastLon as Lang.Float?, owmSunrise as Lang.Number?, owmSunset as Lang.Number?) as Lang.Dictionary {
        var now = Time.now();
        var nowInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var nowSeconds = now.value();

        // 1. Try OWM timestamps if valid and fresh (< 24 hours old)
        if (owmSunrise != null && owmSunset != null) {
            var sunriseMoment = new Time.Moment(owmSunrise);
            var sunsetMoment = new Time.Moment(owmSunset);

            if (nowSeconds < owmSunrise) {
                var info = Gregorian.info(sunriseMoment, Time.FORMAT_SHORT);
                return {
                    :nextEventTime => Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]),
                    :isSunset => false
                };
            } else if (nowSeconds < owmSunset) {
                var info = Gregorian.info(sunsetMoment, Time.FORMAT_SHORT);
                return {
                    :nextEventTime => Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]),
                    :isSunset => true
                };
            }
        }

        // 2. Astronomical calculation based on GPS position
        var lat = (lastLat != null) ? lastLat : 32.0853;
        var lon = (lastLon != null) ? lastLon : 34.7818;

        var dayOfYear = getDayOfYear(nowInfo.year, nowInfo.month, nowInfo.day);
        var times = calculateSunTimes(lat.toFloat(), lon.toFloat(), dayOfYear, nowInfo.year, nowInfo.month, nowInfo.day);

        var sunriseHour = times.get(:sunriseHour) as Lang.Number;
        var sunriseMin = times.get(:sunriseMin) as Lang.Number;
        var sunsetHour = times.get(:sunsetHour) as Lang.Number;
        var sunsetMin = times.get(:sunsetMin) as Lang.Number;

        var currentTotalMin = nowInfo.hour * 60 + nowInfo.min;
        var sunriseTotalMin = sunriseHour * 60 + sunriseMin;
        var sunsetTotalMin = sunsetHour * 60 + sunsetMin;

        if (currentTotalMin < sunriseTotalMin) {
            return {
                :nextEventTime => Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunriseMin.format("%02d")]),
                :isSunset => false
            };
        } else if (currentTotalMin < sunsetTotalMin) {
            return {
                :nextEventTime => Lang.format("$1$:$2$", [sunsetHour.format("%02d"), sunsetMin.format("%02d")]),
                :isSunset => true
            };
        } else {
            return {
                :nextEventTime => Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunriseMin.format("%02d")]),
                :isSunset => false
            };
        }
    }

    private static function getDayOfYear(year as Lang.Number, month as Lang.Number, day as Lang.Number) as Lang.Number {
        var daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
            daysInMonth[2] = 29;
        }
        var doy = 0;
        for (var i = 1; i < month; i++) {
            doy += daysInMonth[i];
        }
        return doy + day;
    }

    private static function calculateSunTimes(lat as Lang.Float, lon as Lang.Float, doy as Lang.Number, year as Lang.Number, month as Lang.Number, day as Lang.Number) as Lang.Dictionary {
        var zenith = 90.833 * Math.PI / 180.0;
        var latRad = lat * Math.PI / 180.0;
        var lngHour = lon / 15.0;

        var b = 2.0 * Math.PI * (doy - 81) / 365.0;
        var eot = 9.87 * Math.sin(2.0 * b) - 7.53 * Math.cos(b) - 1.5 * Math.sin(b);
        var decl = 23.45 * Math.sin(b) * Math.PI / 180.0;

        var cosH = (Math.cos(zenith) - Math.sin(latRad) * Math.sin(decl)) / (Math.cos(latRad) * Math.cos(decl));
        if (cosH > 1.0) { cosH = 1.0; }
        if (cosH < -1.0) { cosH = -1.0; }

        var hRad = Math.acos(cosH);
        var hHours = (hRad * 180.0 / Math.PI) / 15.0;

        var noonUtc = 12.0 - lngHour - (eot / 60.0);
        
        var localTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var utcTime = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
        var tzOffset = localTime.hour - utcTime.hour;
        if (tzOffset < -12) { tzOffset += 24; }
        if (tzOffset > 12) { tzOffset -= 24; }

        var sunriseLocal = noonUtc - hHours + tzOffset;
        var sunsetLocal = noonUtc + hHours + tzOffset;

        while (sunriseLocal < 0.0) { sunriseLocal += 24.0; }
        while (sunriseLocal >= 24.0) { sunriseLocal -= 24.0; }
        while (sunsetLocal < 0.0) { sunsetLocal += 24.0; }
        while (sunsetLocal >= 24.0) { sunsetLocal -= 24.0; }

        var riseH = sunriseLocal.toNumber();
        var riseM = ((sunriseLocal - riseH) * 60.0).toNumber();

        var setH = sunsetLocal.toNumber();
        var setM = ((sunsetLocal - setH) * 60.0).toNumber();

        return {
            :sunriseHour => riseH,
            :sunriseMin => riseM,
            :sunsetHour => setH,
            :sunsetMin => setM
        };
    }
}
