using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    interface ICompiler
    {
        void ScanString(string str, ref int referenceAddress);
        void CompileString(string str, IList<byte> buffer, ref int referenceAddress);
    }
}
