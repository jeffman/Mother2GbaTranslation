using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace ScriptTool
{
    class M12Compiler : ICompiler
    {
        private static IEnumerable<M12ControlCode> controlCodes;
        private static string[] charLookup;
        private const string hexChars = "0123456789ABCDEFabcdef";
        private const string ebCharLookup = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZØØØØØ`abcdefghijklmnopqrstuvwxyz{|}~\\";

        public Dictionary<string, int> AddressMap { get; set; }

        static M12Compiler()
        {
            controlCodes = M12ControlCode.Codes;
            charLookup = File.ReadAllLines("m12-text-table.txt");
        }

        public M12Compiler()
        {
            AddressMap = new Dictionary<string, int>();
        }

        public static bool IsHexByte(string str)
        {
            if (str == null || str.Length > 2)
            {
                return false;
            }

            for (int i = 0; i < str.Length; i++)
            {
                if (hexChars.IndexOf(str[i]) == -1)
                {
                    return false;
                }
            }

            return true;
        }

        public static bool IsValidChar(char c)
        {
            if (!ebCharLookup.Contains(c))
            {
                return false;
            }
            if (c == 'Ø')
            {
                return false;
            }
            return true;
        }

        public static byte GetByte(char c)
        {
            return (byte)(ebCharLookup.IndexOf(c) + 0x50);
        }

        public void ScanString(string str, ref int referenceAddress)
        {
            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket");

                    string[] codeStrings = str.Substring(i + 1, str.IndexOf(']', i + 1) - i - 1)
                        .Split(' ');

                    foreach (var codeString in codeStrings)
                    {
                        if (codeString[0] == '_')
                        {
                            if (codeString[codeString.Length - 1] != '_')
                                throw new Exception("Reference has no closing underscore");

                            if (codeString.Length <= 2)
                                throw new Exception("Reference is empty");

                            referenceAddress += 4;
                        }
                        else if (IsHexByte(codeString))
                        {
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

                    AddressMap.Add(label, referenceAddress);

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    if (!(str[i] == '\r') && !(str[i] == '\n'))
                    {
                        if (!IsValidChar(str[i]))
                            throw new Exception("Invalid character: " + str[i]);

                        referenceAddress++;
                    }
                    i++;
                }
            }
        }

        public void CompileString(string str, IList<byte> buffer, ref int referenceAddress)
        {
            for (int i = 0; i < str.Length; )
            {
                if (str[i] == '[')
                {
                    if (str.IndexOf(']', i + 1) == -1)
                        throw new Exception("Opening bracket has no matching closing bracket");

                    string[] codeStrings = str.Substring(i + 1, str.IndexOf(']', i + 1) - i - 1)
                        .Split(' ');

                    // Match the code
                    M12ControlCode code = controlCodes.FirstOrDefault(c => c.IsMatch(codeStrings));

                    if (code == null)
                    {
                        // Direct copy
                        for (int j = 0; j < codeStrings.Length; j++)
                        {
                            if (!IsHexByte(codeStrings[j]))
                                throw new Exception("Code string for unrecognized control code block must be a byte literal");

                            byte value = byte.Parse(codeStrings[j], System.Globalization.NumberStyles.HexNumber);
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
                        foreach (var codeString in codeStrings)
                        {
                            if (codeString[0] == '_')
                            {
                                if (codeString[codeString.Length - 1] != '_')
                                    throw new Exception("Reference has no closing underscore");

                                if (codeString.Length <= 2)
                                    throw new Exception("Reference is empty");

                                string label = codeString.Substring(1, codeString.Length - 2);
                                int pointer = AddressMap[label];

                                if (!code.AbsoluteAddressing)
                                {
                                    pointer -= referenceAddress;
                                }
                                else
                                {
                                    pointer |= 0x8000000;
                                }

                                buffer.AddInt(pointer);
                                referenceAddress += 4;
                            }
                            else if (IsHexByte(codeString))
                            {
                                byte value = byte.Parse(codeString, System.Globalization.NumberStyles.HexNumber);
                                buffer.Add(value);
                                referenceAddress++;
                            }
                            else
                            {
                                throw new Exception(String.Format(
                                    "Encountered invalid code string at position {0}: {1}", i, codeString));
                            }
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

                    i = str.IndexOf('^', i + 1) + 1;
                }
                else
                {
                    if (!(str[i] == '\r') && !(str[i] == '\n'))
                    {
                        if (!IsValidChar(str[i]))
                            throw new Exception("Invalid character: " + str[i]);

                        byte value = GetByte(str[i]);
                        buffer.Add(value);
                        referenceAddress++;
                    }
                    i++;
                }
            }
        }
    }
}
