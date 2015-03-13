using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    class MiscStringCollection
    {
        [JsonConverter(typeof(JsonHexConverter))]
        public int OffsetTableLocation { get; set; }

        [JsonConverter(typeof(JsonHexConverter))]
        public int StringsLocation { get; set; }

        public IList<MiscStringRef> StringRefs { get; set; }
    }
}
