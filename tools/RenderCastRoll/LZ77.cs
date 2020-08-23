using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace GBA
{
    class LZ77
    {
        public static int Decompress(byte[] data, int address, out byte[] output)
        {
            output = null;
            int start = address;

            if (data[address++] != 0x10) return -1; // Check for LZ77 signature

            // Read the block length
            int length = data[address++];
            length += (data[address++] << 8);
            length += (data[address++] << 16);
            output = new byte[length];

            int bPos = 0;
            while (bPos < length)
            {
                byte ch = data[address++];
                for (int i = 0; i < 8; i++)
                {
                    switch ((ch >> (7 - i)) & 1)
                    {
                        case 0:

                            // Direct copy
                            if (bPos >= length) break;
                            output[bPos++] = data[address++];
                            break;

                        case 1:

                            // Compression magic
                            int t = (data[address++] << 8);
                            t += data[address++];
                            int n = ((t >> 12) & 0xF) + 3;    // Number of bytes to copy
                            int o = (t & 0xFFF);

                            // Copy n bytes from bPos-o to the output
                            for (int j = 0; j < n; j++)
                            {
                                if (bPos >= length) break;
                                output[bPos] = output[bPos - o - 1];
                                bPos++;
                            }

                            break;

                        default:
                            break;
                    }
                }
            }

            return address - start;
        }

        public static byte[] Compress(byte[] data)
        {
            return Compress(data, 0, data.Length);
        }

        public static byte[] Compress(byte[] data, int address, int length)
        {
            int start = address;

            List<byte> obuf = new List<byte>();
            List<byte> tbuf = new List<byte>();
            int control = 0;

            // Let's start by encoding the signature and the length
            obuf.Add(0x10);
            obuf.Add((byte)(length & 0xFF));
            obuf.Add((byte)((length >> 8) & 0xFF));
            obuf.Add((byte)((length >> 16) & 0xFF));

            while ((address - start) < length)
            {
                tbuf.Clear();
                control = 0;
                for (int i = 0; i < 8; i++)
                {
                    bool found = false;

                    // First byte should be raw
                    if (address == start)
                    {
                        tbuf.Add(data[address++]);
                        found = true;
                    }
                    else if ((address - start) >= length)
                    {
                        break;
                    }
                    else
                    {
                        // We're looking for the longest possible string
                        // The farthest possible distance from the current address is 0x1000
                        int max_length = -1;
                        int max_distance = -1;

                        for (int k = 1; k <= 0x1000; k++)
                        {
                            if ((address - k) < start) break;

                            int l = 0;
                            for (; l < 18; l++)
                            {
                                if (((address - start + l) >= length) ||
                                    (data[address - k + l] != data[address + l]))
                                {
                                    if (l > max_length)
                                    {
                                        max_length = l;
                                        max_distance = k;
                                    }
                                    break;
                                }
                            }

                            // Corner case: we matched all 18 bytes. This is
                            // the maximum length, so don't bother continuing
                            if (l == 18)
                            {
                                max_length = 18;
                                max_distance = k;
                                break;
                            }
                        }

                        if (max_length >= 3)
                        {
                            address += max_length;

                            // We hit a match, so add it to the output
                            int t = (max_distance - 1) & 0xFFF;
                            t |= (((max_length - 3) & 0xF) << 12);
                            tbuf.Add((byte)((t >> 8) & 0xFF));
                            tbuf.Add((byte)(t & 0xFF));

                            // Set the control bit
                            control |= (1 << (7 - i));

                            found = true;
                        }
                    }

                    if (!found)
                    {
                        // If we didn't find any strings, copy the byte to the output
                        tbuf.Add(data[address++]);
                    }
                }

                // Flush the temp buffer
                obuf.Add((byte)(control & 0xFF));
                obuf.AddRange(tbuf.ToArray());
            }

            return obuf.ToArray();
        }
    }
}
