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

        private string text;
        public string DisplayedString
        {
            get
            {
                return text;
            }
            set
            {
                text = value;
                Redraw();
            }
        }

        public StringPreviewer()
        {
            InitializeComponent();
        }

        private void Redraw()
        {
            stringPanel.Controls.Clear();

            if (M12Compiler == null || CharLookup == null || text == null)
            {
                return;
            }

            try
            {
                IList<int> widths;
                IList<string> parsed = M12Compiler.FormatPreviewM12(text, out widths, CharLookup);

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
    }
}
