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
    }
}
