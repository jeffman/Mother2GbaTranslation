using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class EbControlCode : IControlCode, IComparable, IComparable<EbControlCode>
    {
        public static IEnumerable<IControlCode> Codes { get; private set; }
        private static string[][] compressedStrings;

        public IList<byte> Identifier { get; set; }
        public string Description { get; set; }
        public bool IsEnd { get; set; }
        public bool IsCompressedString { get; set; }
        public int Length { get; set; }
        public bool IsVariableLength { get; set; }
        public int ReferenceOffset { get; set; }
        public int CountOffset { get; set; }
        public bool HasReferences { get; set; }
        public bool AbsoluteAddressing { get { return true; } }
        public bool SuppressNextEnd { get; set; }

        static EbControlCode()
        {
            // Load compressed strings
            compressedStrings = new string[3][];
            string[] stringsFromFile = Asset.ReadAllLines("eb-compressed-strings.txt");
            compressedStrings[0] = stringsFromFile.Take(0x100).ToArray();
            compressedStrings[1] = stringsFromFile.Skip(0x100).Take(0x100).ToArray();
            compressedStrings[2] = stringsFromFile.Skip(0x200).Take(0x100).ToArray();

            // Load codes
            Codes = JsonConvert.DeserializeObject<List<EbControlCode>>(
                Asset.ReadAllText("eb-codelist.json"));
        }

        public bool IsMatch(byte[] rom, int address)
        {
            for (int i = 0; i < Identifier.Count; i++)
                if (rom[address + i] != Identifier[i])
                    return false;

            return true;
        }

        public bool IsMatch(string[] codeStrings)
        {
            if (codeStrings == null || codeStrings.Length < Identifier.Count)
                return false;

            for (int i = 0; i < Identifier.Count; i++)
                if (Convert.ToByte(codeStrings[i], 16) != Identifier[i])
                    return false;

            return true;
        }

        public bool IsValid(string[] codeStrings)
        {
            if (codeStrings == null || codeStrings.Length < 1)
                return false;

            if (!HasReferences)
            {
                if (codeStrings.Length != Length)
                    return false;

                // Check that each codestring is a byte
                for (int i = Identifier.Count; i < codeStrings.Length; i++)
                {
                    if (!Compiler.IsHexByte(codeStrings[i]))
                        return false;
                }
            }
            else
            {
                // If there's at least one reference, then there must be at least 5 code strings
                if (codeStrings.Length < 5)
                    return false;

                // Check bytes before references
                for (int i = Identifier.Count; i < ReferenceOffset; i++)
                {
                    if (!Compiler.IsHexByte(codeStrings[i]))
                        return false;
                }

                // Check references
                int numReferences;
                if (!IsVariableLength)
                {
                    numReferences = (Length - ReferenceOffset) / 4;
                }
                else
                {
                    byte count;

                    if (!byte.TryParse(codeStrings[CountOffset], System.Globalization.NumberStyles.HexNumber,
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
                int count = rom[address + CountOffset];
                return (count * 4) + 1 + Identifier.Count;
            }
        }

        private int GetReference(byte[] rom, int referenceAddress)
        {
            return rom.ReadSnesPointer(referenceAddress);
        }

        public IList<int> GetReferences(byte[] rom, int address)
        {
            if (!HasReferences)
                return null;

            var refs = new List<int>();

            if (!IsVariableLength)
            {
                for (int i = ReferenceOffset; i < Length; i += 4)
                    refs.Add(GetReference(rom, address + i));
            }
            else
            {
                int count = rom[address + CountOffset];
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

            foreach (var b in Identifier)
                codeStrings.Add(new CodeByte(b));

            int length = ComputeLength(rom, address);

            if (!HasReferences)
            {
                // Direct copy
                for (int i = Identifier.Count; i < length; i++)
                {
                    codeStrings.Add(new CodeByte(rom[address + i]));
                }
            }
            else
            {
                // Get references
                var references = GetReferences(rom, address);

                // Copy bytes before reference
                for (int i = Identifier.Count; i < ReferenceOffset; i++)
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
                    int pointer = addressMap[label] + 0xC00000;

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
            return compressedStrings[rom[address] - 0x15][rom[address + 1]];
        }

        public override string ToString()
        {
            return String.Format("[{0}]: {1}", String.Join(" ", Identifier.Select(b => b.ToString("X2")).ToArray()), Description);
        }

        #region JSON
        public bool ShouldSerializeIsEnd()
        {
            return IsEnd;
        }

        public bool ShouldSerializeIsCompressedString()
        {
            return IsCompressedString;
        }

        public bool ShouldSerializeIsVariableLength()
        {
            return IsVariableLength;
        }

        public bool ShouldSerializeHasReferences()
        {
            return HasReferences;
        }

        public bool ShouldSerializeAbsoluteAddressing()
        {
            return AbsoluteAddressing;
        }

        public bool ShouldSerializeReferenceOffset()
        {
            return HasReferences;
        }

        public bool ShouldSerializeCountOffset()
        {
            return IsVariableLength;
        }

        public bool ShouldSerializeSuppressNextEnd()
        {
            return SuppressNextEnd;
        }

        #endregion

        public int CompareTo(EbControlCode other)
        {
            int numToCheck = Math.Min(Identifier.Count, other.Identifier.Count);

            for (int i = 0; i < numToCheck; i++)
            {
                if (Identifier[i] != other.Identifier[i])
                {
                    return Identifier[i].CompareTo(other.Identifier[i]);
                }
            }

            return 0;
        }

        public int CompareTo(object obj)
        {
            var other = obj as EbControlCode;
            if (other == null)
                throw new Exception("Cannot compare!");

            return CompareTo(other);
        }
    }
}
