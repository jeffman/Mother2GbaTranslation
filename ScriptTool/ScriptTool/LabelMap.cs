using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptTool
{
    class LabelMap
    {
        public IDictionary<int, string> Labels { get; private set; }
        private int counter = 0;

        public LabelMap()
        {
            Labels = new Dictionary<int, string>();
        }

        public string this[int address]
        {
            get
            {
                return Labels[address];
            }
            set
            {
                Labels[address] = value;
            }
        }

        public void Append(int address)
        {
            if (!Labels.ContainsKey(address))
            {
                string newLabel = String.Concat("L", counter.ToString());
                Labels.Add(address, newLabel);
                counter++;
            }
        }

        public void Reset()
        {
            counter = 0;
        }

        public void Clear()
        {
            Reset();
            Labels.Clear();
        }
    }
}
