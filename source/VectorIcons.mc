import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;

class VectorIcons {

    // 1. Mountain Peak Icon (Elevation)
    static function drawMountain(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        var peak1 = [
            [x, y - 6],
            [x - 8, y + 5],
            [x + 5, y + 5]
        ];
        dc.fillPolygon(peak1);

        var peak2 = [
            [x + 4, y - 3],
            [x - 2, y + 5],
            [x + 8, y + 5]
        ];
        dc.fillPolygon(peak2);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x - 2, y - 1, x + 2, y + 2);
    }

    // 2. Weather Cloud Icon (OWM Min/Max)
    static function drawWeatherCloud(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillCircle(x - 4, y + 1, 5);
        dc.fillCircle(x + 2, y, 6);
        dc.fillCircle(x + 7, y + 2, 4);
        dc.fillRectangle(x - 4, y + 2, 12, 4);

        dc.drawCircle(x - 6, y - 3, 2);
    }

    // 3. Sun Horizon Icon (Sunrise/Sunset)
    static function drawSunHorizon(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        dc.drawLine(x - 8, y + 4, x + 8, y + 4);

        dc.fillCircle(x, y + 3, 5);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 7, y + 5, 14, 5);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, y - 5, x, y - 2);
        dc.drawLine(x - 6, y - 3, x - 3, y - 1);
        dc.drawLine(x + 6, y - 3, x + 3, y - 1);
    }

    // 4. Intensity / Runner Icon
    static function drawIntensityIcon(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        dc.fillCircle(x + 1, y - 5, 2);
        dc.drawLine(x + 1, y - 3, x - 1, y + 1);
        dc.drawLine(x - 1, y + 1, x - 5, y + 5);
        dc.drawLine(x - 1, y + 1, x + 4, y + 5);
        dc.drawLine(x, y - 1, x - 4, y);
        dc.drawLine(x, y - 1, x + 4, y - 2);
    }

    // 5. Heart with ECG Pulse Line Icon
    static function drawHeartWithPulse(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillCircle(x - 3, y - 3, 3);
        dc.fillCircle(x + 3, y - 3, 3);
        var tri = [
            [x - 7, y - 1],
            [x + 7, y - 1],
            [x, y + 7]
        ];
        dc.fillPolygon(tri);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - 6, y + 1, x - 2, y + 1);
        dc.drawLine(x - 2, y + 1, x - 1, y - 3);
        dc.drawLine(x - 1, y - 3, x + 1, y + 3);
        dc.drawLine(x + 1, y + 3, x + 2, y + 1);
        dc.drawLine(x + 2, y + 1, x + 6, y + 1);
    }

    // 6. Footprints / Shoes Icon
    static function drawFootsteps(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillCircle(x - 3, y + 3, 3);
        dc.fillCircle(x - 4, y - 2, 2);
        dc.fillCircle(x + 3, y + 1, 3);
        dc.fillCircle(x + 2, y - 4, 2);
    }
}
