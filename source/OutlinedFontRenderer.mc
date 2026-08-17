import Toybox.Graphics;
import Toybox.Lang;

class OutlinedFontRenderer {

    // Draws solid font glyphs
    static function drawSolidTimeText(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, font as Graphics.FontDefinition, text as Lang.String, color as Lang.Number, align as Graphics.TextJustification) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, align);
    }

    // Draws crisp hollow/outlined font glyphs
    static function drawOutlinedTimeText(dc as Graphics.Dc, x as Lang.Number, y as Lang.Number, font as Graphics.FontDefinition, text as Lang.String, outlineColor as Lang.Number, fillColor as Lang.Number, strokeWidth as Lang.Number, align as Graphics.TextJustification) as Void {
        dc.setColor(outlineColor, Graphics.COLOR_TRANSPARENT);

        for (var dx = -strokeWidth; dx <= strokeWidth; dx++) {
            for (var dy = -strokeWidth; dy <= strokeWidth; dy++) {
                if (dx != 0 || dy != 0) {
                    if ((dx * dx + dy * dy) <= (strokeWidth * strokeWidth + 1)) {
                        dc.drawText(x + dx, y + dy, font, text, align);
                    }
                }
            }
        }

        dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, align);
    }
}
