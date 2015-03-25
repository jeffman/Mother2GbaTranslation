using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    class IndexMapping : IEnumerable<IndexPair>
    {
        public IList<IndexPair> Pairs { get; private set; }

        public IndexMapping()
        {
            Pairs = new List<IndexPair>();
        }

        public void Add(int first, int second)
        {
            Pairs.Add(new IndexPair(first, second));
        }

        public IEnumerator<IndexPair> GetEnumerator()
        {
            return Pairs.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}
