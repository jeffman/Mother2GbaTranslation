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
        public IEnumerable<IControlCode> ControlCodes { get; set; }
        public Dictionary<string, int> AddressMap { get; set; }
        public Func<byte[], int, bool> ControlCodePredicate { get; set; }

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
                        throw new Exception("Opening bracket has no matching closing bracket");

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
                                throw new Exception("Reference has no closing underscore");

                            if (codeString.Length <= 2)
                                throw new Exception("Reference is empty");

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
                    throw new Exception("Closing bracket has no matching opening bracket");
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret");

                    string label = str.Substring(i + 1, str.IndexOf('^', i + 1) - i - 1);

                    if (AddressMap.ContainsKey(label))
                        throw new Exception("Label already defined");

                    if(!scanCodesOnly)
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
                        throw new Exception("Opening bracket has no matching closing bracket");

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
                                throw new Exception("Code string for unrecognized control code block must be a byte literal");

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
                            throw new Exception("Invalid control code");

                        // Parse
                        code.Compile(codeStrings, buffer, ref referenceAddress, AddressMap);
                    }

                    i = str.IndexOf(']', i + 1) + 1;
                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket");
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret");

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
                    throw new Exception("Exceeded pad length");

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
                        throw new Exception("Opening bracket has no matching closing bracket");

                    sb.Append(str.Substring(i, str.IndexOf(']', i + 1) - i + 1));

                    i = str.IndexOf(']', i + 1) + 1;
                }
                else if (str[i] == ']')
                {
                    throw new Exception("Closing bracket has no matching opening bracket");
                }
                else if (str[i] == '^')
                {
                    if (str.IndexOf('^', i + 1) == -1)
                        throw new Exception("Label has no matching closing caret");

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
    }
}
