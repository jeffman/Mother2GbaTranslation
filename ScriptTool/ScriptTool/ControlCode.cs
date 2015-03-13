using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ScriptTool
{
    class ControlCode
    {
        public IList<byte> Identifier { get; private set; }
        public bool End { get; set; }
        public bool Multiple { get; set; }
        public int Length { get; set; }
        public string Description { get; set; }
        const string HexChars = "0123456789ABCDEFabcdef";

        public ControlCode()
        {
            Identifier = new List<byte>();
        }

        public bool Match(byte[] rom, int address)
        {
            for (int i = 0; i < Identifier.Count; i++)
                if (rom[address + i] != Identifier[i])
                    return false;
            return true;
        }

        public bool BeginsWith(params byte[] bytes)
        {
            if (bytes.Length > Identifier.Count)
                return false;

            var first = Identifier.Take(bytes.Length);
            if (!first.SequenceEqual(bytes))
                return false;

            return true;
        }

        public override string ToString()
        {
            return Description;
        }

        public static IList<ControlCode> LoadEbControlCodes(string path)
        {
            var codeList = new List<ControlCode>();
            string[] lines = File.ReadAllLines(path);

            foreach (var line in lines)
            {
                var code = new ControlCode();
                string def = line.Substring(0, line.IndexOf(','));
                string desc = line.Substring(line.IndexOf(',') + 1);
                code.Description = desc.Substring(1, desc.Length - 3);

                while (true)
                {
                    if (def.StartsWith("!"))
                    {
                        code.End = true;
                        def = def.Substring(1);
                        continue;
                    }

                    if (def.StartsWith("*"))
                    {
                        code.Multiple = true;
                        def = def.Substring(1);
                        continue;
                    }

                    break;
                }

                string[] defs = def.Split(' ');
                for (int i = 0; i < defs.Length; i++)
                {
                    if (!HexChars.Contains(defs[i][0]))
                        break;

                    code.Identifier.Add(byte.Parse(defs[i], System.Globalization.NumberStyles.HexNumber));
                }

                if (code.Multiple)
                    code.Length = -1;
                else
                    code.Length = defs.Length;

                codeList.Add(code);
            }

            return codeList;
        }

        public static IList<ControlCode> LoadM12ControlCodes(string path)
        {
            var codeList = new List<ControlCode>();
            string[] lines = File.ReadAllLines(path);

            foreach (var line in lines)
            {
                var code = new ControlCode();
                string def = line.Substring(0, line.IndexOf(','));
                string desc = line.Substring(line.IndexOf(',') + 1);
                code.Description = desc;

                while (true)
                {
                    if (def.StartsWith("!"))
                    {
                        code.End = true;
                        def = def.Substring(1);
                        continue;
                    }

                    if (def.StartsWith("*"))
                    {
                        code.Multiple = true;
                        def = def.Substring(1);
                        continue;
                    }

                    break;
                }

                string[] defs = def.Split(' ');
                code.Identifier.Add(byte.Parse(defs[0], System.Globalization.NumberStyles.HexNumber));
                code.Identifier.Add(0xFF);

                if (code.Multiple)
                    code.Length = -1;
                else
                    code.Length = defs.Length;

                codeList.Add(code);
            }

            return codeList;
        }
    }
}
