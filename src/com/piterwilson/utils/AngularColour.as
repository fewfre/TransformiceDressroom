package com.piterwilson.utils 
{
	////////////////////////////////////////
	// com.paulcoyle.utils.colour
	// Originally in it's own com folder, but moved in to here to avoid a top level folder with
	// only one helper function that's only used by this library 
	////////////////////////////////////////
    public class AngularColour
    {
        private static const HEX_RANGE:Number=Math.PI / 3;

        public static function angle_to_colour(angle:Number, colorMultiplier:Number=1):uint {
            var rM:Number=NaN, gM:Number=NaN, bM:Number=NaN;
            angle = angle % (2 * Math.PI);
            var bucket:Number = Math.floor(angle / HEX_RANGE);
            switch (bucket)  {
                case 0: { rM = 1; bM = 0; break; }
                case 1: { gM = 1; bM = 0; break; }
                case 2: { rM = 0; gM = 1; break; }
                case 3: { rM = 0; bM = 1; break; }
                case 4: { gM = 0; bM = 1; break; }
                case 5: { rM = 1; gM = 0; break; }
            }
            if (isNaN(rM)) {
                rM = magnitude_from_hex_area(angle, bucket);
            }
            else if (isNaN(gM)) {
                gM = magnitude_from_hex_area(angle, bucket);
            }
            else if (isNaN(bM)) {
                bM = magnitude_from_hex_area(angle, bucket);
            }
            return rM * colorMultiplier * 255 << 16 | gM * colorMultiplier * 255 << 8 | bM * colorMultiplier * 255;
        }

        private static function magnitude_from_hex_area(angle:Number, bucket:uint):Number {
            angle = angle - bucket * HEX_RANGE;
            if (bucket % 2 != 0) {
                angle = HEX_RANGE - angle;
            }
            return angle / HEX_RANGE;
        }
	}
}