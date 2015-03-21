using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using ScriptTool;
using System.IO;
using Newtonsoft.Json;

namespace ScriptToolGui
{
    public partial class MainForm : Form
    {
        // Static/const members
        const string workingFolder = @"..\..\..\..\working";
        static M12Compiler m12Compiler = new M12Compiler();
        static readonly Game[] validGames;

        // Lookups
        IDictionary<Game, TextBox> textboxLookup;
        IDictionary<Game, IList<string>> stringsLookup;

        // Saving changes
        object changeLock = new object();
        bool changesMade = false;

        // Strings
        IList<string> m12Strings;
        IList<string> m12StringsEnglish;
        IList<string> ebStrings;
        
        // Matched reference pairs
        List<MatchedGroup> tptGroups = new List<MatchedGroup>();
        List<MatchedGroup> battleActionGroups = new List<MatchedGroup>();
        List<MatchedGroup> matchedGroups = new List<MatchedGroup>();

        // Navigation stack
        IDictionary<Game, int> currentIndex;
        NavigationEntry previousNavigationState = null;
        Stack<NavigationEntry> navigationStack = new Stack<NavigationEntry>();

        static MainForm()
        {
            validGames = new Game[] { Game.Eb, Game.M12, Game.M12English };
        }

        public MainForm()
        {
            InitializeComponent();

            ImportAllStringRefs(workingFolder);
            ImportAllStrings(workingFolder);

            InitLookups();

            PopulateSelectors();
        }

        private void InitLookups()
        {
            textboxLookup = new Dictionary<Game, TextBox> {
                { Game.Eb, ebString },
                { Game.M12, m12String },
                { Game.M12English, m12StringEnglish }
            };

            stringsLookup = new Dictionary<Game, IList<string>> {
                { Game.Eb, ebStrings },
                { Game.M12, m12Strings },
                { Game.M12English, m12StringsEnglish }
            };

            currentIndex = new Dictionary<Game, int> {
                { Game.Eb, -1 },
                { Game.M12, -1 },
                { Game.M12English,-1 }
            };
        }

        private void ImportAllStringRefs(string folder)
        {
            // TPT
            string m12PrimaryFileName = Path.Combine(folder, "m12-tpt-primary.json");
            string ebPrimaryFileName = Path.Combine(folder, "eb-tpt-primary.json");

            var m12PrimaryTptRefs = ImportStringRefs(m12PrimaryFileName);
            var ebPrimaryTptRefs = ImportStringRefs(ebPrimaryFileName);

            string m12SecondaryFileName = Path.Combine(folder, "m12-tpt-secondary.json");
            string ebSecondaryFileName = Path.Combine(folder, "eb-tpt-secondary.json");

            var m12SecondaryTptRefs = ImportStringRefs(m12SecondaryFileName);
            var ebSecondaryTptRefs = ImportStringRefs(ebSecondaryFileName);

            tptGroups.AddRange(MatchRefs(ebPrimaryTptRefs, m12PrimaryTptRefs));
            tptGroups.AddRange(MatchRefs(ebSecondaryTptRefs, m12SecondaryTptRefs));
            tptGroups.Sort((g1, g2) => g1.Index.CompareTo(g2.Index));

            matchedGroups.AddRange(tptGroups);

            // Battle actions
            string m12BattleActionsFileName = Path.Combine(folder, "m12-battle-actions.json");
            string ebBattleActionsFileName = Path.Combine(folder, "eb-battle-actions.json");

            var m12BattleActionRefs = ImportStringRefs(m12BattleActionsFileName);
            var ebBattleActionRefs = ImportStringRefs(ebBattleActionsFileName);

            battleActionGroups.AddRange(MatchRefs(ebBattleActionRefs, m12BattleActionRefs));
            battleActionGroups.Sort((g1, g2) => g1.Index.CompareTo(g2.Index));

            matchedGroups.AddRange(battleActionGroups);

            matchedGroups.Sort((g1, g2) => g1.Index.CompareTo(g2.Index));

        }

        private MatchedGroup[] MatchRefs(MainStringRef[] ebRefs, MainStringRef[] m12Refs)
        {
            return ebRefs.Join(m12Refs, e => e.Index, m => m.Index, (e, m) => new { e, m })
                .Select(p => new MatchedGroup(p.e, p.m, p.m))
                .ToArray();
        }

