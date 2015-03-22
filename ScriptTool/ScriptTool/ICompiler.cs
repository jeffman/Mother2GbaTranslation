using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    public interface ICompiler
    {
        void ScanString(string str, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out IList<string> references, out ISet<IControlCode> controlCodes);
        void ScanString(string str, ref int referenceAddress, IDictionary<byte, string> charLookup, bool scanCodesOnly,
            out IList<string> references, out ISet<IControlCode> controlCodes);
        void CompileString(string str, IList<byte> buffer, ref int referenceAddress, IDictionary<byte, string> charLookup);
    }
}
