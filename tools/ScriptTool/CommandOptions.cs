using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class CommandOptions
    {
        public string WorkingDirectory { get; set; }
        public CommandType Command { get; set; }
        public bool DoMiscText { get; set; }
        public bool DoMainText { get; set; }
        public string EbRom { get; set; }
        public string M12Rom { get; set; }
    }

    enum CommandType
    {
        Compile,
        Decompile
    }
}
