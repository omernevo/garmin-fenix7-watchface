import Toybox.Graphics;

class OutlinedFontRenderer {

    // Draws solid font glyphs
    static function drawSolidTimeText(dc as Graphics.Dc, x as Number, y as Number, font as Graphics.FontDefinition, text as String, color as Number, align as Graphics.TextJustification) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, align);
    }

    // Draws crisp hollow/outlined font glyphs
    static function drawOutlinedTimeText(dc as Graphics.Dc, x as Number, y as Number, font as Graphics.FontDefinition, text as String, outlineColor as Number, fillColor as Number, strokeWidth as Number, align as Graphics.TextJustification) as Void {
        dc.setColor(outlineColor, Graphics.COLOR_TRANSPARENT);

        // Render outline perimeter in 8 directions
        for (var dx = -strokeWidth; dx <= strokeWidth; dx++) {
            for (var dy = -strokeWidth; dy <= strokeWidth; dy++) {
                if (dx != 0 || dy != 0) {
                    // Only draw boundary ring
                    if ((dx * dx + dy * dy) <= (strokeWidth * strokeWidth + 1)) {
                        dc.drawText(x + dx, y + dy, font, text, align);
                    }
                }
            }
        }

        // Draw inner hollow core
        dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, align);
    }
}
