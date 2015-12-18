package 
{
    import flash.display.*;
    import flash.geom.*;
    
    public class Furs extends flash.display.MovieClip
    {
        public function Furs(arg1:int)
        {
            super();
            var loc1:*=arg1;
            switch (loc1) 
            {
                case NORMAL:
                {
                    this.setup_fur0("78583A");
                    break;
                }
                case NORMAL1:
                {
                    this.setup_fur0("BD9067");
                    break;
                }
                case NORMAL2:
                {
                    this.setup_fur0("593618");
                    break;
                }
                case NORMAL3:
                {
                    this.setup_fur0("8C887F");
                    break;
                }
                case NORMAL4:
                {
                    this.setup_fur0("DED7CE");
                    break;
                }
                case NORMAL5:
                {
                    this.setup_fur0("4E443A");
                    break;
                }
                case NORMAL6:
                {
                    this.setup_fur0("E3C07E");
                    break;
                }
                case NORMAL7:
                {
                    this.setup_fur0("272220");
                    break;
                }
                case FUR_1:
                {
                    this.setup_fur1();
                    break;
                }
                case FUR_2:
                {
                    this.setup_fur2();
                    break;
                }
                case FUR_3:
                {
                    this.setup_fur3();
                    break;
                }
                case FUR_4:
                {
                    this.setup_fur4();
                    break;
                }
                case FUR_5:
                {
                    this.setup_fur5();
                    break;
                }
                case FUR_6:
                {
                    this.setup_fur6();
                    break;
                }
                case FUR_7:
                {
                    this.setup_fur7();
                    break;
                }
                case FOX:
                {
                    this.setup_fox();
                    break;
                }
                case FUR_9:
                {
                    this.setup_fur9();
                    break;
                }
                case FUR_10:
                {
                    this.setup_fur10();
                    break;
                }
                case FUR_11:
                {
                    this.setup_fur11();
                    break;
                }
                case FUR_12:
                {
                    this.setup_fur12();
                    break;
                }
                case FUR_13:
                {
                    this.setup_fur13();
                    break;
                }
                case FUR_14:
                {
                    this.setup_fur14();
                    break;
                }
                case FUR_15:
                {
                    this.setup_fur15();
                    break;
                }
                case FUR_16:
                {
                    this.setup_fur16();
                    break;
                }
                case FUR_17:
                {
                    this.setup_fur17();
                    break;
                }
                case FUR_18:
                {
                    this.setup_fur18();
                    break;
                }
                case CHEETA:
                {
                    this.setup_cheeta();
                    break;
                }
                case RABBIT:
                {
                    this.setup_rabbit();
                    break;
                }
                default:
                {
                    this.setup_fur0("78583A");
                    break;
                }
            }
            return;
        }

        internal function setup_cheeta():*
        {
            var loc1:*=new Main.costumes.fur_c[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_c[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_c[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_c[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_c[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_c[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_c[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_c[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_c[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_c[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_c[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_c[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_c[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        public function colorFur(arg1:String):*
        {
            var loc2:*=undefined;
            var loc3:*=0;
            var loc4:*=undefined;
            var loc5:*=0;
            var loc6:*=0;
            var loc7:*=0;
            var loc8:*=0;
            var loc9:*=null;
            var loc10:*=0;
            var loc11:*=0;
            var loc12:*=0;
            var loc13:*=0;
            var loc14:*=null;
            var loc1:*=0;
            while (loc1 < this.numChildren) 
            {
                loc2 = this.getChildAt(loc1);
                if (loc2.name != "nocolor") 
                {
                    if (loc2.numChildren > 1) 
                    {
                        loc3 = 0;
                        while (loc3 < loc2.numChildren) 
                        {
                            if ((loc4 = loc2.getChildAt(loc3)).name == "c0") 
                            {
                                loc6 = (loc5 = int("0x" + arg1)) >> 16 & 255;
                                loc7 = loc5 >> 8 & 255;
                                loc8 = loc5 & 255;
                                loc9 = new flash.geom.ColorTransform(loc6 / 128, loc7 / 128, loc8 / 128);
                                loc4.transform.colorTransform = loc9;
                            }
                            ++loc3;
                        }
                    }
                    else 
                    {
                        loc11 = (loc10 = int("0x" + arg1)) >> 16 & 255;
                        loc12 = loc10 >> 8 & 255;
                        loc13 = loc10 & 255;
                        loc14 = new flash.geom.ColorTransform(loc11 / 128, loc12 / 128, loc13 / 128);
                        loc2.transform.colorTransform = loc14;
                    }
                }
                ++loc1;
            }
            return;
        }

        internal function setup_fur0(arg1:String):*
        {
            var loc1:*=new Main.costumes.fur_0[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_0[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*;
            (loc3 = new Main.costumes.fur_0[2]()).x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_0[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_0[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_0[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_0[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_0[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_0[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_0[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_0[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_0[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_0[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            this.colorFur(arg1);
            return;
        }

        internal function setup_fur1():*
        {
            var loc1:*=new Main.costumes.fur_1[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_1[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_1[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_1[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_1[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_1[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_1[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_1[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_1[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_1[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_1[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_1[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_1[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur2():*
        {
            var loc1:*=new Main.costumes.fur_2[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_2[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_2[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_2[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_2[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_2[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_2[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_2[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_2[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_2[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_2[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_2[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_2[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur3():*
        {
            var loc1:*=new Main.costumes.fur_3[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_3[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_3[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_3[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_3[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_3[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_3[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_3[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_3[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_3[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_3[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_3[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_3[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur4():*
        {
            var loc1:*=new Main.costumes.fur_4[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_4[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_4[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_4[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_4[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_4[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_4[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_4[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_4[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_4[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_4[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_4[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_4[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur5():*
        {
            var loc1:*=new Main.costumes.fur_5[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_5[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_5[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_5[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_5[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_5[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_5[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_5[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_5[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_5[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_5[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_5[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_5[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur6():*
        {
            var loc1:*=new Main.costumes.fur_6[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_6[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_6[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_6[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_6[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_6[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_6[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_6[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_6[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_6[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_6[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_6[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_6[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur7():*
        {
            var loc1:*=new Main.costumes.fur_7[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_7[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_7[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_7[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_7[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_7[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_7[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_7[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_7[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_7[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_7[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_7[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_7[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur9():*
        {
            var loc1:*=new Main.costumes.fur_9[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_9[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_9[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_9[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_9[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_9[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_9[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_9[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_9[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_9[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_9[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_9[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_9[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur10():*
        {
            var loc1:*=new Main.costumes.fur_10[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_10[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_10[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_10[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_10[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_10[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_10[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_10[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_10[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_10[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_10[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_10[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_10[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur11():*
        {
            var loc1:*=new Main.costumes.fur_11[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_11[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_11[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_11[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_11[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_11[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_11[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_11[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_11[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_11[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_11[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_11[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_11[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur12():*
        {
            var loc1:*=new Main.costumes.fur_12[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_12[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_12[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_12[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_12[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_12[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_12[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_12[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_12[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_12[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_12[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_12[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_12[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur13():*
        {
            var loc1:*=new Main.costumes.fur_13[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_13[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_13[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_13[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_13[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_13[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_13[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_13[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_13[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_13[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_13[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_13[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_13[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur14():*
        {
            var loc1:*=new Main.costumes.fur_14[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_14[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_14[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_14[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_14[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_14[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_14[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_14[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_14[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_14[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_14[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_14[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_14[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur15():*
        {
            var loc1:*=new Main.costumes.fur_15[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_15[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_15[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_15[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_15[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_15[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_15[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_15[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_15[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_15[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_15[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_15[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_15[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur16():*
        {
            var loc1:*=new Main.costumes.fur_16[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_16[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_16[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_16[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_16[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_16[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_16[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_16[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_16[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_16[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_16[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_16[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_16[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur17():*
        {
            var loc1:*=new Main.costumes.fur_17[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_17[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_17[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_17[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_17[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_17[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_17[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_17[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_17[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_17[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_17[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_17[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_17[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fur18():*
        {
            var loc1:*=new Main.costumes.fur_18[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_18[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_18[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_18[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_18[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_18[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_18[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_18[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_18[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_18[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_18[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_18[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_18[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_fox():*
        {
            var loc1:*=new Main.costumes.fur_8[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_8[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_8[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_8[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_8[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_8[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_8[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_8[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_8[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_8[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_8[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_8[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_8[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        internal function setup_rabbit():*
        {
            var loc1:*=new Main.costumes.fur_r[0]();
            loc1.x = 5.75;
            loc1.y = -22.8;
            addChild(loc1);
            var loc2:*=new Main.costumes.fur_r[1]();
            loc2.name = "nocolor";
            loc2.x = 3.95;
            loc2.y = 13.05;
            addChild(loc2);
            var loc3:*=new Main.costumes.fur_r[2]();
            loc3.x = 1.4;
            loc3.y = 5.95;
            addChild(loc3);
            var loc4:*;
            (loc4 = new Main.costumes.fur_r[3]()).x = 8.3;
            loc4.y = 1.05;
            addChild(loc4);
            var loc5:*;
            (loc5 = new Main.costumes.fur_r[4]()).name = "nocolor";
            loc5.x = -4.25;
            loc5.y = 14.2;
            addChild(loc5);
            var loc6:*;
            (loc6 = new Main.costumes.fur_r[5]()).name = "nocolor";
            loc6.x = -23.35;
            loc6.y = -16.35;
            addChild(loc6);
            var loc7:*;
            (loc7 = new Main.costumes.fur_r[6]()).x = -0.8;
            loc7.y = 3.5;
            addChild(loc7);
            var loc8:*;
            (loc8 = new Main.costumes.fur_r[7]()).name = "nocolor";
            loc8.x = -13.5;
            loc8.y = -8.05;
            addChild(loc8);
            var loc9:*;
            (loc9 = new Main.costumes.fur_r[8]()).x = -4.5;
            loc9.y = 7.3;
            addChild(loc9);
            var loc10:*;
            (loc10 = new Main.costumes.fur_r[9]()).x = 1.85;
            loc10.y = 1.7;
            addChild(loc10);
            var loc11:*;
            (loc11 = new Main.costumes.fur_r[10]()).x = 4.9;
            loc11.y = -9.6;
            addChild(loc11);
            var loc12:*;
            (loc12 = new Main.costumes.fur_r[11]()).name = "nocolor";
            loc12.x = 4.75;
            loc12.y = -10.85;
            addChild(loc12);
            var loc13:*;
            (loc13 = new Main.costumes.fur_r[12]()).x = -6.2;
            loc13.y = -16.6;
            addChild(loc13);
            return;
        }

        
        {
            NORMAL = 0;
            NORMAL1 = 1;
            NORMAL2 = 2;
            NORMAL3 = 3;
            NORMAL4 = 4;
            NORMAL5 = 5;
            NORMAL6 = 6;
            NORMAL7 = 7;
            FUR_1 = 8;
            FUR_2 = 9;
            FUR_3 = 10;
            FUR_4 = 11;
            FUR_5 = 12;
            FUR_6 = 13;
            FUR_7 = 14;
            FOX = 15;
            FUR_9 = 16;
            FUR_10 = 17;
            FUR_11 = 18;
            FUR_12 = 19;
            FUR_13 = 20;
            FUR_14 = 21;
            FUR_15 = 22;
            FUR_16 = 23;
            FUR_17 = 24;
            FUR_18 = 25;
            CHEETA = 26;
            RABBIT = 27;
        }

        public static var NORMAL:int=0;

        public static var NORMAL1:int=1;

        public static var NORMAL2:int=2;

        public static var NORMAL3:int=3;

        public static var NORMAL4:int=4;

        public static var NORMAL5:int=5;

        public static var NORMAL6:int=6;

        public static var NORMAL7:int=7;

        public static var FUR_1:int=8;

        public static var FUR_2:int=9;

        public static var FUR_3:int=10;

        public static var FUR_4:int=11;

        public static var FUR_5:int=12;

        public static var FUR_6:int=13;

        public static var FUR_7:int=14;

        public static var FOX:int=15;

        public var current_fur:int=0;

        public static var FUR_10:int=17;

        public static var FUR_11:int=18;

        public static var FUR_12:int=19;

        public static var FUR_13:int=20;

        public static var FUR_14:int=21;

        public static var FUR_9:int=16;

        public static var FUR_16:int=23;

        public static var FUR_17:int=24;

        public static var FUR_18:int=25;

        public static var CHEETA:int=26;

        public static var RABBIT:int=27;

        public static var FUR_15:int=22;
    }
}
