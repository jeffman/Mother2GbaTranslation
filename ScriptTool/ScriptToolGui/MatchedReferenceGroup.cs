using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptTool;

namespace ScriptToolGui
{
    class MatchedReferenceGroup
    {
        public MainStringRef EbRef { get; private set; }
        public MainStringRef M12Ref { get; private set; }

        public MatchedReferenceGroup(MainStringRef ebRef, MainStringRef m12Ref)
        {
            if(ebRef.Index != m12Ref.Index)
            {

            }
            EbRef = ebRef;
            M12Ref = m12Ref;
        }

        public override string ToString()
        {
            return String.Format("[{0:X3}] EB: {1} / M12: {2}", EbRef.Index.ToString("X3"),
                EbRef.Label, M12Ref.Label);
        }
    }
}
