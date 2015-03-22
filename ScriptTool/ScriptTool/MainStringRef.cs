using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class MainStringRef
    {
        public int Index { get; set; }
        public int PointerLocation { get; set; }
        public int OldPointer { get; set; }

        public string Label { get; set; }

        public override string ToString()
        {
            return "[" + Index.ToString("X3") + "] " + Label;
        }
    }
}
