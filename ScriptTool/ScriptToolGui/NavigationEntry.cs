using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptToolGui
{
    abstract class NavigationEntry
    {
        public abstract NavigationType Type { get; }
    }

    enum NavigationType
    {
        MatchedGroup,
        Reference
    }

    class MatchedGroupNavigationEntry : NavigationEntry
    {
        public override NavigationType Type { get { return NavigationType.MatchedGroup; } }

        public MatchedGroup Group { get; private set; }

        public MatchedGroupNavigationEntry(MatchedGroup group)
        {
            Group = group;
        }
    }

    class ReferenceNavigationEntry : NavigationEntry
    {
        public override NavigationType Type { get { return NavigationType.Reference; } }

        public string Label { get; private set; }
        public Game Game { get; private set; }

        public ReferenceNavigationEntry(Game game, string label)
        {
            Game = game;
            Label = label;
        }
    }
}
