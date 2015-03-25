using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    struct IndexPair
    {
        public readonly int First;
        public readonly int Second;

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
