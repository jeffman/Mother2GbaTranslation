using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

namespace RenderCastRoll
{
    class Program
    {
        static IDictionary<string, byte> m12CharByteLookup;
        static byte[] BitsToNybbleLookup;
        static readonly ushort Palette = 0xF000;
        static RenderFont[] Fonts;
        static byte[] Graphics;
        static _1bppTile emptyTile = new _1bppTile();
        static _1bppTile[] _1bppGraphics;
        static _1bppTile[] _1bppGraphics_RotX;
        static _1bppTile[] _1bppGraphics_RotY;
        static _1bppTile[] _1bppGraphics_RotXY;
        static ushort[] Arrangements;
        static readonly ushort arrStart = 0x100;

        static void Main(string[] args)
        {
            if (args.Length != 2)
                return;

            //Initialization
            string rendersJson = File.ReadAllText(args[0]);
            string dataFolder = args[1] + Path.DirectorySeparatorChar;
            Fonts = new RenderFont[2];
            Fonts[0] = new RenderFont(dataFolder, "main");
            Fonts[1] = new RenderFont(dataFolder, "saturn");
            byte[] CastGraphics = File.ReadAllBytes(dataFolder + "cast_sign_graphics.bin");
            byte[] CastArrangements = File.ReadAllBytes(dataFolder + "cast_sign_arrangements.bin");
            List<Render> renders = JsonConvert.DeserializeObject<RenderRoot>(rendersJson).Renders;
            BitsToNybbleLookup = Asset.ReadAllBytes("bits_to_nybbles.bin");
            m12CharByteLookup = JsonConvert.DeserializeObject<Dictionary<string, byte>>(Asset.ReadAllText("m12-byte-lookup.json"));
            Graphics = new byte[0x8000];
            Arrangements = new ushort[0x48E0];

            for (int i = 0; i < Arrangements.Length; i++)
                Arrangements[i] = 0x3FF; //Empty tile

            for (int i = 0; i < CastGraphics.Length; i++)
                Graphics[0x8000 - CastGraphics.Length + i] = CastGraphics[i]; //Put the CAST graphics in

            int castArrPos = readIntLE(CastArrangements, 0); //First 4 bytes are the position of the CAST arrangements
            for (int i = 0; i < ((CastArrangements.Length - 4) >> 1); i++) //Put the CAST arrangements in
            {
                Arrangements[(castArrPos / 2) + i] = readUShortLE(CastArrangements, (i * 2) + 4);
            }

            int maxTiles = 0x300 - (CastGraphics.Length / 0x20);
            _1bppGraphics = new _1bppTile[maxTiles];
            _1bppGraphics_RotX = new _1bppTile[maxTiles];
            _1bppGraphics_RotY = new _1bppTile[maxTiles];
            _1bppGraphics_RotXY = new _1bppTile[maxTiles];
            int UsedTiles = 0;
            WritingBuffer[] buffers = new WritingBuffer[renders.Count];

            //Render the text as 1bpp
            for (int i = 0; i < renders.Count; i++)
                buffers[i] = renderText(renders[i]);

            for (int i = 0; i < buffers.Length; i++)
                UsedTiles = insertInGraphics(buffers[i], UsedTiles);

            //Put the arrangements in
            for (int i = 0; i < renders.Count; i++)
            {
                int pos = buffers[i].startPos + 1 + (renders[i].Y * 0x20); //The + 1 is here because the scene's map starts from tile 1. Not tile 0
                if (renders[i].Separate_file_name == "")
                    for (int j = 0; j < buffers[i].used; j++)
                        for (int k = 0; k < WritingBuffer.yLength; k++)
                            Arrangements[pos + j + (k * 0x20)] = buffers[i].arrangements[k, j];
                else
                {
                    //This is an arrangement that changes when the game is running. Set the starting arrangements to empty
                    for (int j = 0; j < buffers[i].used; j++)
                        for (int k = 0; k < WritingBuffer.yLength; k++)
                            Arrangements[pos + j + (k * 0x20)] = 0x3FF; //Empty tile

                    //Save this in an external file
                    File.WriteAllBytes(dataFolder + "cast_roll_" + renders[i].Separate_file_name + "_arrangement.bin", prepareSeparateRender(buffers[i]));
                    File.WriteAllBytes(dataFolder + "cast_roll_" + renders[i].Separate_file_name + "_data.bin", prepareSeparateRenderData(buffers[i], renders[i]));
                    File.WriteAllBytes(dataFolder + "cast_roll_" + renders[i].Separate_file_name + "_size.bin", prepareSeparateRenderSize(buffers[i]));
                }
            }

            //Convert the 1bpp tiles to 4bpp
            for (int tile = 0; tile < UsedTiles; tile++)
            {
                int basePos = (tile * 0x20) + 0x2000;
                _1bppTile pre_converted_tile = _1bppGraphics[tile];
                for (int i = 0; i < 8; i++)
                {
                    int row = readIntLE(BitsToNybbleLookup, pre_converted_tile.getRow(i) * 4);
                    for (int j = 0; j < 4; j++)
                        Graphics[basePos + (i * 4) + j] = (byte)((row >> (j * 8)) & 0xFF);
                }
            }

            //File.WriteAllBytes(dataFolder + "cast_roll_graphics.bin", Graphics);
            //File.WriteAllBytes(dataFolder + "cast_roll_arrangements.bin", convertUShortArrToByteArrLE(Arrangements));

            File.WriteAllBytes(dataFolder + "cast_roll_first_free.bin", convertUShortToByteArrLE((ushort)(UsedTiles + 0x100)));
            File.WriteAllBytes(dataFolder + "cast_roll_graphics_[c].bin", GBA.LZ77.Compress(Graphics));
            File.WriteAllBytes(dataFolder + "cast_roll_arrangements_[c].bin", GBA.LZ77.Compress(convertUShortArrToByteArrLE(Arrangements)));
        }

