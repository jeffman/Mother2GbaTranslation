using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    interface IDecompiler
    {
        void ScanRange(byte[] rom, int startAddress, int endAddress);
        string DecompileRange(byte[] rom, int startAddress, int endAddress, bool newLines);
        string DecompileString(byte[] rom, int address, bool newLines);
    }
}
