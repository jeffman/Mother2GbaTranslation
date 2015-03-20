using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    class NavigationLabel
    {
        public Game Game { get; private set; }
        public string Label { get; private set; }

        public NavigationLabel(Game game, string label)
        {
            Game = game;
            Label = label;
        }
    }
}
