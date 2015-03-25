using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ScriptTool
{
    class Decompiler : IDecompiler
    {
        public IEnumerable<IControlCode> ControlCodes { get; set; }
        public IDictionary<byte, string> CharLookup { get; set; }
        public LabelMap LabelMap { get; set; }
        public Func<byte[], int, bool> ControlCodePredicate { get; set; }

        public Decompiler(IEnumerable<IControlCode> controlCodes, IDictionary<byte, string> charLookup,
            Func<byte[], int, bool> controlCodePredicate)
        {
            ControlCodes = controlCodes;
            CharLookup = charLookup;
            ControlCodePredicate = controlCodePredicate;

            LabelMap = new LabelMap();
        }

        public void ScanRange(byte[] rom, int startAddress, int endAddress)
        {
            if (rom == null)
                throw new ArgumentNullException();

            int address = startAddress;
            while (address < endAddress)
            {
                if (ControlCodePredicate(rom, address))
                {
                    IControlCode code = ControlCodes.FirstOrDefault(c => c.IsMatch(rom, address));

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
            bool suppressNextEnd = false;

            int address = startAddress;

            while (!ended)
            {
                if (LabelMap.Labels.ContainsKey(address))
                {
                    builder.Append('^');
                    builder.Append(LabelMap.Labels[address]);
                    builder.Append('^');
                }

                if (ControlCodePredicate(rom, address))
                {
                    IControlCode code = ControlCodes.FirstOrDefault(c => c.IsMatch(rom, address));

                    if (code == null)
                        throw new Exception("Control code not found");

                    // Check if it's compressed text
                    if (code.IsCompressedString)
                    {
                        builder.Append(code.GetCompressedString(rom, address));
                    }
                    else
                    {
                        IList<CodeString> codeStrings = code.GetCodeStrings(rom, address);
                        var filtered = codeStrings.Select(cs => FilterCodeString(cs)).ToArray();

                        builder.Append(String.Format("[{0}]", String.Join(" ", filtered)));

                        if (newLines && code.IsEnd && !suppressNextEnd)
                        {
                            builder.AppendLine();
                        }
                    }

                    address += code.ComputeLength(rom, address);

                    /*if (newLines && code.IsEnd && !suppressNextEnd)
                    {
                        builder.Append("(" + address.ToString("X") + ")");
                    }*/

                    if (readUntilEnd && code.IsEnd)
                        ended = true;

                    if (code.IsEnd)
                    {
                        suppressNextEnd = false;
                    }
                    else if (code.SuppressNextEnd == true)
                    {
                        suppressNextEnd = true;
                    }
                }
                else
                {
                    builder.Append(GetChar(rom[address++]));
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
                    builder.Append("[00 FF]");
                    ended = true;
                    address += 2;
                }
                else if (rom[address] != 0xFF)
                {
                    builder.Append(GetChar(rom[address++]));
                }
                else
                {
                    address++;
                }
            }

            return builder.ToString();
        }

        public string GetChar(byte value)
        {
            if (!CharLookup.ContainsKey(value))
            {
                // Invalid
                throw new Exception("Invalid character");
            }

            return CharLookup[value];
        }
    }
}
