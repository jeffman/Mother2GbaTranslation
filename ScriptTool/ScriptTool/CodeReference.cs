using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class CodeReference : CodeString
    {
        public int Address { get; set; }

        public CodeReference(int address)
        {
            Address = address;
        }
    }
}
