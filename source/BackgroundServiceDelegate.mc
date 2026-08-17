import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Math;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var apiKey = Storage.getValue("OwmApiKey");
        if (apiKey == null || apiKey.length() == 0) {
            apiKey = "767c5a6ab53c51d09cbc74d3adc63a3f";
        }

        var loc = Position.getInfo();
        var lat = 32.0853; // Default fallback (e.g. Tel Aviv / Central)
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
                lat = savedLat;
                lon = savedLon;
            }
        }

        makeWeatherRequest(lat, lon, apiKey);
    }

    function makeWeatherRequest(lat as Float, lon as Float, apiKey as String) as Void {
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

    function onReceiveWeather(responseCode as Number, data as Dictionary or Null) as Void {
        if (responseCode == 200 && data != null) {
            var weatherDict = {} as Dictionary;

            // Current temperature
            if (data.hasKey("main")) {
                var main = data.get("main") as Dictionary;
                if (main.hasKey("temp")) {
                    weatherDict.put("temp", (main.get("temp") as Float).toNumber());
                }
                if (main.hasKey("temp_min")) {
                    weatherDict.put("tempMin", (main.get("temp_min") as Float).toNumber());
                }
                if (main.hasKey("temp_max")) {
                    weatherDict.put("tempMax", (main.get("temp_max") as Float).toNumber());
                }
                if (main.hasKey("humidity")) {
                    weatherDict.put("humidity", main.get("humidity"));
                }
            }

            // Rain volume in next/last 1h
            var rain1h = 0.0;
            if (data.hasKey("rain")) {
                var rain = data.get("rain") as Dictionary;
                if (rain.hasKey("1h")) {
                    rain1h = (rain.get("1h") as Float);
                }
            }
            weatherDict.put("rain1h", rain1h);

            // Pop (Precipitation probability)
            // In 2.5/weather pop is not standard, we estimate or fallback to clouds/humidity or 0%
            var pop = 0;
            if (data.hasKey("clouds")) {
                var clouds = data.get("clouds") as Dictionary;
                if (clouds.hasKey("all")) {
                    var cloudPct = clouds.get("all") as Number;
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
                var wind = data.get("wind") as Dictionary;
                if (wind.hasKey("speed")) {
                    var speedMps = wind.get("speed") as Float;
                    // convert m/s to km/h (speed * 3.6)
                    weatherDict.put("windSpeed", (speedMps * 3.6).toNumber());
                }
                if (wind.hasKey("deg")) {
                    weatherDict.put("windDeg", wind.get("deg") as Number);
                }
            }

            // Sunrise / Sunset
            if (data.hasKey("sys")) {
                var sys = data.get("sys") as Dictionary;
                if (sys.hasKey("sunrise")) {
                    weatherDict.put("sunrise", sys.get("sunrise") as Number);
                }
                if (sys.hasKey("sunset")) {
                    weatherDict.put("sunset", sys.get("sunset") as Number);
                }
            }

            weatherDict.put("timestamp", Time.now().value());
            Background.exit(weatherDict);
        } else {
            Background.exit(null);
        }
    }
}
