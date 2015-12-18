package com.adobe.images 
{
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    
    public class PNGEncoder extends Object
    {
        public function PNGEncoder()
        {
            super();
            return;
        }

        public static function encode(arg1:flash.display.BitmapData):flash.utils.ByteArray
        {
            var loc5:*=0;
            var loc6:*=0;
            var loc1:*=new flash.utils.ByteArray();
            loc1.writeUnsignedInt(2303741511);
            loc1.writeUnsignedInt(218765834);
            var loc2:*=new flash.utils.ByteArray();
            loc2.writeInt(arg1.width);
            loc2.writeInt(arg1.height);
            loc2.writeUnsignedInt(134610944);
            loc2.writeByte(0);
            writeChunk(loc1, 1229472850, loc2);
            var loc3:*=new flash.utils.ByteArray();
            var loc4:*=0;
            while (loc4 < arg1.height) 
            {
                loc3.writeByte(0);
                if (arg1.transparent) 
                {
                    loc6 = 0;
                    while (loc6 < arg1.width) 
                    {
                        loc5 = arg1.getPixel32(loc6, loc4);
                        loc3.writeUnsignedInt(uint((loc5 & 16777215) << 8 | loc5 >>> 24));
                        ++loc6;
                    }
                }
                else 
                {
                    loc6 = 0;
                    while (loc6 < arg1.width) 
                    {
                        loc5 = arg1.getPixel(loc6, loc4);
                        loc3.writeUnsignedInt(uint((loc5 & 16777215) << 8 | 255));
                        ++loc6;
                    }
                }
                ++loc4;
            }
            loc3.compress();
            writeChunk(loc1, 1229209940, loc3);
            writeChunk(loc1, 1229278788, null);
            return loc1;
        }

        internal static function writeChunk(arg1:flash.utils.ByteArray, arg2:uint, arg3:flash.utils.ByteArray):void
        {
            var loc5:*=0;
            var loc6:*=0;
            var loc7:*=0;
            if (!crcTableComputed) 
            {
                crcTableComputed = true;
                crcTable = [];
                loc6 = 0;
                while (loc6 < 256) 
                {
                    loc5 = loc6;
                    loc7 = 0;
                    while (loc7 < 8) 
                    {
                        if (loc5 & 1) 
                        {
                            loc5 = uint(uint(3988292384) ^ uint(loc5 >>> 1));
                        }
                        else 
                        {
                            loc5 = uint(loc5 >>> 1);
                        }
                        ++loc7;
                    }
                    crcTable[loc6] = loc5;
                    ++loc6;
                }
            }
            var loc1:*=0;
            if (arg3 != null) 
            {
                loc1 = arg3.length;
            }
            arg1.writeUnsignedInt(loc1);
            var loc2:*=arg1.position;
            arg1.writeUnsignedInt(arg2);
            if (arg3 != null) 
            {
                arg1.writeBytes(arg3);
            }
            var loc3:*=arg1.position;
            arg1.position = loc2;
            loc5 = 4294967295;
            var loc4:*=0;
            while (loc4 < loc3 - loc2) 
            {
                loc5 = uint(crcTable[(loc5 ^ arg1.readUnsignedByte()) & uint(255)] ^ uint(loc5 >>> 8));
                ++loc4;
            }
            loc5 = uint(loc5 ^ uint(4294967295));
            arg1.position = loc3;
            arg1.writeUnsignedInt(loc5);
            return;
        }

        
        {
            crcTableComputed = false;
        }

        internal static var crcTable:Array;

        internal static var crcTableComputed:Boolean=false;
    }
}
