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
        [JsonConverter(typeof(JsonHexConverter))]
        public int Index { get; set; }

        [JsonConverter(typeof(JsonHexConverter))]
        public int PointerLocation { get; set; }

        [JsonConverter(typeof(JsonHexConverter))]
        public int OldPointer { get; set; }

        public string Label { get; set; }

        public override string ToString()
        {
            return "[" + Index.ToString("X3") + "] " + Label;
        }
    }
}
