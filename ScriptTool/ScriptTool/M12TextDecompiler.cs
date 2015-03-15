using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ScriptTool
{
    class M12TextDecompiler : IDecompiler
    {
        public IList<ControlCode> ControlCodes { get; set; }
        private static string[] charMap;
        private static IList<int[]> textRanges = new List<int[]>();
        private static DecompileContext staticContext = new DecompileContext();

        static M12TextDecompiler()
        {
            // Load strings
            charMap = File.ReadAllLines("m12-text-table.txt");

            // Load text ranges
            textRanges.Add(new int[] { 0x3697F, 0x8C4B0 });
        }

        public void Decompile(byte[] rom, int[] addresses, DecompileContext context)
        {
            if (ControlCodes == null)
                throw new Exception("Codelist is null");

            // First pass -- define labels
            foreach (var address in addresses)
                context.LabelMap.Append(address);

            foreach(var range in textRanges)
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
            var sb = new StringBuilder();

            int address = startAddress;

            if (address == 0)
            {
                throw new Exception("Null pointer");
            }

            if (mode == ScanMode.FirstPass)
            {
                context.LabelMap.Append(address);
            }

            while (!ended)
            {
                // Check for label definition
                if (mode == ScanMode.SecondPass && context.LabelMap.Labels.ContainsKey(address))
                {
                    sb.Append("^" + context.LabelMap[address] + "^");
                }

                // Check for control codes (unless it's in basic mode)

                // No codes begin with a value above 0x1F, so check for that first
                if (rom[address + 1] == 0xFF && (!basicMode || (basicMode && (rom[address] == 0))))
                {
                    // Loop through each control code until we find a match
                    foundMatch = false;
                    foreach (var code in ControlCodes)
                    {
                        if (code.Match(rom, address))
                        {
                            foundMatch = true;

                            if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
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
                                if (code.BeginsWith(0x95) ||
                                    code.BeginsWith(0xBD))
                                {
                                    int count = rom[address++];

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(' ');
                                        sb.Append(count.ToString("X2"));
                                    }

                                    for (int i = 0; i < count; i++)
                                    {
                                        int jump = rom.ReadInt(address);
                                        jump += address;

                                        address += 4;

                                        context.LabelMap.Append(jump);

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
                                if (code.BeginsWith(0x04) ||
                                    code.BeginsWith(0x05) ||
                                    code.BeginsWith(0x80) ||
                                    code.BeginsWith(0x81) ||
                                    code.BeginsWith(0x82) ||
                                    code.BeginsWith(0x86))
                                {
                                    // Single relative address at next byte
                                    int jump = rom.ReadInt(address);
                                    jump += address;

                                    context.LabelMap.Append(jump);

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(" _");
                                        sb.Append(context.LabelMap[jump]);
                                        sb.Append('_');
                                    }
                                }

                                else if (code.BeginsWith(0x1C))
                                {
                                    // Skip two bytes; single relative address afterwards
                                    int jump = rom.ReadInt(address + 2);
                                    jump += address + 2;

                                    context.LabelMap.Append(jump);

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

                                else if (code.BeginsWith(0x9D))
                                {
                                    // Skip two bytes; single absolute address afterwards
                                    int jump = rom.ReadGbaPointer(address + 2);

                                    context.LabelMap.Append(jump);

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

                                else if (code.BeginsWith(0xA2))
                                {
                                    // Single absolute address at next byte
                                    int jump = rom.ReadGbaPointer(address);

                                    context.LabelMap.Append(jump);

                                    if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
                                    {
                                        sb.Append(" _");
                                        sb.Append(context.LabelMap[jump]);
                                        sb.Append('_');
                                    }
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

                            if (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce)
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
                            if (newLines && (mode == ScanMode.SecondPass || mode == ScanMode.ReadOnce) && code.End)
                            {
                                sb.AppendLine();
                                /*sb.Append('(');
                                sb.Append(address.ToString("X"));
                                sb.Append(')');*/
                            }

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
                    {
                        if (!basicMode || (basicMode && (rom[address] != 0xFF)))
                            sb.Append(CharLookup(rom[address]));
                    }

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
            if ((value >= 83 && value <= 95) ||
                (value >= 180 && value <= 191) ||
                value == 255)
            {
                // Invalid
                throw new Exception("Invalid character");
            }

            return charMap[value];
        }

        private enum ScanMode
        {
            FirstPass,
            SecondPass,
            ReadOnce
        }
    }
}
