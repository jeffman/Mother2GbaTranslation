using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    class IndexMapping : IEnumerable<IndexPair>, ICollection<IndexPair>
    {
        public ICollection<IndexPair> Pairs { get; private set; }

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

        public void Add(IndexPair item)
        {
            Pairs.Add(item);
        }

        public void Clear()
        {
            Pairs.Clear();
        }

        public bool Contains(IndexPair item)
        {
            return Pairs.Contains(item);
        }

        public void CopyTo(IndexPair[] array, int arrayIndex)
        {
            Pairs.CopyTo(array, arrayIndex);
        }

        public int Count
        {
            get { return Pairs.Count; }
        }

        public bool IsReadOnly
        {
            get { return Pairs.IsReadOnly; }
        }

        public bool Remove(IndexPair item)
        {
            return Pairs.Remove(item);
        }
    }
}
