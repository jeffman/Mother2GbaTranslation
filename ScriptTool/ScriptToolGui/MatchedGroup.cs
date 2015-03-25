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

        public MatchedGroup()
        {
            Refs = new Dictionary<Game, MainStringRef>();
        }

        public MatchedGroup(MainStringRef ebRef, MainStringRef m12Ref, MainStringRef m12EnglishRef)
            : this()
        {
            Refs.Add(Game.Eb, ebRef);
            Refs.Add(Game.M12, m12Ref);
            Refs.Add(Game.M12English, m12EnglishRef);
        }

        public override string ToString()
        {
            return String.Format("[{0:X3}] EB: {1} / [{2:X3}] M12: {3}",
                Refs[Game.Eb].Index, Refs[Game.Eb].Label,
                Refs[Game.M12].Index, Refs[Game.M12].Label);
        }
    }
}
