using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using ScriptTool;

namespace ScriptToolGui
{
    public partial class StringPreviewer : UserControl
    {
        public Compiler M12Compiler { get; set; }
        public IDictionary<byte, string> CharLookup { get; set; }

        public int MaxWidth { get; set; }

        public StringPreviewer()
        {
            InitializeComponent();
        }

        private void RedrawFancy(string str)
        {
            stringPanel.Controls.Clear();

            if (M12Compiler == null || CharLookup == null || str == null)
            {
                return;
            }

            try
            {
                IList<int> widths;
                IList<string> parsed = M12Compiler.FormatPreviewM12(str, out widths, CharLookup);

                for (int i = 0; i < parsed.Count; i++)
                {
                    var label = new Label();
                    label.AutoSize = true;
                    label.Text = parsed[i] + " (" + widths[i] + ")";

                    if (widths[i] <= MaxWidth)
                        label.ForeColor = Color.Green;
                    else
                        label.ForeColor = Color.Red;

                    stringPanel.Controls.Add(label);
                }
            }
            catch (Exception e)
            {
                stringPanel.Controls.Clear();

                var errLabel = new Label();
                errLabel.AutoSize = true;
                errLabel.Font = new Font(errLabel.Font, FontStyle.Bold);
                errLabel.Text = "Error: " + e.Message;

                stringPanel.Controls.Add(errLabel);
            }
        }

        private void RedrawPlain(string str)
        {
            stringPanel.Controls.Clear();

            if (str == null)
                return;

            var label = new Label
            {
                AutoSize = true,
                Text = str
            };
            stringPanel.Controls.Add(label);
        }

        public void DisplayString(string str, bool fancy)
        {
            if (fancy)
                RedrawFancy(str);
            else
                RedrawPlain(str);
        }
    }
}
