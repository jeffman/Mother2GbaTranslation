using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptTool;

namespace ScriptToolGui
{
    class IndexLabel
    {
        public int Index { get; private set; }
        public string Label { get; private set; }

        public IndexLabel(int index, string label)
        {
            Index = index;
            Label = label;
        }

        public IndexLabel(MainStringRef stringRef)
            : this(stringRef.Index, stringRef.Label)
        {

        }
    }
}
