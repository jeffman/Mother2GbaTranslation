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
        const string workingFolder = @"..\..\..\..\working";

        // String references
        MainStringRef[] m12TptRefs;
        MainStringRef[] ebTptRefs;
        //MainStringRef[] m2TptRefs;

        // Strings
        IList<string> m12Strings;
        IList<string> m12StringsEnglish;
        IList<string> ebStrings;
        //IList<string> m2Strings;
        
        public MainForm()
        {
            InitializeComponent();

            m12String.Font = new Font("Meiryo UI", 8);

            LoadAllStringRefs(workingFolder);
            LoadAllStrings(workingFolder);

            PopulateTptList();
        }

        private void LoadAllStringRefs(string folder)
        {
            string m12FileName = Path.Combine(folder, "m12-tpt.json");
            string ebFileName = Path.Combine(folder, "eb-tpt.json");
            //string m2FileName = Path.Combine(folder, "m2-tpt.json");

            m12TptRefs = LoadStringRefs(m12FileName);
            ebTptRefs = LoadStringRefs(ebFileName);
            //m2TptRefs = LoadStringRefs(m2FileName);
        }

        private MainStringRef[] LoadStringRefs(string fileName)
        {
            string jsonString = File.ReadAllText(fileName);
            return JsonConvert.DeserializeObject<MainStringRef[]>(jsonString);
        }

        private void LoadAllStrings(string folder)
        {
            string m12FileName = Path.Combine(folder, "m12-strings.txt");
            string m12EnglishFileName = Path.Combine(folder, "m12-strings-english.txt");
            string ebFileName = Path.Combine(folder, "eb-strings.txt");
            //string m2FileName = Path.Combine(folder, "m2-strings.txt");

            m12Strings = LoadStrings(m12FileName);
            m12StringsEnglish = LoadStrings(m12EnglishFileName);
            ebStrings = LoadStrings(ebFileName);
            //m2Strings = LoadStrings(m2FileName);
        }

        private IList<string> LoadStrings(string fileName)
        {
            return new List<string>(File.ReadAllLines(fileName).Where(l => !l.Equals("")));
        }

        private void PopulateTptList()
        {
            var sb = new StringBuilder();
            tptSelector.Items.Clear();
            foreach (var m12Ref in m12TptRefs)
            {
                sb.Clear();
                sb.Append('[');
                sb.Append(m12Ref.Index.ToString("X3"));
                sb.Append("] ");
                sb.Append(m12Ref.Label);
                tptSelector.Items.Add(sb.ToString());
            }
        }

        private void LoadTptEntry(int index)
        {
            if (index == -1)
            {
                ebString.Text =
                    m12String.Text =
                    m12StringEnglish.Text = "";
            }
            else
            {
                var ebRef = ebTptRefs.FirstOrDefault(eb => eb.Index == index);
                var m12Ref = m12TptRefs.FirstOrDefault(m12 => m12.Index == index);

                if (ebRef == null)
                    ebString.Text = "";
                else
                {
                    string str = GetString(ebStrings, ebRef.Label);
                    if (str != null)
                        ebString.Text = str;
                }

                if (m12Ref == null)
                    m12String.Text = "";
                else
                {
                    string str = GetString(m12Strings, m12Ref.Label);
                    if (str != null)
                        m12String.Text = str;

                    str = GetString(m12StringsEnglish, m12Ref.Label);
                    if (str != null)
                        m12StringEnglish.Text = str;
                }

            }
        }

        private string GetString(IList<string> strings, string label)
        {
            try
            {
                return strings.First(l => l.Contains("^" + label + "^"));
            }
            catch
            {
                MessageBox.Show("Error: label definition not found in strings: " + label);
                return null;
            }
        }

        private void tptSelector_SelectionChangeCommitted(object sender, EventArgs e)
        {
            if (tptSelector.SelectedIndex == -1)
            {
                LoadTptEntry(-1);
            }
            else
            {
                string tptString = (string)tptSelector.Items[tptSelector.SelectedIndex];
                string indexString = tptString.Substring(1, 3);
                int index = Convert.ToInt32(indexString, 16);
                LoadTptEntry(index);
            }
        }
    }
}
