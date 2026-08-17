import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

(:background)
class Fenix7WatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        // Register background temporal event for OpenWeatherMap if supported
        if (Toybox.System has :ServiceDelegate) {
            var updateInterval = Storage.getValue("WeatherUpdateInterval");
            if (updateInterval == null || updateInterval < 5) {
                updateInterval = 20; // Default 20 minutes
            }
            try {
                Background.registerForTemporalEvent(new Time.Duration(updateInterval * 60));
            } catch (e) {
                System.println("Temporal event registration exception: " + e.getErrorMessage());
            }
        }
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [ new Fenix7WatchFaceView() ];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new BackgroundServiceDelegate() ];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        if (data instanceof Dictionary) {
            var weatherData = data as Dictionary;
            if (weatherData.hasKey("temp")) {
                Storage.setValue("OwmTemp", weatherData.get("temp"));
            }
            if (weatherData.hasKey("tempMin")) {
                Storage.setValue("OwmTempMin", weatherData.get("tempMin"));
            }
            if (weatherData.hasKey("tempMax")) {
                Storage.setValue("OwmTempMax", weatherData.get("tempMax"));
            }
            if (weatherData.hasKey("rain1h")) {
                Storage.setValue("OwmRain1h", weatherData.get("rain1h"));
            }
            if (weatherData.hasKey("pop")) {
                Storage.setValue("OwmPop", weatherData.get("pop"));
            }
            if (weatherData.hasKey("windSpeed")) {
                Storage.setValue("OwmWindSpeed", weatherData.get("windSpeed"));
            }
            if (weatherData.hasKey("windDeg")) {
                Storage.setValue("OwmWindDeg", weatherData.get("windDeg"));
            }
            if (weatherData.hasKey("sunrise")) {
                Storage.setValue("OwmSunrise", weatherData.get("sunrise"));
            }
            if (weatherData.hasKey("sunset")) {
                Storage.setValue("OwmSunset", weatherData.get("sunset"));
            }
            if (weatherData.hasKey("timestamp")) {
                Storage.setValue("OwmLastUpdated", weatherData.get("timestamp"));
            }
            WatchUi.requestUpdate();
        }
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}
