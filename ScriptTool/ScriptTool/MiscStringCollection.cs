using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScriptTool
{
    public class MiscStringCollection
    {
        public int OffsetTableLocation { get; set; }
        public int StringsLocation { get; set; }

        public IList<MiscStringRef> StringRefs { get; set; }
    }
}
