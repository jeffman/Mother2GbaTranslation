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
        bool IsMatch(byte[] rom, int address);
        bool IsMatch(string[] codeStrings);
        bool IsValid(string[] codeStrings);
        int ComputeLength(byte[] rom, int address);
        IList<int> GetReferences(byte[] rom, int address);
        IList<CodeString> GetCodeStrings(byte[] rom, int address);
    }
}
