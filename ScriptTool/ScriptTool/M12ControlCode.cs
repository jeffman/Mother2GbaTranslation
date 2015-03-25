using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class M12ControlCode : IControlCode, IComparable, IComparable<M12ControlCode>
    {
        public static IEnumerable<IControlCode> Codes { get; private set; }

        public byte Identifier { get; set; }
        public string Description { get; set; }
        public bool IsEnd { get; set; }
        public int Length { get; set; }
        public bool IsVariableLength { get; set; }
        public int ReferenceOffset { get; set; }
        public bool HasReferences { get; set; }
        public bool AbsoluteAddressing { get; set; }
        public bool IsCompressedString { get { return false; } }
        public bool SuppressNextEnd { get; set; }

        static M12ControlCode()
        {
            Codes = JsonConvert.DeserializeObject<List<M12ControlCode>>(
                File.ReadAllText("m12-codelist.json"));
        }

        public bool IsMatch(byte[] rom, int address)
        {
            return rom[address] == Identifier &&
                rom[address + 1] == 0xFF;
        }

        public bool IsMatch(string[] codeStrings)
        {
            if (codeStrings == null || codeStrings.Length < 2)
                return false;

            byte value1 = Convert.ToByte(codeStrings[0], 16);
            byte value2 = Convert.ToByte(codeStrings[1], 16);

            return value1 == Identifier && value2 == 0xFF;
        }

        // Assumes the code has already been matched
        public bool IsValid(string[] codeStrings)
        {
            if (codeStrings == null || codeStrings.Length < 2)
                return false;

            if (!HasReferences)
            {
                if (codeStrings.Length != Length)
                    return false;

                // Check that each codestring is a byte
                for (int i = 2; i < codeStrings.Length; i++)
                {
                    if (!Compiler.IsHexByte(codeStrings[i]))
                        return false;
                }
            }
            else
            {
                // If there's at least one reference, then there must be at least 6 code strings
                if (codeStrings.Length < 6)
                    return false;

                // Check bytes before references
                for (int i = 2; i < ReferenceOffset; i++)
                {
                    if (!Compiler.IsHexByte(codeStrings[i]))
                        return false;
                }

                // Check references
                int numReferences;
                if (!IsVariableLength)
                {
                    numReferences = 1;
                }
                else
                {
                    byte count;

                    if (!byte.TryParse(codeStrings[2], System.Globalization.NumberStyles.HexNumber,
                        null, out count))
                        return false;

                    numReferences = count;
                }

                for (int i = 0; i < numReferences; i++)
                {
                    string reference = codeStrings[(i * 4) + ReferenceOffset];

                    if (reference.Length < 3)
                        return false;

                    if (!(reference[0] == '_' && reference[reference.Length - 1] == '_'))
                        return false;
                }

                // Check bytes after references
                for (int i = ReferenceOffset + (numReferences * 4); i < codeStrings.Length; i++)
                {
                    if (!Compiler.IsHexByte(codeStrings[i]))
                        return false;
                }
            }

            return true;
        }

        public int ComputeLength(byte[] rom, int address)
        {
            if (!IsVariableLength)
            {
                return Length;
            }
            else
            {
                byte count = rom[address + 2];
                return (count * 4) + 3;
            }
        }

        private int GetReference(byte[] rom, int referenceAddress)
        {
            if (AbsoluteAddressing)
                return rom.ReadGbaPointer(referenceAddress);
            else
                return rom.ReadInt(referenceAddress) + referenceAddress;
        }

        public IList<int> GetReferences(byte[] rom, int address)
        {
            if (!HasReferences)
                return null;

            var refs = new List<int>();

            if (!IsVariableLength)
            {
                refs.Add(GetReference(rom, address + ReferenceOffset));
            }
            else
            {
                byte count = rom[address + 2];
                for (int i = 0; i < count; i++)
                {
                    refs.Add(GetReference(rom, address + ReferenceOffset + (i * 4)));
                }
            }

            return refs;
        }

        public IList<CodeString> GetCodeStrings(byte[] rom, int address)
        {
            var codeStrings = new List<CodeString>();

            codeStrings.Add(new CodeByte(Identifier));
            codeStrings.Add(new CodeByte(0xFF));

            int length = ComputeLength(rom, address);

            if (!HasReferences)
            {
                // Direct copy
                for (int i = 2; i < length; i++)
                {
                    codeStrings.Add(new CodeByte(rom[address + i]));
                }
            }
            else
            {
                // Get references
                var references = GetReferences(rom, address);

                // Copy bytes before reference
                for (int i = 2; i < ReferenceOffset; i++)
                {
                    codeStrings.Add(new CodeByte(rom[address + i]));
                }

                // Copy references
                foreach (var reference in references)
                {
                    codeStrings.Add(new CodeReference(reference));
                }

                // Copy bytes after reference
                for (int i = ReferenceOffset + (references.Count * 4); i < length; i++)
                {
                    codeStrings.Add(new CodeByte(rom[address + i]));
                }
            }

            return codeStrings;
        }

        public void Compile(string[] codeStrings, IList<byte> buffer, ref int referenceAddress, IDictionary<string, int> addressMap)
        {
            foreach (var codeString in codeStrings)
            {
                if (codeString[0] == '_')
                {
                    if (codeString[codeString.Length - 1] != '_')
                        throw new Exception("Reference has no closing underscore");

                    if (codeString.Length <= 2)
                        throw new Exception("Reference is empty");

                    string label = codeString.Substring(1, codeString.Length - 2);
                    int pointer = addressMap[label];

                    if (!AbsoluteAddressing)
                    {
                        pointer -= referenceAddress;
                    }
                    else
                    {
                        pointer |= 0x8000000;
                    }

                    if (buffer != null)
                        buffer.AddInt(pointer);
                    referenceAddress += 4;
                }
                else
                {
                    byte value = Convert.ToByte(codeString, 16); 
                    buffer.Add(value);
                    referenceAddress++;
                }
            }
        }

        public string GetCompressedString(byte[] rom, int address)
        {
            throw new InvalidOperationException("Code is not a compressed string");
        }

        public override string ToString()
        {
            return String.Format("[{0:X2} FF]: {1}", Identifier, Description);
        }

        public int CompareTo(M12ControlCode other)
        {
            return Identifier.CompareTo(other.Identifier);
        }

        public int CompareTo(object obj)
        {
            var other = obj as M12ControlCode;
            if (other == null)
                throw new Exception("Cannot compare!");

            return CompareTo(other);
        }
    }
}
