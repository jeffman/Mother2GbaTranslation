using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    class IndexPair
    {
        public int First { get; private set; }
        public int Second { get; private set; }

        public IndexPair(int first, int second)
        {
            First = first;
            Second = second;
        }

        public override string ToString()
        {
            return String.Format("First: {0}, Second: {1}", First, Second);
        }
    }
}
