using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    class FixedStringCollection
    {
        [JsonConverter(typeof(JsonHexConverter))]
        public int StringsLocation { get; set; }

        public IList<int> TablePointers { get; set; }

        public int NumEntries { get; set; }
        public int EntryLength { get; set; }
        public IList<FixedStringRef> StringRefs { get; set; }
    }
}
