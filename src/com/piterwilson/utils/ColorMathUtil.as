package com.piterwilson.utils 
{
    public class ColorMathUtil extends Object
    {
        public function ColorMathUtil()
        {
            super();
            return;
        }

        public static function RGBToHex(arg1:uint, arg2:uint, arg3:uint):uint
        {
            var loc1:*;
            return loc1 = arg1 << 16 | arg2 << 8 | arg3;
        }

        public static function HexToRGB(arg1:uint):Array
        {
            var loc1:*=[];
            var loc2:*=arg1 >> 16 & 255;
            var loc3:*=arg1 >> 8 & 255;
            var loc4:*=arg1 & 255;
            loc1.push(loc2, loc3, loc4);
            return loc1;
        }

        public static function HexToDeci(arg1:String):uint
        {
            if (arg1.substr(0, 2) != "0x") 
            {
                arg1 = "0x" + arg1;
            }
            return new uint(arg1);
        }

        public static function hexToHsv(arg1:uint):Array
        {
            var loc1:*=HexToRGB(arg1);
            return RGBtoHSV(loc1[0], loc1[1], loc1[2]);
        }

        public static function hsvToHex(arg1:Number, arg2:Number, arg3:Number):uint
        {
            var loc1:*=HSVtoRGB(arg1, arg2, arg3);
            return RGBToHex(loc1[0], loc1[1], loc1[2]);
        }

        public static function RGBtoHSV(arg1:uint, arg2:uint, arg3:uint):Array
        {
            var loc1:*=Math.max(arg1, arg2, arg3);
            var loc2:*=Math.min(arg1, arg2, arg3);
            var loc3:*=0;
            var loc4:*=0;
            var loc5:*=0;
            var loc6:*=[];
            if (loc1 != loc2) 
            {
                if (loc1 != arg1) 
                {
                    if (loc1 != arg2) 
                    {
                        if (loc1 == arg3) 
                        {
                            loc3 = 60 * (arg1 - arg2) / (loc1 - loc2) + 240;
                        }
                    }
                    else 
                    {
                        loc3 = 60 * (arg3 - arg1) / (loc1 - loc2) + 120;
                    }
                }
                else 
                {
                    loc3 = (60 * (arg2 - arg3) / (loc1 - loc2) + 360) % 360;
                }
            }
            else 
            {
                loc3 = 0;
            }
            loc5 = loc1;
            if (loc1 != 0) 
            {
                loc4 = (loc1 - loc2) / loc1;
            }
            else 
            {
                loc4 = 0;
            }
            return loc6 = [Math.round(loc3), Math.round(loc4 * 100), Math.round(loc5 / 255 * 100)];
        }

        public static function HSVtoRGB(arg1:Number, arg2:Number, arg3:Number):Array
        {
            var loc1:*=0;
            var loc2:*=0;
            var loc3:*=0;
            var loc4:*=[];
            var loc5:*=arg2 / 100;
            var loc6:*=arg3 / 100;
            var loc7:*=Math.floor(arg1 / 60) % 6;
            var loc8:*=arg1 / 60 - Math.floor(arg1 / 60);
            var loc9:*=loc6 * (1 - loc5);
            var loc10:*=loc6 * (1 - loc8 * loc5);
            var loc11:*=loc6 * (1 - (1 - loc8) * loc5);
            var loc12:*=loc7;
            switch (loc12) 
            {
                case 0:
                {
                    loc1 = loc6;
                    loc2 = loc11;
                    loc3 = loc9;
                    break;
                }
                case 1:
                {
                    loc1 = loc10;
                    loc2 = loc6;
                    loc3 = loc9;
                    break;
                }
                case 2:
                {
                    loc1 = loc9;
                    loc2 = loc6;
                    loc3 = loc11;
                    break;
                }
                case 3:
                {
                    loc1 = loc9;
                    loc2 = loc10;
                    loc3 = loc6;
                    break;
                }
                case 4:
                {
                    loc1 = loc11;
                    loc2 = loc9;
                    loc3 = loc6;
                    break;
                }
                case 5:
                {
                    loc1 = loc6;
                    loc2 = loc9;
                    loc3 = loc10;
                    break;
                }
            }
            return loc4 = [Math.round(loc1 * 255), Math.round(loc2 * 255), Math.round(loc3 * 255)];
        }
    }
}
