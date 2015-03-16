using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ScriptTool
{
    class M12Decompiler : IDecompiler
    {
        private static IEnumerable<IControlCode> controlCodes;
        private static string[] charLookup;

        public LabelMap LabelMap { get; set; }

        static M12Decompiler()
        {
            controlCodes = M12ControlCode.Codes;
            charLookup = File.ReadAllLines("m12-text-table.txt");
        }

        public M12Decompiler()
        {
            LabelMap = new LabelMap();
        }

        public void ScanRange(byte[] rom, int startAddress, int endAddress)
        {
            if (rom == null)
                throw new ArgumentNullException();

            int address = startAddress;
            while (address < endAddress)
            {
                if (rom[address + 1] == 0xFF)
                {
                    IControlCode code = controlCodes.FirstOrDefault(c => c.IsMatch(rom, address));

                    if (code == null)
                        throw new Exception("Control code not found");

                    IList<int> references = code.GetReferences(rom, address);

                    if (references != null)
                        LabelMap.AddRange(references);

                    address += code.ComputeLength(rom, address);
                }

                else
                {
                    address++;
                }
            }
        }
        
        private string FilterCodeString(CodeString codeString)
        {
            var codeByte = codeString as CodeByte;
            if (codeByte != null)
                return codeByte.Value.ToString("X2");
            return "_" + LabelMap.Labels[((CodeReference)codeString).Address] + "_";
        }

        public string DecompileRange(byte[] rom, int startAddress, int endAddress, bool newLines)
        {
            if (rom == null)
                throw new ArgumentNullException();

            var builder = new StringBuilder();
            bool readUntilEnd = (endAddress == -1);
            bool ended = false;
            int address = startAddress;

            while (!ended)
            {
                if (LabelMap.Labels.ContainsKey(address))
                {
                    builder.Append('^');
                    builder.Append(LabelMap.Labels[address]);
                    builder.Append('^');
                }

                if (rom[address + 1] == 0xFF)
                {
                    IControlCode code = (M12ControlCode)controlCodes.FirstOrDefault(c => c.IsMatch(rom, address));

                    if (code == null)
                        throw new Exception("Control code not found");

                    IList<CodeString> codeStrings = code.GetCodeStrings(rom, address);
                    var filtered = codeStrings.Select(cs => FilterCodeString(cs)).ToArray();

                    builder.Append(String.Format("[{0}]", String.Join(" ", filtered)));

                    if (newLines && code.IsEnd)
                    {
                        builder.AppendLine();
                    }

                    address += code.ComputeLength(rom, address);

                    /*if (code.IsEnd)
                    {
                        builder.Append("(" + address.ToString("X") + ")");
                    }*/

                    if (readUntilEnd && code.IsEnd)
                        ended = true;
                }
                else
                {
                    builder.Append(CharLookup(rom[address++]));
                }

                if (!readUntilEnd && address >= endAddress)
                    ended = true;
            }

            return builder.ToString();
        }

        public string DecompileString(byte[] rom, int address, bool newLines)
        {
            return DecompileRange(rom, address, -1, newLines);
        }

        public string ReadFFString(byte[] rom, int address)
        {
            var builder = new StringBuilder();
            bool ended = false;

            while (!ended)
            {
                if (rom[address] == 0 && rom[address + 1] == 0xFF)
                {
                    builder.AppendLine("[00 FF]");
                    ended = true;
                    address += 2;
                }
                else if (rom[address] != 0xFF)
                {
                    builder.AppendLine(CharLookup(rom[address++]));
                }
                else
                {
                    address++;
                }
            }

            return builder.ToString();
        }

        public string CharLookup(byte value)
        {
            if ((value >= 83 && value <= 95) ||
                (value >= 180 && value <= 191) ||
                value == 255)
            {
                // Invalid
                throw new Exception("Invalid character");
            }

            return charLookup[value];
        }
    }
}
