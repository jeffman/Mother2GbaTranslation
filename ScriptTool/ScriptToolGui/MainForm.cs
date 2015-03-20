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
        static IDictionary<Game, TextBox> textboxLookup;
        static IDictionary<Game, IList<string>> stringsLookup;

        const string workingFolder = @"..\..\..\..\working";
        static M12Compiler m12Compiler = new M12Compiler();

        // Strings
        IList<string> m12Strings;
        IList<string> m12StringsEnglish;
        IList<string> ebStrings;
        
        // Matched reference pairs
        List<MatchedReferenceGroup> matchedGroups = new List<MatchedReferenceGroup>();

        // Navigation stack
        MatchedReferenceGroup previousGroup = null;
        Stack<MatchedReferenceGroup> navigationStack = new Stack<MatchedReferenceGroup>();

        public MainForm()
        {
            InitializeComponent();

            ImportAllStringRefs(workingFolder);
            ImportAllStrings(workingFolder);

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

            PopulateTptList();
        }

        private void ImportAllStringRefs(string folder)
        {
            string m12PrimaryFileName = Path.Combine(folder, "m12-tpt-primary.json");
            string ebPrimaryFileName = Path.Combine(folder, "eb-tpt-primary.json");

            var m12PrimaryTptRefs = ImportStringRefs(m12PrimaryFileName);
            var ebPrimaryTptRefs = ImportStringRefs(ebPrimaryFileName);

            string m12SecondaryFileName = Path.Combine(folder, "m12-tpt-secondary.json");
            string ebSecondaryFileName = Path.Combine(folder, "eb-tpt-secondary.json");

            var m12SecondaryTptRefs = ImportStringRefs(m12SecondaryFileName);
            var ebSecondaryTptRefs = ImportStringRefs(ebSecondaryFileName);

            matchedGroups.AddRange(MatchRefs(ebPrimaryTptRefs, m12PrimaryTptRefs));
            matchedGroups.AddRange(MatchRefs(ebSecondaryTptRefs, m12SecondaryTptRefs));

            matchedGroups.Sort((g1, g2) => g1.EbRef.Index.CompareTo(g2.EbRef.Index));
        }

        private MatchedReferenceGroup[] MatchRefs(MainStringRef[] ebRefs, MainStringRef[] m12Refs)
        {
            return ebRefs.Join(m12Refs, e => e.Index, m => m.Index, (e, m) => new { e, m })
                .Select(p => new MatchedReferenceGroup(p.e, p.m))
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

        private void PopulateTptList()
        {
            tptSelector.Items.Clear();
            tptSelector.Items.AddRange(matchedGroups.ToArray());
        }

        private void PopulateCodeList()
        {

        }

        private void PopulateReferenceList()
        {
            codeList.Text = "";
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
            try
            {
                return stringsLookup[game].First(l => l.Contains("^" + label + "^"));
            }
            catch
            {
                return null;
            }
        }

        private void NavigateTo(MatchedReferenceGroup group)
        {
            if (group == null)
            {
                ebString.Text = "";
                m12String.Text = "";
                m12StringEnglish.Text = "";

                tptSelector.SelectedIndex = -1;
            }
            else
            {
                string eb = GetString(Game.Eb, group.EbRef.Label);
                string m12 = GetString(Game.M12, group.M12Ref.Label);
                string m12English = GetString(Game.M12English, group.M12Ref.Label);

                ebString.Text = eb;
                m12String.Text = m12;
                m12StringEnglish.Text = m12English;

                tptSelector.SelectedItem = group;
            }

            PopulateCodeList();
            PopulateReferenceList();
        }

        private void NavigateTo(Game game, string label)
        {

        }

        private void PushPreviousGroup()
        {
            if (previousGroup != null)
            {
                navigationStack.Push(previousGroup);
            }
        }

        private void tptSelector_SelectionChangeCommitted(object sender, EventArgs e)
        {
            if (tptSelector.SelectedIndex == -1)
                NavigateTo(null);
            else
            {
                PushPreviousGroup();

                var currentGroup = (MatchedReferenceGroup)tptSelector.SelectedItem;
                NavigateTo(currentGroup);
                previousGroup = currentGroup;
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

                
            }
        }

        private void backButton_Click(object sender, EventArgs e)
        {
            if (navigationStack.Count < 1)
                return;

            var group = navigationStack.Pop();
            NavigateTo(group);
            previousGroup = group;
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
