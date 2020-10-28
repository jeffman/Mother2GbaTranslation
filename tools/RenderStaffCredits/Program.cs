using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

namespace RenderStaffCredits
{
    class Program
    {
        static readonly ushort Palette = 0xF000;
        static IDictionary<string, ushort> m12BigCharArrLookup;
        static IDictionary<string, ushort> m12SmallCharArrLookup;
        static ushort[] Arrangements;
        static readonly ushort Empty = 0x9B;
        static readonly ushort arrStart = 0x100;
        static readonly byte defaultOffset = 0xD;
        static readonly string defaultPlayerName = "MARIO";
        static int player_Y_Pos = 0;

        static void Main(string[] args)
        {
            //Load the stuff we'll use
            string[] staff_text = File.ReadAllLines(args[0]);
            string dataFolder = args[1] + Path.DirectorySeparatorChar;
            m12BigCharArrLookup = JsonConvert.DeserializeObject<Dictionary<string, ushort>>(Asset.ReadAllText("m12-big-arr-lookup.json"));
            m12SmallCharArrLookup = JsonConvert.DeserializeObject<Dictionary<string, ushort>>(Asset.ReadAllText("m12-small-arr-lookup.json"));
            
            //Prepare the empty arrangements
            Arrangements = createArrangements(getStaffTextLength(staff_text));
            int pos = 0;
            for (int i = 0; i < staff_text.Length; i++)
            {
                //Handle a single line and increment the current YPosition accordingly
                pos += handleStr(staff_text[i], Arrangements, pos);
            }

            //Save the arrangements
            File.WriteAllBytes(dataFolder + "m2-credits-arrangements_[c].bin", GBA.LZ77.Compress(convertUShortArrToByteArrLE(Arrangements)));
            //Save some data that tells us where to put the player name at runtime
            byte[] extra_things = new byte[4];
            writeIntToByteArrLE(extra_things, player_Y_Pos, 0, 2);
            writeIntToByteArrLE(extra_things, defaultPlayerName.Length, 2, 2);
            File.WriteAllBytes(dataFolder + "m2-credits-extra-data.bin", extra_things);
            //Save some data that tells us how many vertical tiles the arrangement is long
            int arrSize = Arrangements.Length / 0x20;
            byte[] size = new byte[4];
            writeIntToByteArrLE(size, arrSize, 0, 4);
            File.WriteAllBytes(dataFolder + "m2-credits-size.bin", size);
            //Save some data that tells us where to end scrolling at runtime (in pixels)
            int scrollSize = (arrSize + defaultOffset) * 8;
            byte[] size_full = new byte[4];
            writeIntToByteArrLE(size_full, scrollSize, 0, 4);
            File.WriteAllBytes(dataFolder + "m2-credits-scroll-size.bin", size_full);
            byte[] size_minus_one = new byte[4];
            writeIntToByteArrLE(size_minus_one, scrollSize - 1, 0, 4);
            File.WriteAllBytes(dataFolder + "m2-credits-scroll-size-limit.bin", size_minus_one);

        }

        static void writeIntToByteArrLE(byte[] arr, int value, int pos, int limiter)
        {
            for (int i = 0; i < limiter; i++)
                arr[pos + i] = (byte)((value >> (8 * i)) & 0xFF);
        }

        static byte[] convertUShortArrToByteArrLE(ushort[] arr)
        {
            byte[] newArr = new byte[arr.Length * 2];
            for (int i = 0; i < arr.Length; i++)
            {
                newArr[(i * 2)] = (byte)((arr[i]) & 0xFF);
                newArr[(i * 2) + 1] = (byte)((arr[i] >> 8) & 0xFF);
            }
            return newArr;
        }

        static int handleStr(string str, ushort[] Arrangements, int YPosition)
        {
            if (str.StartsWith("# "))
            {
                handleSmallText(getStrContent(str), Arrangements, YPosition);
                return 1;
            }
            if (str.StartsWith("- "))
            {
                handleBigText(getStrContent(str), Arrangements, YPosition);
                return 2;
            }
            if (str.StartsWith("player_name"))
            {
                //Save data that tells us where to put the player_name at runtime
                player_Y_Pos = YPosition;
                handleBigText(defaultPlayerName, Arrangements, YPosition);
                return 2;
            }
            if (str.StartsWith("> "))
                return parseEmptyArrLine(getStrContent(str));
            return 0;
        }

        static void handleBigText(string content, ushort[] Arrangements, int YPosition)
        {
            //The big text, normally, has a top tile and a bottom tile. The bottom tile is 0x20 tiles after the top tile
            content = content.ToUpper();
            int XPosition = getStrStartPos(content);
            for (int i = 0; i < content.Length; i++)
            {
                string value = content[i].ToString();
                if (m12BigCharArrLookup.ContainsKey(value))
                {
                    Arrangements[(YPosition * 0x20) + XPosition + i] = (ushort)(Palette | (arrStart + m12BigCharArrLookup[value]));
                    Arrangements[(YPosition * 0x20) + XPosition + i + 0x20] = (ushort)(Palette | (arrStart + m12BigCharArrLookup[value] + 0x20));
                }
            }
        }

        static void handleSmallText(string content, ushort[] Arrangements, int YPosition)
        {
            content = content.ToUpper();
            int XPosition = getStrStartPos(content);
            for (int i = 0; i < content.Length; i++)
            {
                string value = content[i].ToString();
                if (m12SmallCharArrLookup.ContainsKey(value))
                    Arrangements[(YPosition * 0x20) + XPosition + i] = (ushort)(Palette | (arrStart + m12SmallCharArrLookup[value]));
            }
        }

        static int getStrStartPos(string str)
        {
            int len = getStrLen(str);
            return 1 + ((0x1F - len) >> 1);
        }

        static int getStrLen(string str)
        {
            return str.Length;
        }

        static int getStaffTextLength(string[] staff_text)
        {
            int arrLen = 0;
            for (int i = 0; i < staff_text.Length; i++)
            {
                string str = staff_text[i];
                if (str.StartsWith("# "))
                    arrLen += 1;
                else if (str.StartsWith("- ") || str.StartsWith("player_name"))
                    arrLen += 2;
                else if (str.StartsWith("> "))
                    arrLen += parseEmptyArrLine(getStrContent(str));
            }
            return arrLen;
        }

        static string getStrContent(string str)
        {
            return str.Substring(2);
        }

        static int parseEmptyArrLine(string str)
        {
            return int.Parse(str);
        }

        static ushort[] createArrangements(int len)
        {
            ushort[] arrangements = new ushort[len * 0x20];
            for (int i = 0; i < len; i++)
                for (int j = 0; j < 0x20; j++)
                    arrangements[(i * 0x20) + j] = (ushort)(Palette | (Empty + arrStart));
            return arrangements;
        }
    }
}
