using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ScriptTool
{
    class EbTextDecompiler : IDecompiler2
    {
        private IList<ControlCode> _controlCodes;
        public IList<ControlCode> ControlCodes
        {
            get { return _controlCodes; }
            set
            {
                // Grab the jump table codes
                foreach (var code in value)
                {
                    if (code.BeginsWith(9))
                        jumpTableReturn = code;

                    if (code.BeginsWith(0x1f, 0xc0))
                        jumpTableNoReturn = code;
                }

                _controlCodes = value;
            }
        }

        private ControlCode jumpTableReturn;
        private ControlCode jumpTableNoReturn;

        private const string charMapEb = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZØØØØØ`abcdefghijklmnopqrstuvwxyz{|}~\\";

        private static string[][] compressedStringsEb;
        private static IList<int[]> textRanges = new List<int[]>();

        static EbTextDecompiler()
        {
            // Load compressed strings
            compressedStringsEb = new string[3][];
            string[] stringsFromFile = File.ReadAllLines(@"eb-compressed-strings.txt");
            compressedStringsEb[0] = stringsFromFile.Take(0x100).ToArray();
            compressedStringsEb[1] = stringsFromFile.Skip(0x100).Take(0x100).ToArray();
            compressedStringsEb[2] = stringsFromFile.Skip(0x200).Take(0x100).ToArray();

            // Load text ranges
            textRanges.Add(new int[] { 0x50000, 0x5FFEC });
            textRanges.Add(new int[] { 0x60000, 0x6FFE3 });
            textRanges.Add(new int[] { 0x70000, 0x7FF40 });
            textRanges.Add(new int[] { 0x80000, 0x8BC2D });
            textRanges.Add(new int[] { 0x8D9ED, 0x8FFF3 });
            textRanges.Add(new int[] { 0x90000, 0x9FF2F });
            textRanges.Add(new int[] { 0x2F4E20, 0x2FA460 });
        }

        public void Decompile(byte[] rom, int[] addresses, DecompileContext context)
        {
            if (ControlCodes == null)
                throw new Exception("Codelist is null");

            // First pass -- define labels
            foreach (var address in addresses)
                context.LabelMap.Add(address);

            foreach (var range in textRanges)
                ScanAt(rom, range[0], range[1], context, ScanMode.FirstPass, false, false, false);

            // Second pass -- decompile the strings
            foreach (var range in textRanges)
                ScanAt(rom, range[0], range[1], context, ScanMode.SecondPass, false, false, true);
        }

        public string ReadString(byte[] rom, int address, int endAddress, bool basicMode)
        {
            return ScanAt(rom, address, endAddress, null, ScanMode.ReadOnce, true, basicMode, false);
        }

        private string ScanAt(byte[] rom, int startAddress, int endAddress, DecompileContext context,
            ScanMode mode, bool stopOnEnd, bool basicMode, bool newLines)
        {
            bool ended = false;
            bool foundMatch = false;
            bool prev1902 = false;

            var sb = new StringBuilder();

            int address = startAddress;

            if (address == 0)
            {
                throw new Exception("Null pointer");
            }

            if (mode == ScanMode.FirstPass)
            {
                context.LabelMap.Add(address);
            }

            while (!ended)
            {
                // Check for label definition
                if (mode == ScanMode.SecondPass && context.LabelMap.Labels.ContainsKey(address))
                {
                    sb.Append("^" + context.LabelMap[address] + "^");
                }

                // Check for control codes

                // No codes begin with a value above 0x1F, so check for that first
                if (rom[address] < 0x20)
                {
                    // Check for basic mode null-terminator
                    if (basicMode && rom[address] == 0)
                    {
                        ended = true;
                        continue;
                    }

                    // Loop through each control code until we find a match
                    foundMatch = false;
                    foreach (var code in ControlCodes)
                    {
                        if (code.Match(rom, address))
                        {
                            foundMatch = true;

                            if ((mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce) && !IsCompressedCode(code))
                            {
                                // Output the start of the code block
                                sb.Append('[');

                                // Output the identifier bytes
                                sb.Append(String.Join(" ", code.Identifier.Select(b => b.ToString("X2")).ToArray()));
                            }

                            // Skip the identifier bytes
                            address += code.Identifier.Count;

                            // Found a match -- check if it's variable-length
                            if (code.Multiple)
                            {
                                if (code.BeginsWith(9) ||
                                    code.BeginsWith(0x1F, 0xC0))
                                {
                                    int count = rom[address++];

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(' ');
                                        sb.Append(count.ToString("X2"));
                                    }

                                    for (int i = 0; i < count; i++)
                                    {
                                        int jump = rom.ReadSnesPointer(address);
                                        address += 4;

                                        context.LabelMap.Add(jump);

                                        if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                        {
                                            sb.Append(" _");
                                            sb.Append(context.LabelMap[jump]);
                                            sb.Append('_');
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // Check if it references any other addresses -- scan those too
                                if (code.BeginsWith(8) ||
                                    code.BeginsWith(0xA) ||
                                    code.BeginsWith(0x1B, 0x02) ||
                                    code.BeginsWith(0x1B, 0x03) ||
                                    code.BeginsWith(0x1F, 0x63))
                                {
                                    // Single address at next byte
                                    int jump = rom.ReadSnesPointer(address);

                                    context.LabelMap.Add(jump);

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(" _");
                                        sb.Append(context.LabelMap[jump]);
                                        sb.Append('_');
                                    }
                                }

                                else if (code.BeginsWith(0x1F, 0x66) ||
                                    code.BeginsWith(6))
                                {
                                    // Skip two bytes; single address afterwards
                                    int jump = rom.ReadSnesPointer(address + 2);

                                    context.LabelMap.Add(jump);

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(' ');
                                        sb.Append(rom[address].ToString("X2"));
                                        sb.Append(' ');
                                        sb.Append(rom[address + 1].ToString("X2"));

                                        sb.Append(" _");
                                        sb.Append(context.LabelMap[jump]);
                                        sb.Append('_');
                                    }
                                }

                                else if (
                                    code.BeginsWith(0x1F, 0x18) ||
                                    code.BeginsWith(0x1F, 0x19))
                                {
                                    // Check
                                }

                                else if ((mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce) &&
                                    (code.BeginsWith(0x15) ||
                                    code.BeginsWith(0x16) ||
                                    code.BeginsWith(0x17)))
                                {
                                    // Check for compressed codes
                                    int bank = code.Identifier[0] - 0x15;
                                    int index = rom[address];
                                    sb.Append(compressedStringsEb[bank][index]);
                                }

                                else
                                {
                                    // Regular control code -- output the rest of the bytes
                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        for (int i = 0; i < (code.Length - code.Identifier.Count); i++)
                                        {
                                            sb.Append(' ');
                                            sb.Append(rom[address + i].ToString("X2"));
                                        }
                                    }
                                }

                                // Skip the rest of the bytes
                                address += code.Length - code.Identifier.Count;
                            }

                            if ((mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce) && !IsCompressedCode(code))
                            {
                                // Output the end of the code block
                                sb.Append(']');
                            }

                            // End the block if necessary
                            if (stopOnEnd && code.End)
                            {
                                ended = true;
                            }

                            // Insert a newline after each end code for readibility
                            if (newLines && (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce) && code.End && !prev1902)
                            {
                                sb.AppendLine();
                                /*sb.Append('(');
                                sb.Append(address.ToString("X"));
                                sb.Append(')');*/
                            }

                            // Check if we're in a menu string
                            if (code.BeginsWith(0x19, 0x02))
                                prev1902 = true;
                            else
                                prev1902 = false;

                            break;
                        }
                    }

                    if (!foundMatch)
                    {
                        // Bad!
                        throw new Exception("Found unknown control code");
                    }
                }
                else
                {
                    // It's not a control code -- just skip it
                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                        sb.Append(CharLookup(rom[address]));

                    address++;
                }

                if ((endAddress != -1) && (address >= endAddress))
                    ended = true;
            }

            if (mode == ScanMode.SecondPass)
                context.Strings.Add(sb.ToString());

            else if (mode == ScanMode.ReadOnce)
                return sb.ToString();

            return null;
        }

        private string CharLookup(byte value)
        {
            if (value >= 0x8B && value <= 0x8F)
            {
                // Greek letters -- output hex literals instead
                return "[" + value.ToString("X2") + "]";
            }
            else if (value == 0xAF)
            {
                // Musical note -- output \ instead of the garbage char that normally would get outputted
                return "\\";
            }
            else
            {
                return charMapEb[value - 0x50].ToString();
            }
        }

        private bool IsCompressedCode(ControlCode code)
        {
            if (code.Identifier[0] == 0x15 || code.Identifier[0] == 0x16 ||
                code.Identifier[0] == 0x17)
                return true;

            return false;
        }

        private enum ScanMode
        {
            FirstPass,
            SecondPass,
            ReadOnce
        }
    }
}
