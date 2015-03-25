using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    class MatchedGroupCollection : IEnumerable<MatchedGroup>
    {
        public string Name { get; set; }
        public List<MatchedGroup> Groups { get; private set; }

        public MatchedGroupCollection(string name)
        {
            Name = name;
            Groups = new List<MatchedGroup>();
        }

        public void SortGroups()
        {
            Groups.Sort((g1, g2) => g1.Refs[Game.Eb].Index.CompareTo(g2.Refs[Game.Eb].Index));
        }

        public IEnumerator<MatchedGroup> GetEnumerator()
        {
            return Groups.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }

        public override string ToString()
        {
            return Name;
        }
    }
}
