using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Newtonsoft.Json;

namespace SetDefaultNames
{
    public class NamesEntry
    {
        public string entry { get; set; }
        public string[] defaultNames { get; set; }
    }

    public class NamesEntryRoot
    {
        public List<NamesEntry> NamesEntries { get; set; }
    }

    class Program
    {
        static readonly int[] MaxSizes = { 5, 5, 5, 5, 6, 6, 6 };
        static readonly int entry_size = 0x4C;
        static readonly int entry_numbers = 7;
        static readonly int encode_ascii = 48;

        static void Main(string[] args)
        {
            if (args.Length != 2)
                return;

            //Initialization
            string namesJson = File.ReadAllText(args[0]);
            string dataFolder = args[1] + Path.DirectorySeparatorChar;
            byte[] namesBin = File.ReadAllBytes(dataFolder + "m2-default-names.bin");
            List<NamesEntry> entries = JsonConvert.DeserializeObject<NamesEntryRoot>(namesJson).NamesEntries;

            for (int i = 0; i < MaxSizes.Length; i++)
            {
                for (int j = 0; j < entries[i].defaultNames.Length; j++)
                {
                    byte[] convertedString = getTextBytes(entries[i].defaultNames[j]);
                    int size = Math.Min(convertedString.Length, MaxSizes[i]);
                    int pos = (i * entry_numbers * entry_size) + (j * entry_size);
                    insertInt(namesBin, pos, size);
                    for (int k = 0; k < 8; k++)
                    {
                        byte value = (k < size) ? convertedString[k] : (byte)0;
                        namesBin[pos + 4 + k] = value;
                    }
                }

            }
            
            File.WriteAllBytes(dataFolder + "m2-default-names.bin", namesBin);
        }

        static void insertInt(byte[] bin, int pos, int val)
        {
            bin[pos] = (byte)((val) & 0xFF);
            bin[pos + 1] = (byte)((val >> 8) & 0xFF);
            bin[pos + 2] = (byte)((val >> 16) & 0xFF);
            bin[pos + 3] = (byte)((val >> 24) & 0xFF);
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
                    tokens.Add((byte)(Encoding.ASCII.GetBytes(token)[0] + encode_ascii));
            }
            return tokens.ToArray();
        }
    }
}
