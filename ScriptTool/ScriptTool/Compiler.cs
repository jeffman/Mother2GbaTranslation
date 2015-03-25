using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ScriptTool
{
    public class Compiler : ICompiler
    {
        private static int[] virtualWidths;
        private static int[] renderWidths;

        public IEnumerable<IControlCode> ControlCodes { get; set; }
        public Dictionary<string, int> AddressMap { get; set; }
        public Func<byte[], int, bool> ControlCodePredicate { get; set; }

        static Compiler()
        {
            byte[] widths = File.ReadAllBytes("m2-widths-main.bin");
            virtualWidths = new int[widths.Length / 2];
            renderWidths = new int[widths.Length / 2];

            for (int i = 0; i < widths.Length; i += 2)
            {
                virtualWidths[i / 2] = widths[i];
                renderWidths[i / 2] = widths[i + 1];
            }
        }

        public Compiler(IEnumerable<IControlCode> controlCodes,
            Func<byte[], int, bool> controlCodePredicate)
        {
            ControlCodes = controlCodes;
            ControlCodePredicate = controlCodePredicate;

            AddressMap = new Dictionary<string, int>();
        }

        public static bool IsHexByte(string str)
        {
            try
            {
                Convert.ToByte(str, 16);
                return true;
            }
            catch
            {
                return false;
            }
        }

        private byte GetByte(char c, IDictionary<byte, string> charLookup)
        {
            return charLookup.First(kv => kv.Value[0] == c).Key; // lazy
        }

        public void ScanString(string str, ref int referenceAddress, IDictionary<byte, string> charLookup, bool scanCodesOnly)
        {
            ISet<IControlCode> codes;
            IList<string> references;
            ScanString(str, ref referenceAddress, charLookup, scanCodesOnly, out references, out codes);
        }

        public void ScanString(string str, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out IList<string> references)
        {
            int temp = 0;
            ISet<IControlCode> codes;
            ScanString(str, ref temp, charLookup, scanCodesOnly, out references, out codes);
        }

        public void ScanString(string str, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out ISet<IControlCode> codes)
        {
            int temp = 0;
            IList<string> references;
            ScanString(str, ref temp, charLookup, scanCodesOnly, out references, out codes);
        }

        public void ScanString(string str, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out IList<string> references, out ISet<IControlCode> controlCodes)
        {
            int temp = 0;
            ScanString(str, ref temp, charLookup, scanCodesOnly, out references, out controlCodes);
        }

        public void ScanString(string str, ref int referenceAddress, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out IList<string> references, out ISet<IControlCode> controlCodes)
        {
            references = new List<string>();
            controlCodes = new HashSet<IControlCode>();

            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket: position " + i);

                    string[] codeStrings = str.Substring(i + 1, str.IndexOf(']', i + 1) - i - 1)
                        .Split(' ');

                    IControlCode code = ControlCodes.FirstOrDefault(c => c.IsMatch(codeStrings));
                    if (!controlCodes.Contains(code))
                    {
                        controlCodes.Add(code);
                    }

                    foreach (var codeString in codeStrings)
                    {
                        if (codeString[0] == '_')
                        {
                            if (codeString[codeString.Length - 1] != '_')
                                throw new Exception("Reference has no closing underscore: position " + i);

                            if (codeString.Length <= 2)
                                throw new Exception("Reference is empty: position " + i);

                            if (!scanCodesOnly)
                                referenceAddress += 4;

                            references.Add(codeString.Substring(1, codeString.Length - 2));
                        }
                        else if (IsHexByte(codeString))
                        {
                            if (!scanCodesOnly)
                                referenceAddress++;
                        }
                        else
                        {
                            throw new Exception(String.Format(
                                "Encountered invalid code string at position {0}: {1}", i, codeString));
                        }
                    }

                    i = str.IndexOf(']', i + 1) + 1;
                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket: position " + i);
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret: position " + i);

                    string label = str.Substring(i + 1, str.IndexOf('^', i + 1) - i - 1);

                    if (AddressMap.ContainsKey(label))
                        throw new Exception("Label already defined: position " + i);

                    if (!scanCodesOnly)
                        AddressMap.Add(label, referenceAddress);

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    if (!(str[i] == '\r') && !(str[i] == '\n'))
                    {
                        if (!scanCodesOnly)
                        {
                            GetByte(str[i], charLookup); // just check if it's valid
                            referenceAddress++;
                        }
                    }
                    i++;
                }
            }
        }

        public void CompileString(string str, IList<byte> buffer, ref int referenceAddress, IDictionary<byte, string> charLookup)
        {
            CompileString(str, buffer, ref referenceAddress, charLookup, -1);
        }

        public void CompileString(string str, IList<byte> buffer, ref int referenceAddress, IDictionary<byte, string> charLookup, int padLength)
        {
            int previousBufferSize = buffer.Count;

            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket: position " + i);

                    string[] codeStrings = str.Substring(i + 1, str.IndexOf(']', i + 1) - i - 1)
                        .Split(' ');

                    // Match the code
                    IControlCode code = ControlCodes.FirstOrDefault(c => c.IsMatch(codeStrings));

                    if (code == null)
                    {
                        // Direct copy
                        for (int j = 0; j < codeStrings.Length; j++)
                        {
                            if (!IsHexByte(codeStrings[j]))
                                throw new Exception("Code string for unrecognized control code block must be a byte literal: position " + i);

                            byte value = byte.Parse(codeStrings[j], System.Globalization.NumberStyles.HexNumber);
                            if (buffer != null)
                                buffer.Add(value);
                            referenceAddress++;
                        }
                    }

                    else
                    {
                        // Validate
                        if (!code.IsValid(codeStrings))
                            throw new Exception("Invalid control code: position " + i);

                        // Parse
                        code.Compile(codeStrings, buffer, ref referenceAddress, AddressMap);
                    }

                    i = str.IndexOf(']', i + 1) + 1;
                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket: position " + i);
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret: position " + i);

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    if (!(str[i] == '\r') && !(str[i] == '\n'))
                    {
                        byte value = GetByte(str[i], charLookup);

                        if (buffer != null)
                            buffer.Add(value);

                        referenceAddress++;
                    }
                    i++;
                }
            }

            // Pad the remaining bytes
            if (padLength != -1)
            {
                int bytesWritten = buffer.Count - previousBufferSize;

                if (bytesWritten > padLength)
                    throw new Exception("Exceeded pad length: wrote " + bytesWritten +
                        " bytes, but the pad length is " + padLength + " bytes");

                for (int i = bytesWritten; i < padLength; i++)
                {
                    if (buffer != null)
                        buffer.Add(0);

                    referenceAddress++;
                }
            }
        }

        public string StripText(string str)
        {
            var sb = new StringBuilder();

            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket: position " + i);

                    sb.Append(str.Substring(i, str.IndexOf(']', i + 1) - i + 1));

                    i = str.IndexOf(']', i + 1) + 1;
                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket: position " + i);
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret: position " + i);

                    sb.Append(str.Substring(i, str.IndexOf('^', i + 1) - i + 1));

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    i++;
                }
            }

            return sb.ToString();
        }

        public IList<string> FormatPreviewM12(string str, out IList<int> widths, IDictionary<byte, string> charLookup)
        {
            var sb = new StringBuilder();
            widths = new List<int>();
            int currentWidth = 0;

            var strings = new List<string>();

            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket: position " + i);

                    string[] codeStrings = str.Substring(i + 1, str.IndexOf(']', i + 1) - i - 1)
                        .Split(' ');

                    M12ControlCode code = (M12ControlCode)ControlCodes.FirstOrDefault(c => c.IsMatch(codeStrings));

                    foreach (var codeString in codeStrings)
                    {
                        if (codeString[0] == '_')
                        {
                            if (codeString[codeString.Length - 1] != '_')
                                throw new Exception("Reference has no closing underscore: position " + i);

                            if (codeString.Length <= 2)
                                throw new Exception("Reference is empty: position " + i);
                        }
                        else if (!IsHexByte(codeString))
                        {
                            throw new Exception(String.Format(
                                "Encountered invalid code string at position {0}: {1}", i, codeString));
                        }
                    }

                    i = str.IndexOf(']', i + 1) + 1;

                    
                    switch (code.Identifier)
                    {
                        case 0xC:
                        case 0xD:
                        case 0xE:
                        case 0xF:
                        case 0x10:
                        case 0x11:
                        case 0x12:
                        case 0x15:
                        case 0x1A:
                        case 0x2D:
                        case 0x9F:
                        case 0xAD:
                            // Name/item code
                            sb.Append("[NAME]");
                            currentWidth += 60;
                            break;

                        case 0x1:
                        case 0x2:
                            // Line break
                            strings.Add(sb.ToString());
                            sb.Clear();
                            widths.Add(currentWidth);
                            currentWidth = 0;
                            break;

                        case 0x20:
                            sb.Append("[SMAAASH]");
                            currentWidth += 72;
                            break;

                        case 0x21:
                            sb.Append("[YOU WIN]");
                            currentWidth += 72;
                            break;

                        case 0x23:
                        case 0x63:
                        case 0x98:
                        case 0xB7:
                            sb.Append("[MONEY]");
                            currentWidth += 36;
                            break;

                        case 0x24:
                        case 0x25:
                        case 0x26:
                        case 0x27:
                        case 0x28:
                        case 0x29:
                        case 0x2A:
                        case 0x2B:
                            sb.Append("[STAT]");
                            currentWidth += 18;
                            break;

                        case 0x1E:
                        case 0x1F:
                            sb.Append("_");
                            currentWidth += 10;
                            break;
                    }

                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket: position " + i);
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret: position " + i);

                    string label = str.Substring(i + 1, str.IndexOf('^', i + 1) - i - 1);

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    if (!(str[i] == '\r') && !(str[i] == '\n'))
                    {
                        sb.Append(str[i]);
                        currentWidth += virtualWidths[GetByte(str[i], charLookup) - 0x50];
                    }
                    i++;
                }
            }

            if (sb.Length > 0)
            {
                strings.Add(sb.ToString());
                widths.Add(currentWidth);
            }

            return strings;
        }
    }
}
