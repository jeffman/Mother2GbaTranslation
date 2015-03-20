using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    public interface ICompiler
    {
        IList<string> ScanString(string str, bool scanCodesOnly);
        IList<string> ScanString(string str, ref int referenceAddress, bool scanCodesOnly);
        void CompileString(string str, IList<byte> buffer, ref int referenceAddress);
    }
}
