using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class MiscStringRef
    {
        public int Index { get; set; }
        public int OffsetLocation { get; set; }
        public int OldPointer { get; set; }

        public bool BasicMode { get; set; }
        public string Old { get; set; }
        public string New { get; set; }

        public bool ShouldSerializeBasicMode()
        {
            return BasicMode;
        }
    }
}
