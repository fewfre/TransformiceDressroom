package com.piterwilson.utils 
{
    public class ColorMathUtil
    {
        public static function RGBToHex(r:uint, g:uint, b:uint):uint {
            return r << 16 | g << 8 | b;
        }

        public static function HexToRGB(color:uint):Array {
            return [ color >> 16 & 255 , color >> 8 & 255 , color & 255];
        }

        public static function HexToDeci(hexString:String):uint {
            if (hexString.substr(0, 2) != "0x") {
                hexString = "0x" + hexString;
            }
            return new uint(hexString);
        }

        public static function hexToHsv(color:uint):Array {
            var rgb:Array=HexToRGB(color);
            return RGBtoHSV(rgb[0], rgb[1], rgb[2]);
        }

        public static function hsvToHex(h:Number, s:Number, v:Number):uint {
            var rgb:Array=HSVtoRGB(h, s, v);
            return RGBToHex(rgb[0], rgb[1], rgb[2]);
        }

        public static function RGBtoHSV(r:uint, g:uint, b:uint):Array {
            var max:Number=Math.max(r, g, b), min:Number=Math.min(r, g, b), diff:Number = max - min;
			
            var h:*=0;
            if (max != min) {
                if (max != r) {
                    if (max != g) {
                        if (max == b) {
                            h = 60 * (r - g) / diff + 240;
                        }
                    }
                    else {
                        h = 60 * (b - r) / diff + 120;
                    }
                } else {
                    h = (60 * (g - b) / diff + 360) % 360;
                }
            } else {
                h = 0;
            }
			
            var s:Number = (max == 0 ? 0 : diff / max);
            var v:Number = max / 255;
            return [Math.round(h), Math.round(s * 100), Math.round(v * 100)];
        }

        public static function HSVtoRGB(hIn:Number, sIn:Number, vIn:Number):Array {
            var r:Number=0, g:Number=0, b:Number=0;
			
			var s:Number=sIn / 100, v:Number=vIn / 100;
			
            var i:Number=Math.floor(hIn / 60);
            var f:Number=hIn / 60 - i;
			
            var p:Number = v * (1 - s);
            var q:Number = v * (1 - f * s);
            var t:Number = v * (1 - (1 - f) * s);
			
            switch (i % 6) {
                case 0: { r = v; g = t; b = p; break; }
                case 1: { r = q; g = v; b = p; break; }
                case 2: { r = p; g = v; b = t; break; }
                case 3: { r = p; g = q; b = v; break; }
                case 4: { r = t; g = p; b = v; break; }
                case 5: { r = v; g = p; b = q; break; }
            }
            return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
        }
		
		////////////////////////////////////////
		// com.paulcoyle.utils.colour
		// Originally in it's own com folder, but moved in to here to avoid 1 top level folder with 1 helper function
		////////////////////////////////////////
        internal static const paulcoyle__HEX_RANGE:Number=Math.PI / 3;

        public static function paulcoyle__angle_to_colour(angle:Number, colorMultiplier:Number=1):uint {
            var rM:Number=NaN, gM:Number=NaN, bM:Number=NaN;
            angle = angle % (2 * Math.PI);
            var bucket:Number = Math.floor(angle / paulcoyle__HEX_RANGE);
            switch (bucket)  {
                case 0: { rM = 1; bM = 0; break; }
                case 1: { gM = 1; bM = 0; break; }
                case 2: { rM = 0; gM = 1; break; }
                case 3: { rM = 0; bM = 1; break; }
                case 4: { gM = 0; bM = 1; break; }
                case 5: { rM = 1; gM = 0; break; }
            }
            if (isNaN(rM)) {
                rM = paulcoyle__magnitude_from_hex_area(angle, bucket);
            }
            else if (isNaN(gM)) {
                gM = paulcoyle__magnitude_from_hex_area(angle, bucket);
            }
            else if (isNaN(bM)) {
                bM = paulcoyle__magnitude_from_hex_area(angle, bucket);
            }
            return rM * colorMultiplier * 255 << 16 | gM * colorMultiplier * 255 << 8 | bM * colorMultiplier * 255;
        }

        internal static function paulcoyle__magnitude_from_hex_area(angle:Number, bucket:uint):Number {
            angle = angle - bucket * paulcoyle__HEX_RANGE;
            if (bucket % 2 != 0) {
                angle = paulcoyle__HEX_RANGE - angle;
            }
            return angle / paulcoyle__HEX_RANGE;
        }
    }
}
