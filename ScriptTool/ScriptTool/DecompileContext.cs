using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class DecompileContext
    {
        public LabelMap LabelMap { get; private set; }
        public IList<string> Strings { get; private set; }

        public DecompileContext()
        {
            LabelMap = new LabelMap();
            Strings = new List<string>();
        }
    }
}
