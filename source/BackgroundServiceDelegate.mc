import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Math;
import Toybox.Lang;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var apiKey = Storage.getValue("OwmApiKey");
        if (apiKey == null || (apiKey as Lang.String).length() == 0) {
            apiKey = "767c5a6ab53c51d09cbc74d3adc63a3f";
        }

        var loc = Position.getInfo();
        var lat = 32.0853;
        var lon = 34.7818;

        if (loc != null && loc.position != null) {
            var radians = loc.position.toRadians();
            lat = radians[0] * 180.0 / Math.PI;
            lon = radians[1] * 180.0 / Math.PI;
            Storage.setValue("LastLat", lat);
            Storage.setValue("LastLon", lon);
        } else {
            var savedLat = Storage.getValue("LastLat");
            var savedLon = Storage.getValue("LastLon");
            if (savedLat != null && savedLon != null) {
                lat = (savedLat as Lang.Float);
                lon = (savedLon as Lang.Float);
            }
        }

        makeWeatherRequest(lat.toFloat(), lon.toFloat(), apiKey as Lang.String);
    }

    function makeWeatherRequest(lat as Lang.Float, lon as Lang.Float, apiKey as Lang.String) as Void {
        var url = "https://api.openweathermap.org/data/2.5/weather";
        var params = {
            "lat" => lat.format("%.4f"),
            "lon" => lon.format("%.4f"),
            "appid" => apiKey,
            "units" => "metric"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveWeather));
    }

    function onReceiveWeather(responseCode as Lang.Number, data as Lang.Dictionary or Null) as Void {
        if (responseCode == 200 && data != null) {
            var weatherDict = {} as Lang.Dictionary;

            // Current temperature
            if (data.hasKey("main")) {
                var main = data.get("main") as Lang.Dictionary;
                if (main.hasKey("temp")) {
                    weatherDict.put("temp", (main.get("temp") as Lang.Float).toNumber());
                }
                if (main.hasKey("temp_min")) {
                    weatherDict.put("tempMin", (main.get("temp_min") as Lang.Float).toNumber());
                }
                if (main.hasKey("temp_max")) {
                    weatherDict.put("tempMax", (main.get("temp_max") as Lang.Float).toNumber());
                }
                if (main.hasKey("humidity")) {
                    weatherDict.put("humidity", main.get("humidity"));
                }
            }

            // Rain volume in next/last 1h
            var rain1h = 0.0;
            if (data.hasKey("rain")) {
                var rain = data.get("rain") as Lang.Dictionary;
                if (rain.hasKey("1h")) {
                    rain1h = (rain.get("1h") as Lang.Float);
                }
            }
            weatherDict.put("rain1h", rain1h);

            // Pop (Precipitation probability)
            var pop = 0;
            if (data.hasKey("clouds")) {
                var clouds = data.get("clouds") as Lang.Dictionary;
                if (clouds.hasKey("all")) {
                    var cloudPct = clouds.get("all") as Lang.Number;
                    if (rain1h > 0.0) {
                        pop = 100;
                    } else if (cloudPct > 80) {
                        pop = (cloudPct * 0.6).toNumber();
                    } else {
                        pop = 0;
                    }
                }
            }
            weatherDict.put("pop", pop);

            // Wind
            if (data.hasKey("wind")) {
                var wind = data.get("wind") as Lang.Dictionary;
                if (wind.hasKey("speed")) {
                    var speedMps = wind.get("speed") as Lang.Float;
                    weatherDict.put("windSpeed", (speedMps * 3.6).toNumber());
                }
                if (wind.hasKey("deg")) {
                    weatherDict.put("windDeg", wind.get("deg") as Lang.Number);
                }
            }

            // Sunrise / Sunset
            if (data.hasKey("sys")) {
                var sys = data.get("sys") as Lang.Dictionary;
                if (sys.hasKey("sunrise")) {
                    weatherDict.put("sunrise", sys.get("sunrise") as Lang.Number);
                }
                if (sys.hasKey("sunset")) {
                    weatherDict.put("sunset", sys.get("sunset") as Lang.Number);
                }
            }

            weatherDict.put("timestamp", Time.now().value());
            Background.exit(weatherDict);
        } else {
            Background.exit(null);
        }
    }
}
