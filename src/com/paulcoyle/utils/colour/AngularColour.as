package com.paulcoyle.utils.colour 
{
    public class AngularColour extends Object
    {
        public function AngularColour()
        {
            super();
            return;
        }

        public static function angle_to_colour(arg1:Number, arg2:Number=1):uint
        {
            var loc1:*=NaN;
            var loc2:*=NaN;
            var loc3:*=NaN;
            arg1 = arg1 % (2 * Math.PI);
            var loc4:*=Math.floor(arg1 / HEX_RANGE);
            var loc5:*=loc4;
            switch (loc5) 
            {
                case 0:
                {
                    loc1 = 1;
                    loc3 = 0;
                    break;
                }
                case 1:
                {
                    loc2 = 1;
                    loc3 = 0;
                    break;
                }
                case 2:
                {
                    loc1 = 0;
                    loc2 = 1;
                    break;
                }
                case 3:
                {
                    loc1 = 0;
                    loc3 = 1;
                    break;
                }
                case 4:
                {
                    loc2 = 0;
                    loc3 = 1;
                    break;
                }
                case 5:
                {
                    loc1 = 1;
                    loc2 = 0;
                    break;
                }
            }
            if (isNaN(loc1)) 
            {
                loc1 = com.paulcoyle.utils.colour.AngularColour.magnitude_from_hex_area(arg1, loc4);
            }
            else if (isNaN(loc2)) 
            {
                loc2 = com.paulcoyle.utils.colour.AngularColour.magnitude_from_hex_area(arg1, loc4);
            }
            else if (isNaN(loc3)) 
            {
                loc3 = com.paulcoyle.utils.colour.AngularColour.magnitude_from_hex_area(arg1, loc4);
            }
            return loc1 * arg2 * 255 << 16 | loc2 * arg2 * 255 << 8 | loc3 * arg2 * 255;
        }

        internal static function magnitude_from_hex_area(arg1:Number, arg2:uint):Number
        {
            arg1 = arg1 - arg2 * HEX_RANGE;
            if (arg2 % 2 != 0) 
            {
                arg1 = HEX_RANGE - arg1;
            }
            return arg1 / HEX_RANGE;
        }

        internal static const HEX_RANGE:Number=Math.PI / 3;
    }
}
