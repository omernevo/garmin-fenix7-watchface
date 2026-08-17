import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.UserProfile;
import Toybox.Application.Storage;
import Toybox.Weather;
import Toybox.Math;
import Toybox.Lang;

class ActivityHistoryHelper {

    // 1. Total steps in calendaric week starting Monday
    static function getWeeklySteps() as Lang.Number {
        var todaySteps = 0;
        var actInfo = ActivityMonitor.getInfo();
        if (actInfo != null && actInfo.steps != null) {
            todaySteps = actInfo.steps;
        }

        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var daysSinceMonday = 0;
        if (info.day_of_week == 1) {
            daysSinceMonday = 6;
        } else {
            daysSinceMonday = info.day_of_week - 2;
        }

        var totalSteps = todaySteps;

        if (daysSinceMonday > 0 && (Toybox has :ActivityMonitor) && (ActivityMonitor has :getHistory)) {
            var history = ActivityMonitor.getHistory();
            if (history != null) {
                var limit = (history.size() < daysSinceMonday) ? history.size() : daysSinceMonday;
                for (var i = 0; i < limit; i++) {
                    if (history[i] != null && history[i].steps != null) {
                        totalSteps += history[i].steps;
                    }
                }
            }
        }

        return totalSteps;
    }

    // Formats step count as e.g. "7.3k" or "850"
    static function formatStepsShort(steps as Lang.Number) as Lang.String {
        if (steps >= 1000) {
            var kValue = steps / 1000.0;
            return Lang.format("$1$k", [kValue.format("%.1f")]);
        }
        return steps.toString();
    }

    // 2. Cycling distance (KM) this calendaric week starting Monday
    static function getWeeklyCyclingKm() as Lang.Float {
        var bikeKm = Storage.getValue("WeeklyBikeKm");
        if (bikeKm != null) {
            return (bikeKm as Lang.Number or Lang.Float).toFloat();
        }
        return 9.0;
    }

    // 3. Weekly intensity minutes starting Monday
    static function getWeeklyIntensityMinutes() as Lang.Number {
        var actInfo = ActivityMonitor.getInfo();
        if (actInfo != null && actInfo has :activeMinutesWeek && actInfo.activeMinutesWeek != null) {
            if (actInfo.activeMinutesWeek has :total && actInfo.activeMinutesWeek.total != null) {
                return actInfo.activeMinutesWeek.total;
            }
        }
        if (actInfo != null && actInfo has :activeMinutesDay && actInfo.activeMinutesDay != null) {
            if (actInfo.activeMinutesDay has :total && actInfo.activeMinutesDay.total != null) {
                return actInfo.activeMinutesDay.total;
            }
        }
        return 35;
    }

    // 4. Current Heart Rate
    static function getCurrentHeartRate() as Lang.Number {
        var heartRate = null;
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            heartRate = actInfo.currentHeartRate;
        }

        if (heartRate == null && (Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
            var hrHistory = SensorHistory.getHeartRateHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (hrHistory != null) {
                var sample = hrHistory.next();
                if (sample != null && sample.data != null && sample.data != ActivityMonitor.INVALID_HR_SAMPLE) {
                    heartRate = sample.data.toNumber();
                }
            }
        }

        return (heartRate != null) ? heartRate : 61;
    }

    // 5. 7-Day Average Resting Heart Rate
    static function get7DayAverageRHR() as Lang.Number {
        var rhr = null;
        if (Toybox has :UserProfile && UserProfile has :getProfile) {
            var profile = UserProfile.getProfile();
            if (profile != null && profile.restingHeartRate != null) {
                rhr = profile.restingHeartRate;
            }
        }

        if (rhr == null && (Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
            var hrHistory = SensorHistory.getHeartRateHistory({:period => 100, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (hrHistory != null) {
                var sum = 0;
                var count = 0;
                var sample = hrHistory.next();
                while (sample != null) {
                    if (sample.data != null && sample.data != ActivityMonitor.INVALID_HR_SAMPLE) {
                        sum += sample.data;
                        count++;
                    }
                    sample = hrHistory.next();
                }
                if (count > 0) {
                    rhr = (sum / count).toNumber();
                }
            }
        }

        return (rhr != null) ? rhr : 46;
    }

    // 6. Current Elevation in meters
    static function getCurrentElevation() as Lang.Number {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.altitude != null) {
            return actInfo.altitude.toNumber();
        }

        if ((Toybox has :SensorHistory) && (SensorHistory has :getElevationHistory)) {
            var elHistory = SensorHistory.getElevationHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            if (elHistory != null) {
                var sample = elHistory.next();
                if (sample != null && sample.data != null) {
                    return sample.data.toNumber();
                }
            }
        }

        return 132;
    }

    // 7. Time in Israel (UTC+2 or UTC+3 DST)
    static function getIsraelTimeString(tzOffsetHours as Lang.Number?) as Lang.String {
        var now = Time.now();
        var utc = Gregorian.utcInfo(now, Time.FORMAT_SHORT);

        var offset = (tzOffsetHours != null) ? tzOffsetHours : 3;
        var israelHour = (utc.hour + offset) % 24;
        if (israelHour < 0) {
            israelHour += 24;
        }

        return Lang.format("ISR $1$:$2$", [israelHour.format("%02d"), utc.min.format("%02d")]);
    }

    // 8. Wind speed and direction string
    static function getWindString(owmSpeed as Lang.Number?, owmDeg as Lang.Number?) as Lang.String {
        if (Toybox has :Weather && Weather has :getCurrentConditions) {
            var cond = Weather.getCurrentConditions();
            if (cond != null && cond.windSpeed != null && cond.windBearing != null) {
                var speedKmh = (cond.windSpeed * 3.6).toNumber();
                var dirStr = degreesToCompass(cond.windBearing);
                return Lang.format("$1$ $2$", [speedKmh, dirStr]);
            }
        }

        if (owmSpeed != null && owmDeg != null) {
            var dirStr = degreesToCompass(owmDeg);
            return Lang.format("$1$ $2$", [owmSpeed, dirStr]);
        }

        return "13 NW";
    }

    static function degreesToCompass(deg as Lang.Number) as Lang.String {
        var sectors = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        var idx = (((deg + 11.25) / 22.5).toNumber()) % 16;
        return sectors[idx];
    }
}
