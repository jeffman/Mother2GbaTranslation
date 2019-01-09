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
        // Config
        static readonly string configFile = "config.json";
        Config config;

        // Static/const members
        static Compiler m12Compiler = new Compiler(M12ControlCode.Codes, (rom, address) => rom[address + 1] == 0xFF);
        static Compiler ebCompiler = new Compiler(EbControlCode.Codes, (rom, address) => rom[address] < 0x20);
        static readonly Game[] validGames;
        static IDictionary<byte, string> ebCharLookup;
        static IDictionary<byte, string> m12CharLookup;

        // Lookups
        Dictionary<Game, TextBox> textboxLookup;
        Dictionary<Game, List<string>> stringsLookup;

        // Saving changes
        object changeLock = new object();

        // Strings
        List<string> m12Strings;
        List<string> m12StringsEnglish;
        List<string> ebStrings;
        
        // Index mappings
        IndexMapping itemMapping = new IndexMapping();

        // Matched reference pairs
        MatchedGroupCollection tptGroups = new MatchedGroupCollection("TPT", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection battleActionGroups = new MatchedGroupCollection("Battle actions", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection itemHelpGroups = new MatchedGroupCollection("Item help", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection psiHelpGroups = new MatchedGroupCollection("PSI help", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection enemyEncounterGroups = new MatchedGroupCollection("Enemy encounters", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection enemyDeathGroups = new MatchedGroupCollection("Enemy deaths", Game.Eb, Game.M12, Game.M12English);
        MatchedGroupCollection rawM12Groups = new MatchedGroupCollection("Raw M12 strings", Game.M12, Game.M12English);
        MatchedGroupCollection rawEbGroups = new MatchedGroupCollection("Raw EB strings", Game.Eb);
        List<MatchedGroupCollection> matchedCollections = new List<MatchedGroupCollection>();

        // Navigation stack
        IDictionary<Game, int> currentIndex;
        NavigationEntry previousNavigationState = null;
        Stack<NavigationEntry> navigationStack = new Stack<NavigationEntry>();
        MatchedGroupCollection currentCollection = null;

        // Misc
        bool badStart = false;

        static MainForm()
        {
            validGames = new Game[] { Game.Eb, Game.M12, Game.M12English };
            ebCharLookup = JsonConvert.DeserializeObject<Dictionary<byte, string>>(Asset.ReadAllText("eb-char-lookup.json"));
            m12CharLookup = JsonConvert.DeserializeObject<Dictionary<byte, string>>(Asset.ReadAllText("m12-char-lookup.json"));
        }

        string ReadEbString(byte[] rom, int address, int length)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < length && rom[address] != 0; i++)
            {
                sb.Append((char)(rom[address++] - 0x30));
            }
            return sb.ToString();
        }

        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            try
            {
                config = GetConfig();
                if (config == null)
                {
                    MessageBox.Show("Could not load a valid configuration. The application will now exit.");
                    Close();
                }

                previewer.M12Compiler = m12Compiler;
                previewer.CharLookup = ebCharLookup;

                ImportAllStrings();
                ImportAllStringRefs();

                InitLookups();

                PopulateCollectionSelector();

                collectionSelector.SelectedIndex = 0;
                collectionSelector_SelectionChangeCommitted(null, null);

                Activate();
            }
            catch (Exception ex)
            {
                badStart = true;
                MessageBox.Show($"There was an error starting the tool.{Environment.NewLine}{ex}");
                Close();
            }
        }

        private Config GetConfig()
        {
            config = Config.Read(configFile);

            if (config == null)
            {
                if (MessageBox.Show($"There was a problem reading {configFile}. Create a new one now?",
                    "Config error",
                    MessageBoxButtons.YesNo) == DialogResult.Yes)
                {
                    using (var dialog = new FolderBrowserDialog())
                    {
                        dialog.Description = "Select the working folder for the repository";
                        dialog.RootFolder = Environment.SpecialFolder.MyComputer;
                        dialog.ShowNewFolderButton = false;

                        if (dialog.ShowDialog() == DialogResult.OK)
                        {
                            config = new Config { WorkingFolder = dialog.SelectedPath };
                            config.Write(configFile);
                        }
                    }
                }
            }

            return config;
        }

        private void PopulateCollectionSelector()
        {
            collectionSelector.Items.Clear();
            collectionSelector.Items.AddRange(matchedCollections.ToArray());
        }

        private void PopulateGroupSelector(MatchedGroupCollection collection)
        {
            groupSelector.Items.Clear();

            if (collection != null)
            {
                groupSelector.Items.AddRange(collection.Groups.ToArray());
            }
        }

        private void InitLookups()
        {
            textboxLookup = new Dictionary<Game, TextBox> {
                { Game.Eb, ebString },
                { Game.M12, m12String },
                { Game.M12English, m12StringEnglish }
            };

            stringsLookup = new Dictionary<Game, List<string>> {
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

        private void ImportAllStringRefs()
        {
            // TPT
            var m12PrimaryTptRefs = ImportStringRefs("m12-tpt-primary.json");
            var ebPrimaryTptRefs = ImportStringRefs("eb-tpt-primary.json");

            var m12SecondaryTptRefs = ImportStringRefs("m12-tpt-secondary.json");
            var ebSecondaryTptRefs = ImportStringRefs("eb-tpt-secondary.json");

            tptGroups.Groups.AddRange(MatchRefs(ebPrimaryTptRefs, m12PrimaryTptRefs));
            tptGroups.Groups.AddRange(MatchRefs(ebSecondaryTptRefs, m12SecondaryTptRefs));
            tptGroups.SortGroups();

            // Battle actions
            var m12BattleActionRefs = ImportStringRefs("m12-battle-actions.json");
            var ebBattleActionRefs = ImportStringRefs("eb-battle-actions.json");

            battleActionGroups.Groups.AddRange(MatchRefs(ebBattleActionRefs, m12BattleActionRefs));
            battleActionGroups.SortGroups();

            // Item help
            itemMapping = JsonConvert.DeserializeObject<IndexMapping>(Asset.ReadAllText("item-map.json"));
            var m12ItemHelpRefs = ImportStringRefs("m12-item-help.json");
            var ebItemHelpRefs = ImportStringRefs("eb-item-help.json");

            var itemHelpMappingGroups = itemMapping.Select(p => new MatchedGroup(
                ebItemHelpRefs.First(e => e.Index == p.First),
                m12ItemHelpRefs.First(m => m.Index == p.Second)))
                .OrderBy(g => g.Refs[Game.Eb].Index)
                .ToArray();

            itemHelpGroups.Groups.AddRange(itemHelpMappingGroups);

            // PSI help
            var m12PsiHelpRefs = ImportStringRefs("m12-psi-help.json");
            var ebPsiHelpRefs = ImportStringRefs("eb-psi-help.json");

            var psiHelpMappingGroups = ebPsiHelpRefs.Select(e =>
                new MatchedGroup(e,
                    m12PsiHelpRefs.First(m => m.Index == e.Index - 1)))
                    .ToArray();

            psiHelpGroups.Groups.AddRange(psiHelpMappingGroups);
            psiHelpGroups.SortGroups();

            // Enemy encounters
            var m12EncounterRefs = ImportStringRefs("m12-enemy-encounters.json");
            var ebEncounterRefs = ImportStringRefs("eb-enemy-encounters.json");

            enemyEncounterGroups.Groups.AddRange(MatchRefs(ebEncounterRefs, m12EncounterRefs));

            // Enemy deaths
            var m12DeathRefs = ImportStringRefs("m12-enemy-deaths.json");
            var ebDeathRefs = ImportStringRefs("eb-enemy-deaths.json");

            enemyDeathGroups.Groups.AddRange(MatchRefs(ebDeathRefs, m12DeathRefs));

            // Raw M12
            var labels = Enumerable.Range(0, 5864);
            foreach (int i in labels)
            {
                rawM12Groups.Groups.Add(new MatchedGroup(i, "L" + i.ToString()));
            }

            // Raw EB
            labels = Enumerable.Range(0, 5357);
            foreach (int i in labels)
            {
                rawEbGroups.Groups.Add(new MatchedGroup(Game.Eb, i, "L" + i.ToString()));
            }

            matchedCollections.Add(tptGroups);
            matchedCollections.Add(battleActionGroups);
            matchedCollections.Add(itemHelpGroups);
            matchedCollections.Add(psiHelpGroups);
            matchedCollections.Add(enemyEncounterGroups);
            matchedCollections.Add(enemyDeathGroups);
            matchedCollections.Add(rawM12Groups);
            matchedCollections.Add(rawEbGroups);
        }

        private MatchedGroup[] MatchRefs(MainStringRef[] ebRefs, MainStringRef[] m12Refs)
        {
            return ebRefs.Join(m12Refs, e => e.Index, m => m.Index,
                (e, m) => new { e, m })
                .Select(p => new MatchedGroup(p.e, p.m))
                .ToArray();
        }

        private MainStringRef[] ImportStringRefs(string fileName)
        {
            string jsonString = File.ReadAllText(Path.Combine(config.WorkingFolder, fileName));
            return JsonConvert.DeserializeObject<MainStringRef[]>(jsonString);
        }

        private void ImportAllStrings()
        {
            string m12FileName = Path.Combine(config.WorkingFolder, "m12-strings.txt");
            string m12EnglishFileName = Path.Combine(config.WorkingFolder, "m12-strings-english.txt");
            string ebFileName = Path.Combine(config.WorkingFolder, "eb-strings.txt");

            m12Strings = ImportStrings(m12FileName);
            m12StringsEnglish = ImportStrings(m12EnglishFileName);
            ebStrings = ImportStrings(ebFileName);
        }

        private List<string> ImportStrings(string fileName)
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

        private void PopulateCodeList()
        {
            codeList.Items.Clear();
            ISet<IControlCode> codes = null;

            if (ebSelector.Checked)
                ebCompiler.ScanString(ebString.Text, ebCharLookup, true, out codes);

            else if (m12Selector.Checked)
                m12Compiler.ScanString(m12String.Text, ebCharLookup, true, out codes);

            var sorted = codes.Distinct().OrderBy(c => c).ToArray();
            codeList.Items.AddRange(sorted.ToArray());
        }

        private void PopulateReferenceList()
        {
            referenceList.Items.Clear();
            IList<string> references = null;

            if (ebSelector.Checked)
                ebCompiler.ScanString(ebString.Text, ebCharLookup, true, out references);

            else if (m12Selector.Checked)
                m12Compiler.ScanString(m12String.Text, ebCharLookup, true, out references);

            references = references.Distinct().OrderBy(r => r).ToList();
            referenceList.Items.AddRange(references.ToArray());
        }

        private string GetString(Game game, MatchedGroup group)
        {
            int index;
            return GetString(game, group, out index);
        }

        private string GetString(Game game, MatchedGroup group, out int index)
        {
            if (!group.Refs.ContainsKey(game))
            {
                index = -1;
                return null;
            }

            return GetString(game, group.Refs[game].Label, out index);
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

        private void NavigateTo(MatchedGroup group, MatchedGroupCollection collection)
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

                string eb = GetString(Game.Eb, group, out index);
                currentIndex[Game.Eb] = index;

                string m12 = GetString(Game.M12, group, out index);
                currentIndex[Game.M12] = index;

                string m12English = GetString(Game.M12English, group, out index);
                currentIndex[Game.M12English] = index;

                ebString.Text = eb;
                m12String.Text = m12;
                m12StringEnglish.Text = m12English;

                previousNavigationState = new MatchedGroupNavigationEntry(group, collection);

                if (m12 != null && m12 == m12Compiler.StripText(m12))
                {
                    m12String.BackColor = Color.Orange;
                }
                else
                {
                    m12String.BackColor = SystemColors.Control;
                }
            }

            PopulateCodeList();
            PopulateReferenceList();

            previewButton_Click(null, null);
        }

        private void SelectGroup(MatchedGroup group, MatchedGroupCollection collection)
        {
            if (collection != null)
            {
                if ((MatchedGroupCollection)collectionSelector.SelectedItem !=
                        collection)
                {
                    collectionSelector.SelectedItem = collection;
                    PopulateGroupSelector(collection);
                }

                if (group != null)
                {
                    groupSelector.SelectedItem = group;
                }
                else
                {
                    groupSelector.SelectedIndex = -1;
                }
            }
            else
            {
                collectionSelector.SelectedIndex = -1;
                groupSelector.SelectedIndex = -1;
            }

            currentCollection = collection;
        }

        private void FindGroup(Game game, string label, out MatchedGroup group, out MatchedGroupCollection collection)
        {
            // Attempt to find the label
            string labelDef = "^" + label + "^";
            string str = stringsLookup[game].First(s => s.Contains(labelDef));

            foreach (var coll in matchedCollections.Where(c => c.Games.Contains(game)))
            {
                var match = coll.Groups.FirstOrDefault(g => str.Contains("^" + g.Refs[game].Label + "^"));
                if (match != null)
                {
                    group = match;
                    collection = coll;
                    return;
                }
            }

            group = null;
            collection = null;
        }

        private void NavigateTo(Game game, string label, out MatchedGroup group, out MatchedGroupCollection collection)
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

            if (game == Game.M12 || game == Game.M12English)
            {
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

                string m12 = textboxLookup[Game.M12].Text;
                if (m12 != null && m12 == m12Compiler.StripText(m12))
                {
                    m12String.BackColor = Color.Orange;
                }
                else
                {
                    m12String.BackColor = SystemColors.Control;
                }
            }
            else
            {
                m12String.BackColor = SystemColors.Control;
            }

            previousNavigationState = new ReferenceNavigationEntry(game, label);

            FindGroup(game, label, out group, out collection);

            // Check if any other games have this matched ref
            if (group != null)
            {
                foreach (var otherGame in group.Refs.Where(kv => kv.Key != game))
                {
                    labelDef = "^" + otherGame.Value.Label + "^";
                    textboxLookup[otherGame.Key].Text = GetString(otherGame.Key, otherGame.Value.Label, out index);
                    currentIndex[otherGame.Key] = index;
                }
            }

            PopulateCodeList();
            PopulateReferenceList();

            previewButton_Click(null, null);
        }

        private void PushPreviousNavigationState()
        {
            if (previousNavigationState == null)
                return;

            navigationStack.Push(previousNavigationState);
        }
        
        private async void SaveCurrentState(bool insertEndcode)
        {
            string endcodeInsertion = null;

            lock (changeLock)
            {
                foreach (var game in validGames)
                {
                    if (currentIndex[game] >= 0)
                    {
                        string oldString = stringsLookup[game][currentIndex[game]];
                        string newString = textboxLookup[game].Text.Replace(Environment.NewLine, "");

                        if (game == Game.M12English)
                        {
                            if (insertEndcode)
                            {
                                // Special case -- for M12 English, if the line is modified,
                                // check for an end code and insert if it's missing
                                var lastCode = m12Compiler.GetLastControlCode(newString);

                                if (!IsJustALabel(newString) && (lastCode == null || (lastCode != null
                                    && !lastCode.IsEnd)))
                                {
                                    newString += "[00 FF]";
                                    endcodeInsertion = "Inserted missing [00 FF]";
                                }
                            }
                        }

                        stringsLookup[game][currentIndex[game]] = newString;

                        if (!textboxLookup[game].Text.Equals(newString))
                        {
                            // Update the text box as well
                            textboxLookup[game].Text = newString;
                        }
                    }
                }
            }

            if (endcodeInsertion != null)
            {
                await SetMessageLabel(endcodeInsertion);
            }
        }

        public static bool IsJustALabel(string str)
        {
            return (str.Length > 2) && (str[0] == '^') &&
                (str[str.Length - 1] == '^') && !str.Skip(1).Take(str.Length - 2).Contains('^');
        }

        private void WriteChanges(bool insertEndcode)
        {
            SaveCurrentState(insertEndcode);

            lock (changeLock)
            {
                using (StreamWriter sw = File.CreateText(Path.Combine(config.WorkingFolder, "m12-strings-english.txt")))
                {
                    foreach (string line in m12StringsEnglish)
                    {
                        sw.WriteLine(line);
                    }
                }

                UpdateStatus(String.Format("Last saved: {0:G}", DateTime.Now));
            }
        }

        private static IList<string> ExtractLabels(string str)
        {
            if (str == null)
                return null;

            var labels = new List<string>();

            for (int i = 0; i < str.Length; )
            {
                // Find the first caret
                if (str[i] == '^')
                {
                    // Find the next caret
                    bool foundNext = false;
                    for (int j = i + 1; j < str.Length; j++)
                    {
                        if (str[j] == '^')
                        {
                            // Get the label
                            string label = str.Substring(i + 1, j - i - 1);
                            labels.Add(label);

                            i = j + 1;
                            foundNext = true;
                            break;
                        }
                    }

                    if (!foundNext)
                    {
                        throw new Exception("Found opening caret with no closing caret: " + str);
                    }
                }
                else
                {
                    i++;
                }
            }

            return labels;
        }

        private void UpdateStatus(string text)
        {
            if (statusBar.InvokeRequired)
            {
                statusBar.Invoke(new Action<string>(UpdateStatus), text);
            }
            else
            {
                writeLabel.Text = text;
            }
        }

        private void groupSelector_SelectionChangeCommitted(object sender, EventArgs e)
        {
            SaveCurrentState(true);

            if (groupSelector.SelectedIndex == -1)
            {
                NavigateTo(null, null);
            }
            else
            {
                PushPreviousNavigationState();

                var currentGroup = (MatchedGroup)groupSelector.SelectedItem;
                var currentCollection = (MatchedGroupCollection)collectionSelector.SelectedItem;

                NavigateTo(currentGroup, currentCollection);
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
                    SaveCurrentState(true);
                    PushPreviousNavigationState();

                    MatchedGroup group;
                    MatchedGroupCollection collection;
                    NavigateTo(game, label, out group, out collection);
                    SelectGroup(group, collection);
                }
            }
        }

        private void backButton_Click(object sender, EventArgs e)
        {
            if (navigationStack.Count < 1)
                return;
            
            SaveCurrentState(true);

            var nav = navigationStack.Pop();

            if (nav.Type == NavigationType.MatchedGroup)
            {
                var matchedEntry = (MatchedGroupNavigationEntry)nav;
                NavigateTo(matchedEntry.Group, matchedEntry.Collection);
                SelectGroup(matchedEntry.Group, matchedEntry.Collection);
            }
            else if (nav.Type == NavigationType.Reference)
            {
                var referenceEntry = (ReferenceNavigationEntry)nav;
                MatchedGroup group;
                MatchedGroupCollection collection;
                NavigateTo(referenceEntry.Game, referenceEntry.Label, out group, out collection);
                SelectGroup(group, collection);
            }
        }

        private void saveMenu_Click(object sender, EventArgs e)
        {
            WriteChanges(true);
        }

        private void writeTimer_Tick(object sender, EventArgs e)
        {
            WriteChanges(false);
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (badStart)
                return;

            writeTimer.Enabled = false;
            WriteChanges(true);
        }

        private void copyCodesButton_Click(object sender, EventArgs e)
        {
            m12StringEnglish.Text = m12Compiler.StripText(m12String.Text);
            groupSelector.Focus();
        }

        private void collectionSelector_SelectionChangeCommitted(object sender, EventArgs e)
        {
            if (collectionSelector.SelectedIndex == -1)
            {
                groupSelector.Items.Clear();
                previewer.DisplayString(null, false);
            }
            else
            {
                var collection = (MatchedGroupCollection)collectionSelector.SelectedItem;

                // Set the previewer width before we do navigation stuff
                if (collection == psiHelpGroups)
                {
                    previewer.MaxWidth = 224;
                }
                else if (collection == battleActionGroups)
                {
                    previewer.MaxWidth = 176;
                }
                else
                {
                    previewer.MaxWidth = 144;
                }

                // Take no action if we haven't actually changed the collection
                // (otherwise, the group selector would jump to 0, probably unwanted)
                if (collection == currentCollection)
                    return;

                currentCollection = collection;
                PopulateGroupSelector(collection);

                groupSelector.SelectedIndex = 0;
                groupSelector_SelectionChangeCommitted(null, null);
            }
        }

        private void previewButton_Click(object sender, EventArgs e)
        {
            previewer.DisplayString(m12StringEnglish.Text, true);
        }

        private void m12StringEnglish_MouseClick(object sender, MouseEventArgs e)
        {
            if (ModifierKeys == Keys.Control)
            {
                // Insert a line break
                int currentSelectionStart = m12StringEnglish.SelectionStart;
                m12StringEnglish.Text = m12StringEnglish.Text.Insert(m12StringEnglish.SelectionStart, "[01 FF]");
                m12StringEnglish.SelectionStart = currentSelectionStart + 7;
            }
        }

        private async Task SetMessageLabel(string message)
        {
            var messageLabel = new ToolStripStatusLabel(message);
            messageLabel.Font = new Font(messageLabel.Font, FontStyle.Bold);
            messageLabel.BackColor = SystemColors.Highlight;
            statusBar.Items.Add(messageLabel);

            await Task.Delay(3000);

            statusBar.Items.Remove(messageLabel);
        }

        private void resolveDuplicateLabelsMenu_Click(object sender, EventArgs e)
        {
            SaveCurrentState(false);

            try
            {
                // Enumerate all labels
                var labels = m12StringsEnglish.Select((s, i) => new { Labels = ExtractLabels(s), Index = i });

                // Find duplicates
                var flattened = labels.SelectMany(l => l.Labels.Select(b => new { Label = b, Index = l.Index }));
                var duplicates = flattened.GroupBy(f => f.Label)
                    .Where(g => g.Count() > 1)
                    .Select(g => new
                    {
                        Label = g.Key,
                        Indices = g.Select(r => new { Index = r.Index, Trivial = IsJustALabel(m12StringsEnglish[r.Index]) }).ToList()
                    })
                    .ToList();

                // Find the duplicates that can be resolved
                var canBeResolved = duplicates.Where(d => d.Indices.Where(i => !i.Trivial).Count() <= 1).ToList();

                // Find the duplicates that can't be resolved
                var cantBeResolved = duplicates.Where(d => d.Indices.Where(i => !i.Trivial).Count() > 1).ToList();

                if (duplicates.Count == 0)
                {
                    MessageBox.Show("No duplicates found.", "Duplicates", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    string message = "Duplicates were found.";

                    if (canBeResolved.Count > 0)
                    {
                        message += Environment.NewLine + Environment.NewLine +
                            "The following duplicates may be resolved automatically:" + Environment.NewLine +
                            String.Join(", ", canBeResolved.Select(d => d.Label).ToArray());
                    }

                    if (cantBeResolved.Count > 0)
                    {
                        message += Environment.NewLine + Environment.NewLine +
                            "The following duplicates cannot be resolved manually:" + Environment.NewLine +
                            String.Join(", ", cantBeResolved.Select(d => d.Label).ToArray());
                    }

                    if (canBeResolved.Count > 0)
                    {
                        message += Environment.NewLine + Environment.NewLine +
                            "Would you like to fix the resolvable duplicates now?";

                        var dialogResult = MessageBox.Show(message, "Duplicates", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

                        if (dialogResult == DialogResult.Yes)
                        {
                            // The trivial duplicates may simply be removed from the strings collection

                            // Unless, however, a label has no non-trivial duplicates; in that case, keep one of them
                            var noNonTrivial = canBeResolved.Where(d => !d.Indices.Any(i => !i.Trivial));
                            foreach (var toBeSaved in noNonTrivial)
                                toBeSaved.Indices.RemoveAt(0);

                            var toBeRemoved = canBeResolved.Where(d => d.Indices.Any(i => !i.Trivial))
                                .Concat(noNonTrivial)
                                .SelectMany(d => d.Indices)
                                .Where(i => i.Trivial)
                                .Select(i => i.Index)
                                .Distinct()
                                .OrderByDescending(i => i);

                            // If there are no non-trivial duplicates, we must leave exactly one trivial duplicate
                            // Make sure we aren't currently on a string that's about to be removed (shouldn't ever actually happen...)
                            if (toBeRemoved.Any(i => i == currentIndex[Game.M12English]))
                            {
                                MessageBox.Show("Could not remove duplicates because one of them is currently selected! Navigate away first.",
                                    "Could not resolve", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                return;
                            }

                            foreach (int i in toBeRemoved)
                            {
                                // Remove the string
                                m12StringsEnglish.RemoveAt(i);

                                // Update currentIndex
                                if (currentIndex[Game.M12English] > i)
                                {
                                    currentIndex[Game.M12English]--;
                                }
                            }

                            MessageBox.Show("Duplicates removed!", "Finished", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                    else
                    {
                        MessageBox.Show(message, "Duplicates", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error extracting labels. " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
        }

        private void checkCompletionMenu_Click(object sender, EventArgs e)
        {
            int completedCount = m12StringsEnglish.Count(s => !IsJustALabel(s));
            int total = m12StringsEnglish.Count;
            MessageBox.Show(String.Format("Completed: {0}/{1} ({2:F2}%)", completedCount, total, (double)completedCount * 100d / (double)total));
        }

        private void prevButton_Click(object sender, EventArgs e)
        {
            if (groupSelector.SelectedIndex < 1)
            {
                return;
            }

            groupSelector.SelectedIndex--;
            groupSelector_SelectionChangeCommitted(null, null);
        }

        private void nextButton_Click(object sender, EventArgs e)
        {
            if (groupSelector.SelectedIndex == -1 || groupSelector.SelectedIndex == groupSelector.Items.Count - 1)
            {
                return;
            }

            groupSelector.SelectedIndex++;
            groupSelector_SelectionChangeCommitted(null, null);
        }

        private void autosaveMenu_Click(object sender, EventArgs e)
        {
            writeTimer.Enabled = autosaveMenu.Checked;
        }

        private void translateButton_Click(object sender, EventArgs e)
        {
            string toTranslate = StripCodes(m12String.Text);
            Translate(toTranslate);
        }

        private void Translate(string toTranslate)
        {
            var builder = new StringBuilder();
            builder.Append("https://translate.google.com/#ja/en/");

            var bytes = Encoding.UTF8.GetBytes(toTranslate);
            foreach (byte b in bytes)
            {
                builder.Append('%');
                builder.Append(b.ToString("X2"));
            }

            System.Diagnostics.Process.Start(builder.ToString());
        }

        private string StripCodes(string str)
        {
            var builder = new StringBuilder();
            bool inCode = false;
            foreach(char c in str)
            {
                if (c == '[')
                {
                    inCode = true;
                }
                else if (c == ']')
                {
                    inCode = false;
                    builder.Append(' ');
                }
                else if (c == '^')
                {
                    inCode = !inCode;
                }
                else
                {
                    if (!inCode)
                        builder.Append(c);
                }
            }
            return builder.ToString();
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
