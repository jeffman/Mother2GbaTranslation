using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RenderCastRoll
{
    public class Render
    {
        public int Y { get; set; }
        public int Center_X { get; set; }
        public string Text { get; set; }
        public int Font { get; set; }
    }

    public class RenderRoot
    {
        public List<Render> Renders { get; set; }
    }

    public class RenderFont
    {
        public byte[] font;
        public byte[] fontWidth;

        public RenderFont(string folder, string fontName)
        {
            font = File.ReadAllBytes(folder + "m2-font-" + fontName + ".bin");
            fontWidth = File.ReadAllBytes(folder + "m2-widths-" + fontName + ".bin");
        }
    }

    public class _1bppTile
    {
        UInt64 tile;

        public _1bppTile() : this(0) { }

        public _1bppTile(UInt64 val)
        {
            tile = val;
        }

        public byte getRow(int i)
        {
            return (byte)((tile >> (i * 8)) & 0xFF);
        }

        public void setRow(int i, byte val)
        {
            UInt64 mask = ~((UInt64)(0xFF) << (i * 8));
            tile = (tile & mask) | ((UInt64)val << (i * 8));
        }

        public UInt64 getColumn(int i)
        {
            UInt64 mask = (UInt64)(0x0101010101010101 << i);
            return mask & tile;
        }

        public void setColumn(int i, UInt64 val)
        {
            UInt64 mask = ~(UInt64)(0x0101010101010101 << i);
            tile = (tile & mask) | val;
        }

        public bool Equals(_1bppTile t)
        {
            return this.tile == t.tile;
        }

        public _1bppTile rotateX()
        {
            _1bppTile newTile = new _1bppTile(tile);
            for (int row = 0; row < 8; row++)
            {
                byte val = newTile.getRow(row);
                byte newVal = 0;
                for (int i = 0; i < 8; i++)
                    newVal |= (byte)(((val >> i) & 1) << (7 - i));
                newTile.setRow(row, newVal);
            }
            return newTile;
        }

        public _1bppTile rotateY()
        {
            _1bppTile newTile = new _1bppTile(tile);
            for (int column = 0; column < 8; column++)
            {
                UInt64 val = newTile.getColumn(column);
                UInt64 newVal = 0;
                for (int i = 0; i < 8; i++)
                    newVal |= ((val >> (i * 8)) & 0xFF) << ((7 - i) * 8);
                newTile.setColumn(column, newVal);
            }
            return newTile;
        }
    }

    public class WritingBuffer
    {
        public _1bppTile[,] tiles;
        public ushort[,] arrangements;
        public int used;
        public int startPos;

        public WritingBuffer()
        {
            used = 0;
            startPos = 0;
            tiles = new _1bppTile[2, 0x20];
            arrangements = new ushort[2, 0x20];
            for (int i = 0; i < 2; i++)
                for (int j = 0; j < 0x20; j++)
                {
                    tiles[i, j] = new _1bppTile();
                    arrangements[i, j] = 0x3FF; //Empty tile
                }
        }
    }
}