        private MainStringRef[] ImportStringRefs(string fileName)
        {
            string jsonString = File.ReadAllText(fileName);
            return JsonConvert.DeserializeObject<MainStringRef[]>(jsonString);
        }

        private void ImportAllStrings(string folder)
        {
            string m12FileName = Path.Combine(folder, "m12-strings.txt");
            string m12EnglishFileName = Path.Combine(folder, "m12-strings-english.txt");
            string ebFileName = Path.Combine(folder, "eb-strings.txt");

            m12Strings = ImportStrings(m12FileName);
            m12StringsEnglish = ImportStrings(m12EnglishFileName);
            ebStrings = ImportStrings(ebFileName);
        }

        private IList<string> ImportStrings(string fileName)
        {
            return new List<string>(File.ReadAllLines(fileName).Where(l => !l.Equals("")));
        }

        private Game GetCurrentGame()
        {
            if (ebSelector.Checked)
                return Game.Eb;

            else if (m12Selector.Checked)
                return Game.M12;

            return Game.None;
        }

        private void PopulateSelectors()
        {
            tptSelector.Items.Clear();
            tptSelector.Items.AddRange(tptGroups.ToArray());

            battleActionSelector.Items.Clear();
            battleActionSelector.Items.AddRange(battleActionGroups.ToArray());
        }

        private void PopulateCodeList()
        {

        }

        private void PopulateReferenceList()
        {
            referenceList.Items.Clear();

            if (ebSelector.Checked)
            {

            }
            else if (m12Selector.Checked)
            {
                var references = m12Compiler.ScanString(m12String.Text, true).Distinct().OrderBy(r => r);
                referenceList.Items.AddRange(references.ToArray());
            }
        }

        private string GetString(Game game, string label)
        {
            int index;
            return GetString(game, label, out index);
        }

        private string GetString(Game game, string label, out int index)
        {
            string labelDef = "^" + label + "^";
            var str = stringsLookup[game].Select((l, i) => new { Index = i, Line = l })
                .FirstOrDefault(a => a.Line.Contains(labelDef));

            if (str == null)
                index = -1;
            else
                index = str.Index;

            if (str == null)
                return null;
            else
                return str.Line;
        }

        private void NavigateTo(MatchedGroup group)
        {
            if (group == null)
            {
                ebString.Text = "";
                m12String.Text = "";
                m12StringEnglish.Text = "";
            }
            else
            {
                int index;

                string eb = GetString(Game.Eb, group.Refs[Game.Eb].Label, out index);
                currentIndex[Game.Eb] = index;

                string m12 = GetString(Game.M12, group.Refs[Game.M12].Label, out index);
                currentIndex[Game.M12] = index;

                string m12English = GetString(Game.M12English, group.Refs[Game.M12].Label, out index);
                currentIndex[Game.M12English] = index;

                ebString.Text = eb;
                m12String.Text = m12;
                m12StringEnglish.Text = m12English;

                previousNavigationState = new MatchedGroupNavigationEntry(group);
            }

            SelectGroup(tptSelector, group);
            SelectGroup(battleActionSelector, group);

            PopulateCodeList();
            PopulateReferenceList();
        }

        private void SelectGroup(ComboBox selector, MatchedGroup group)
        {
            if (group != null && selector.Items.Contains(group))
                selector.SelectedItem = group;
            else
                selector.SelectedIndex = -1;
        }

        private MatchedGroup FindGroup(IEnumerable<MatchedGroup> groups, Game game, string label)
        {
            // Attempt to find the label
            string labelDef = "^" + label + "^";
            string str = stringsLookup[game].First(l => l.Contains(labelDef));
            var match = groups.FirstOrDefault(g => str.Contains("^" + g.Refs[game].Label + "^"));
            return match;
        }

