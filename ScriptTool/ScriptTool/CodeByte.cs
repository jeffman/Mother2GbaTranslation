using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class CodeByte : CodeString
    {
        public byte Value { get; set; }

        public CodeByte(byte value)
        {
            Value = value;
        }
    }
}