        static byte[] prepareSeparateRenderSize(WritingBuffer buf)
        {
            byte[] newArr = new byte[1]; //Used in order to have a properly sized buffer
            newArr[0] = (byte)((buf.used * 2 * WritingBuffer.yLength) & 0xFF);
            return newArr;
        }

        static byte[] prepareSeparateRenderData(WritingBuffer buf, Render ren)
        {
            byte[] newArr = new byte[8]; //Data used to display the separate arrangements
            writeUShortToByteArrLE(newArr, 0, (ushort)(buf.startPos + 1)); //The + 1 is needed because the map starts from 1, not from 0
            writeUShortToByteArrLE(newArr, 2, (ushort)(ren.Y + 0x19)); //Apparently, the actual arrangements start at y = 0x19...
            writeUShortToByteArrLE(newArr, 4, (ushort)(buf.used));
            writeUShortToByteArrLE(newArr, 6, (ushort)(WritingBuffer.yLength));
            return newArr;
        }

        static byte[] prepareSeparateRender(WritingBuffer buf)
        {
            //Converts the arrangements to an array that is to be included separately
            byte[] newArr = new byte[WritingBuffer.yLength * buf.used * 2];
            for (int j = 0; j < WritingBuffer.yLength; j++)
                for (int i = 0; i < buf.used; i++)
                    writeUShortToByteArrLE(newArr, (i + (j * buf.used)) * 2, buf.arrangements[j, i]);

            return newArr;
        }

        static int readIntLE(byte[] arr, int pos)
        {
            return arr[pos] + (arr[pos + 1] << 8) + (arr[pos + 2] << 16) + (arr[pos + 3] << 24);
        }

        static ushort readUShortLE(byte[] arr, int pos)
        {
            return (ushort)(arr[pos] + (arr[pos + 1] << 8));
        }

        static void writeIntToByteArrLE(byte[] arr, int pos, int val)
        {
            for (int i = 0; i < 4; i++)
                arr[pos + i] = (byte)((val >> (i * 8)) & 0xFF);
        }

        static void writeUShortToByteArrLE(byte[] arr, int pos, ushort val)
        {
            for (int i = 0; i < 2; i++)
                arr[pos + i] = (byte)((val >> (i * 8)) & 0xFF);
        }

