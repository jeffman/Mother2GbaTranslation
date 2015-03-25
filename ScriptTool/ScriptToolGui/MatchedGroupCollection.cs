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
