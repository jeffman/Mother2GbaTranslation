using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptTool;

namespace ScriptToolGui
{
    class MatchedGroup
    {
        public IDictionary<Game, MainStringRef> Refs { get; private set; }
        public int Index { get; private set; }

        public MatchedGroup()
        {
            Refs = new Dictionary<Game, MainStringRef>();
        }

        public MatchedGroup(MainStringRef ebRef, MainStringRef m12Ref, MainStringRef m12EnglishRef)
            : this()
        {
            if (ebRef.Index != m12Ref.Index)
            {

            }

            Refs.Add(Game.Eb, ebRef);
            Refs.Add(Game.M12, m12Ref);
            Refs.Add(Game.M12English, m12EnglishRef);

            Index = ebRef.Index;
        }

        public override string ToString()
        {
            return String.Format("[{0:X3}] EB: {1} / M12: {2}", Index.ToString("X3"),
                Refs[Game.Eb].Label, Refs[Game.M12].Label);
        }
    }
}
