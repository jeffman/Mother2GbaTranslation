using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    public interface IControlCode
    {
        bool IsEnd { get; }
        bool IsCompressedString { get; }
        bool IsMatch(byte[] rom, int address);
        bool IsMatch(string[] codeStrings);
        bool IsValid(string[] codeStrings);
        bool HasReferences { get; }
        bool AbsoluteAddressing { get; }

        int ComputeLength(byte[] rom, int address);
        IList<int> GetReferences(byte[] rom, int address);
        IList<CodeString> GetCodeStrings(byte[] rom, int address);
        string GetCompressedString(byte[] rom, int address);
        void Compile(string[] codeStrings, IList<byte> buffer, ref int referenceAddress, IDictionary<string, int> addressMap);
    }
}
