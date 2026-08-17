import Toybox.Graphics;
import Toybox.Math;

class VectorIcons {

    // 1. Mountain Peak Icon (Elevation)
    static function drawMountain(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Main peak
        var peak1 = [
            [x, y - 6],
            [x - 8, y + 5],
            [x + 5, y + 5]
        ];
        dc.fillPolygon(peak1);

        // Secondary peak
        var peak2 = [
            [x + 4, y - 3],
            [x - 2, y + 5],
            [x + 8, y + 5]
        ];
        dc.fillPolygon(peak2);

        // Snow-cap separation line
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x - 2, y - 1, x + 2, y + 2);
    }

    // 2. Weather Cloud Icon (OWM Min/Max)
    static function drawWeatherCloud(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        // Cloud body circles
        dc.fillCircle(x - 4, y + 1, 5);
        dc.fillCircle(x + 2, y, 6);
        dc.fillCircle(x + 7, y + 2, 4);
        // Base rectangle
        dc.fillRectangle(x - 4, y + 2, 12, 4);

        // Sun disc
        dc.drawCircle(x - 6, y - 3, 2);
    }

    // 3. Sun Horizon Icon (Sunrise/Sunset)
    static function drawSunHorizon(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        // Horizon line
        dc.drawLine(x - 8, y + 4, x + 8, y + 4);

        // Half sun disc
        dc.fillCircle(x, y + 3, 5);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 7, y + 5, 14, 5);

        // Radiating rays
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, y - 5, x, y - 2);         // Top ray
        dc.drawLine(x - 6, y - 3, x - 3, y - 1); // Left ray
        dc.drawLine(x + 6, y - 3, x + 3, y - 1); // Right ray
    }

    // 4. Intensity / Runner Icon
    static function drawIntensityIcon(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        // Head
        dc.fillCircle(x + 1, y - 5, 2);

        // Body / Torso
        dc.drawLine(x + 1, y - 3, x - 1, y + 1);

        // Legs (Running stance)
        dc.drawLine(x - 1, y + 1, x - 5, y + 5);
        dc.drawLine(x - 1, y + 1, x + 4, y + 5);

        // Arms
        dc.drawLine(x, y - 1, x - 4, y);
        dc.drawLine(x, y - 1, x + 4, y - 2);
    }

    // 5. Heart with ECG Pulse Line Icon
    static function drawHeartWithPulse(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        // Draw Heart shape
        dc.fillCircle(x - 3, y - 3, 3);
        dc.fillCircle(x + 3, y - 3, 3);
        var tri = [
            [x - 7, y - 1],
            [x + 7, y - 1],
            [x, y + 7]
        ];
        dc.fillPolygon(tri);

        // Pulse line across heart
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - 6, y + 1, x - 2, y + 1);
        dc.drawLine(x - 2, y + 1, x - 1, y - 3);
        dc.drawLine(x - 1, y - 3, x + 1, y + 3);
        dc.drawLine(x + 1, y + 3, x + 2, y + 1);
        dc.drawLine(x + 2, y + 1, x + 6, y + 1);
    }

    // 6. Footprints / Shoes Icon
    static function drawFootsteps(dc as Graphics.Dc, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        // Left foot
        dc.fillCircle(x - 3, y + 3, 3);
        dc.fillCircle(x - 4, y - 2, 2);

        // Right foot (offset forward)
        dc.fillCircle(x + 3, y + 1, 3);
        dc.fillCircle(x + 2, y - 4, 2);
    }
}