        static byte[] convertUShortToByteArrLE(ushort val)
        {
            byte[] newArr = new byte[2];
            newArr[0] = (byte)((val) & 0xFF);
            newArr[1] = (byte)((val >> 8) & 0xFF);
            return newArr;
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

        static int insertInGraphics(WritingBuffer buf, int usedInGraphics)
        {
            //Optimally inserts the graphics inside the final product
            int total = usedInGraphics;

            for (int i = 0; i < buf.used; i++)
            {
                for (int j = 0; j < WritingBuffer.yLength; j++)
                {
                    _1bppTile tile = buf.tiles[j, i];

                    int rot = 0;
                    int pos = -1;
                    if (emptyTile.Equals(tile))
                        pos = 0x2FF; //Empty tile
                    else
                        pos = getPosInFinal(tile, total, _1bppGraphics);

                    if (pos == -1)
                    {
                        rot = 1;
                        pos = getPosInFinal(tile, total, _1bppGraphics_RotX);

                        if (pos == -1)
                        {
                            rot = 2;
                            pos = getPosInFinal(tile, total, _1bppGraphics_RotY);

                            if (pos == -1)
                            {
                                rot = 3;
                                pos = getPosInFinal(tile, total, _1bppGraphics_RotXY);
                            }
                        }
                    }

                    if (pos == -1) //Hasn't been found in any of the ways the buffer can be looked at
                    {
                        rot = 0;
                        pos = total++;
                        _1bppGraphics[pos] = tile; //If we're here, we already calculated all four of them
                        _1bppGraphics_RotX[pos] = tile.rotateX();
                        _1bppGraphics_RotY[pos] = tile.rotateY();
                        _1bppGraphics_RotXY[pos] = _1bppGraphics_RotX[pos].rotateY();
                    }

                    buf.arrangements[j, i] = (ushort)(Palette | (pos + arrStart) | (rot << 0xA));
                }
            }

            return total;
        }

        static int getPosInFinal(_1bppTile tile, int total, _1bppTile[] finalProd)
        {
            int pos = -1;
            for (int k = 0; k < total; k++)
                if (finalProd[k].Equals(tile))
                {
                    pos = k;
                    break;
                }
            return pos;
        }

        static WritingBuffer renderText(Render r)
        {
            WritingBuffer a = new WritingBuffer();
            byte[] text = getTextBytes(r.Text);
            int len = getTextLength(text, r.Font);
            int x = r.Center_X - (len / 2);

            //Boundary checks
            if (x + len > 240)
                x = 240 - len;
            if (x < 0)
                x = 0;

            a.startPos = (x >> 3);
            int bufferPos = x & 7;

            for (int i = 0; i < text.Length; i++)
                bufferPos += _1bppRenderChar(text[i], bufferPos, r.Font, a);

            a.used = (bufferPos + 7) >> 3;
            return a;
        }

        static byte _1bppRenderChar(byte chr, int x, int font, WritingBuffer buf)
        {
            //Renders a character
            int tileHeight = 2;
            int tileWidth = 2;
            int tileX = x >> 3;
            int chrPos = chr * tileWidth * tileHeight * 8;
            int offsetX = x & 7;
            int startOffsetY = 3 & 7;
            if(font == 1) //Saturn font is higher, for some reason...
                startOffsetY = 0;
            byte vWidth = Fonts[font].fontWidth[chr * 2];
            byte rWidth = Fonts[font].fontWidth[(chr * 2) + 1];

            if (font == 1 && vWidth != rWidth) //The Saturn font is compressed horizontally by removing 1 trailing pixel
                vWidth -= 1;

            for(int dTileY = 0; dTileY < tileHeight; dTileY++)
            {
                int dTileX = 0;
                int renderedWidth = rWidth;
                while (renderedWidth > 0)
                {
                    int offsetY = startOffsetY & 7;
                    int tileIndexX = tileX + dTileX;
                    int tileIndexY = dTileY;
                    _1bppTile leftTile = buf.tiles[dTileY, tileIndexX];
                    _1bppTile rightTile = buf.tiles[dTileY, tileIndexX + 1];

                    for (int row = 0; row < 8; row++)
                    {
                        ushort canvasRow = (ushort)(leftTile.getRow(row + offsetY) | (rightTile.getRow(row + offsetY) << 8));
                        ushort glyphRow = (ushort)(Fonts[font].font[chrPos + row + (((dTileY * tileWidth) + dTileX) * 8)] << offsetX);

                        canvasRow |= glyphRow;
                        leftTile.setRow(row + offsetY, (byte)(canvasRow & 0xFF));
                        rightTile.setRow(row + offsetY, (byte)((canvasRow >> 8) & 0xFF));

                        if(row != 7 && row + offsetY == 7)
                        {
                            offsetY = -(row + 1);
                            tileIndexY++;
                            leftTile = buf.tiles[tileIndexY, tileIndexX];
                            rightTile = buf.tiles[tileIndexY, tileIndexX + 1];
                        }
                    }

                    renderedWidth -= 8;
                    dTileX++;
                }
            }
            return vWidth;
        }

        static byte[] getTextBytes(String str)
        {
            //Reads a string and converts it to bytes
            List<byte> tokens = new List<byte>();
            for (int i = 0; str.Length > 0; i++)
            {
                string token = str[0].ToString();
                str = str.Substring(1);
                if (token == "[")
                    while (str.Length > 0 && !token.EndsWith("]"))
                    {
                        token += str[0].ToString();
                        str = str.Substring(1);
                    }
                if (m12CharByteLookup.ContainsKey(token))
                    tokens.Add(m12CharByteLookup[token]);
            }
            return tokens.ToArray();
        }

        static int getTextLength(byte[] text, int Font)
        {
            int len = 0;
            for (int i = 0; i < text.Length; i++)
            {
                len += Fonts[Font].fontWidth[2 * text[i]];
                if (Font == 1 && Fonts[Font].fontWidth[2 * text[i]] != Fonts[Font].fontWidth[(2 * text[i]) + 1]) //Handle Saturn font compression
                    len -= 1;
            }
            return len;
        }
    }
}
