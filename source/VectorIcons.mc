import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;

class VectorIcons {

    // 1. Mountain Peak Icon (Elevation)
    static function drawMountain(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        var peak1 = [
            [x, y - 5],
            [x - 6, y + 4],
            [x + 4, y + 4]
        ];
        dc.fillPolygon(peak1);

        var peak2 = [
            [x + 3, y - 2],
            [x - 1, y + 4],
            [x + 7, y + 4]
        ];
        dc.fillPolygon(peak2);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x - 2, y, x + 2, y + 2);
    }

    // 2. Dynamic Weather Condition Icon (OWM: Clear, Clouds, Rain, Snow, Thunderstorm, Mist)
    static function drawWeatherCondition(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, condition as Lang.String?, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (condition == null) {
            condition = "Clouds";
        }

        if (condition.equals("Clear")) {
            // Sunny / Clear Sun
            dc.setPenWidth(1);
            dc.fillCircle(x, y, 3);
            dc.drawLine(x, y - 5, x, y - 4);
            dc.drawLine(x, y + 4, x, y + 5);
            dc.drawLine(x - 5, y, x - 4, y);
            dc.drawLine(x + 4, y, x + 5, y);
            dc.drawLine(x - 4, y - 4, x - 3, y - 3);
            dc.drawLine(x + 3, y + 3, x + 4, y + 4);
            dc.drawLine(x + 3, y - 3, x + 4, y - 4);
            dc.drawLine(x - 4, y + 4, x - 3, y + 3);
        } else if (condition.equals("Rain") || condition.equals("Drizzle")) {
            // Cloud with Rain drops
            drawCloudBody(dc, x, y - 2);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            dc.drawLine(x - 3, y + 3, x - 4, y + 5);
            dc.drawLine(x, y + 3, x - 1, y + 5);
            dc.drawLine(x + 3, y + 3, x + 2, y + 5);
        } else if (condition.equals("Thunderstorm")) {
            // Cloud with Lightning
            drawCloudBody(dc, x, y - 2);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            dc.drawLine(x + 1, y + 2, x - 1, y + 4);
            dc.drawLine(x - 1, y + 4, x + 2, y + 4);
            dc.drawLine(x + 2, y + 4, x, y + 6);
        } else if (condition.equals("Snow")) {
            // Cloud with Snow
            drawCloudBody(dc, x, y - 2);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawPoint(x - 3, y + 4);
            dc.drawPoint(x, y + 5);
            dc.drawPoint(x + 3, y + 4);
        } else if (condition.equals("Mist") || condition.equals("Fog") || condition.equals("Haze")) {
            // Mist lines
            dc.setPenWidth(1);
            dc.drawLine(x - 5, y - 2, x + 5, y - 2);
            dc.drawLine(x - 7, y + 1, x + 7, y + 1);
            dc.drawLine(x - 4, y + 4, x + 4, y + 4);
        } else {
            // Default Clouds / Partly Cloudy
            drawCloudBody(dc, x, y);
        }
    }

    private static function drawCloudBody(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number) as Void {
        dc.fillCircle(x - 3, y + 1, 3);
        dc.fillCircle(x + 1, y, 4);
        dc.fillCircle(x + 5, y + 1, 3);
        dc.fillRectangle(x - 3, y + 2, 8, 2);
    }

    // 3. Sun Horizon Icon (Sunrise/Sunset)
    static function drawSunHorizon(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Horizon line
        dc.drawLine(x - 6, y + 3, x + 6, y + 3);

        // Half sun disc
        dc.fillCircle(x, y + 2, 3);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 5, y + 3, 10, 4);

        // Radiating rays
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, y - 3, x, y - 1);
        dc.drawLine(x - 4, y - 2, x - 2, y - 1);
        dc.drawLine(x + 4, y - 2, x + 2, y - 1);
    }

    // 4. Intensity / Runner Icon
    static function drawIntensityIcon(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        dc.fillCircle(x + 1, y - 4, 1);
        dc.drawLine(x + 1, y - 2, x - 1, y + 1);
        dc.drawLine(x - 1, y + 1, x - 4, y + 4);
        dc.drawLine(x - 1, y + 1, x + 3, y + 4);
        dc.drawLine(x, y - 1, x - 3, y);
        dc.drawLine(x, y - 1, x + 3, y - 2);
    }

    // 5. Heart with ECG Pulse Line Icon
    static function drawHeartWithPulse(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillCircle(x - 2, y - 2, 2);
        dc.fillCircle(x + 2, y - 2, 2);
        var tri = [
            [x - 5, y - 1],
            [x + 5, y - 1],
            [x, y + 5]
        ];
        dc.fillPolygon(tri);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - 4, y, x - 1, y);
        dc.drawLine(x - 1, y, x, y - 2);
        dc.drawLine(x, y - 2, x + 1, y + 2);
        dc.drawLine(x + 1, y + 2, x + 2, y);
        dc.drawLine(x + 2, y, x + 4, y);
    }

    // 6. Footprints / Shoes Icon
    static function drawFootsteps(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillCircle(x - 2, y + 2, 2);
        dc.fillCircle(x - 3, y - 2, 1);
        dc.fillCircle(x + 2, y, 2);
        dc.fillCircle(x + 1, y - 4, 1);
    }
}
