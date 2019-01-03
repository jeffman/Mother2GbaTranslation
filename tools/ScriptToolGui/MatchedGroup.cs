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
        public IDictionary<Game, IndexLabel> Refs { get; private set; }

        public MatchedGroup()
        {
            Refs = new Dictionary<Game, IndexLabel>();
        }

        public MatchedGroup(MainStringRef ebRef, MainStringRef m12Ref)
            : this()
        {
            Refs.Add(Game.Eb, new IndexLabel(ebRef));
            Refs.Add(Game.M12, new IndexLabel(m12Ref));
            Refs.Add(Game.M12English, new IndexLabel(m12Ref));
        }

        public MatchedGroup(MainStringRef m12Ref)
            : this()
        {
            Refs.Add(Game.M12, new IndexLabel(m12Ref));
            Refs.Add(Game.M12English, new IndexLabel(m12Ref));
        }

        public MatchedGroup(int m12Index, string m12Label)
            : this()
        {
            Refs.Add(Game.M12, new IndexLabel(m12Index, m12Label));
            Refs.Add(Game.M12English, new IndexLabel(m12Index, m12Label));
        }

        public MatchedGroup(Game game, int index, string label)
            : this()
        {
            Refs.Add(game, new IndexLabel(index, label));
        }

        public override string ToString()
        {
            var parts = new List<string>();
            
            if (Refs.ContainsKey(Game.Eb))
            {
                parts.Add(String.Format("[{0:D4}] EB: {1}", Refs[Game.Eb].Index, Refs[Game.Eb].Label));
            }
            if (Refs.ContainsKey(Game.M12))
            {
                parts.Add(String.Format("[{0:D4}] M12: {1}", Refs[Game.M12].Index, Refs[Game.M12].Label));
            }

            return String.Join(" / ", parts.ToArray());
        }
    }
}