        private void NavigateTo(Game game, string label)
        {
            foreach (var eachGame in validGames)
            {
                currentIndex[eachGame] = -1;
                textboxLookup[eachGame].Text = "";
            }

            string labelDef = "^" + label + "^";

            int index;
            textboxLookup[game].Text = GetString(game, label, out index);
            currentIndex[game] = index;

            if (game == Game.M12)
            {
                textboxLookup[Game.M12English].Text = GetString(Game.M12English, label, out index);
                currentIndex[Game.M12English] = index;
            }
            else if (game == Game.M12English)
            {
                textboxLookup[Game.M12].Text = GetString(Game.M12, label, out index);
                currentIndex[Game.M12] = index;
            }

            previousNavigationState = new ReferenceNavigationEntry(game, label);

            MatchedGroup match = FindGroup(matchedGroups, game, label);

            // Check if any other games have this matched ref
            if (match != null)
            {
                foreach (var otherGame in match.Refs.Where(kv => kv.Key != game))
                {
                    labelDef = "^" + otherGame.Value.Label + "^";
                    textboxLookup[otherGame.Key].Text = GetString(otherGame.Key, otherGame.Value.Label, out index);
                    currentIndex[game] = index;
                    //stringsLookup[otherGame.Key].First(l => l.Contains(labelDef));
                }
            }

            SelectGroup(tptSelector, match);
            SelectGroup(battleActionSelector, match);

            PopulateCodeList();
            PopulateReferenceList();
        }

        private void PushPreviousNavigationState()
        {
            if (previousNavigationState == null)
                return;

            navigationStack.Push(previousNavigationState);
        }
        
        private void SaveCurrentState()
        {
            lock (changeLock)
            {
                foreach (var game in validGames)
                {
                    if (currentIndex[game] >= 0)
                    {
                        string oldString = stringsLookup[game][currentIndex[game]];
                        string newString = textboxLookup[game].Text;
                        stringsLookup[game][currentIndex[game]] = newString;

                        if (game == Game.M12English && oldString != newString)
                            changesMade = true;
                    }
                }
            }
        }

        private void WriteChanges()
        {
            SaveCurrentState();

            lock (changeLock)
            {
                if (changesMade)
                {
                    using (StreamWriter sw = File.CreateText(Path.Combine(workingFolder, "m12-strings-english.txt")))
                    {
                        foreach (string line in m12StringsEnglish)
                        {
                            sw.WriteLine(line);
                        }
                    }

                    UpdateStatus(String.Format("Last saved: {0:G}", DateTime.Now));
                    changesMade = false;
                }
            }
        }

        private void UpdateStatus(string text)
        {
            if (statusBar.InvokeRequired)
            {
                statusBar.Invoke(new Action<string>(UpdateStatus), text);
            }
            else
            {
                statusLabel.Text = text;
            }
        }

        private void selector_SelectionChangeCommitted(object sender, EventArgs e)
        {
            var selector = (ComboBox)sender;

            SaveCurrentState();

            if (selector.SelectedIndex == -1)
                NavigateTo(null);
            else
            {
                PushPreviousNavigationState();

                var currentGroup = (MatchedGroup)selector.SelectedItem;
                NavigateTo(currentGroup);
            }
        }

        private void gameSelector_CheckedChanged(object sender, EventArgs e)
        {
            PopulateCodeList();
            PopulateReferenceList();
        }

        private void referenceList_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            int match = referenceList.IndexFromPoint(e.Location);
            if (match != ListBox.NoMatches)
            {
                Game game = GetCurrentGame();
                string label = (string)referenceList.SelectedItem;

                // Only navigate if we're not already at the target label
                if (!stringsLookup[game].Contains("^" + label + "^"))
                {
                    SaveCurrentState();

                    PushPreviousNavigationState();
                    NavigateTo(game, label);
                }
            }
        }

        private void backButton_Click(object sender, EventArgs e)
        {
            if (navigationStack.Count < 1)
                return;
            
            SaveCurrentState();

            var nav = navigationStack.Pop();

            if (nav.Type == NavigationType.MatchedGroup)
            {
                var matchedEntry = (MatchedGroupNavigationEntry)nav;
                NavigateTo(matchedEntry.Group);
            }
            else if (nav.Type == NavigationType.Reference)
            {
                var referenceEntry = (ReferenceNavigationEntry)nav;
                NavigateTo(referenceEntry.Game, referenceEntry.Label);
            }
        }

        private void saveMenu_Click(object sender, EventArgs e)
        {
            WriteChanges();
        }

        private void writeTimer_Tick(object sender, EventArgs e)
        {
            WriteChanges();
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            WriteChanges();
        }

        private void copyCodesButton_Click(object sender, EventArgs e)
        {
            m12StringEnglish.Text = m12Compiler.StripText(m12String.Text);
        }
    }

    enum Game
    {
        None,
        Eb,
        M2,
        M12,
        M12English
    }
}
