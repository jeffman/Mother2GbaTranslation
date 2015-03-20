namespace ScriptToolGui
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.tptSelector = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.textSplitContainer = new System.Windows.Forms.SplitContainer();
            this.previewSplitContainer = new System.Windows.Forms.SplitContainer();
            this.ebString = new System.Windows.Forms.TextBox();
            this.m12String = new System.Windows.Forms.TextBox();
            this.m12StringEnglish = new System.Windows.Forms.TextBox();
            this.codeSplitContainer = new System.Windows.Forms.SplitContainer();
            this.codeList = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.referenceList = new System.Windows.Forms.ListBox();
            this.label3 = new System.Windows.Forms.Label();
            this.gameSelectorPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.ebSelector = new System.Windows.Forms.RadioButton();
            this.m12Selector = new System.Windows.Forms.RadioButton();
            this.backButton = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.fileMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.saveMenu = new System.Windows.Forms.ToolStripMenuItem();
            ((System.ComponentModel.ISupportInitialize)(this.textSplitContainer)).BeginInit();
            this.textSplitContainer.Panel1.SuspendLayout();
            this.textSplitContainer.Panel2.SuspendLayout();
            this.textSplitContainer.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.previewSplitContainer)).BeginInit();
            this.previewSplitContainer.Panel1.SuspendLayout();
            this.previewSplitContainer.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.codeSplitContainer)).BeginInit();
            this.codeSplitContainer.Panel1.SuspendLayout();
            this.codeSplitContainer.Panel2.SuspendLayout();
            this.codeSplitContainer.SuspendLayout();
            this.gameSelectorPanel.SuspendLayout();
            this.menuStrip1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // tptSelector
            // 
            this.tptSelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.tptSelector.FormattingEnabled = true;
            this.tptSelector.Location = new System.Drawing.Point(66, 4);
            this.tptSelector.Name = "tptSelector";
            this.tptSelector.Size = new System.Drawing.Size(238, 21);
            this.tptSelector.TabIndex = 0;
            this.tptSelector.SelectionChangeCommitted += new System.EventHandler(this.tptSelector_SelectionChangeCommitted);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(57, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "TPT entry:";
            // 
            // textSplitContainer
            // 
            this.textSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.textSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textSplitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.textSplitContainer.Location = new System.Drawing.Point(0, 0);
            this.textSplitContainer.Name = "textSplitContainer";
            // 
            // textSplitContainer.Panel1
            // 
            this.textSplitContainer.Panel1.AutoScroll = true;
            this.textSplitContainer.Panel1.BackColor = System.Drawing.SystemColors.Control;
            this.textSplitContainer.Panel1.Controls.Add(this.previewSplitContainer);
            // 
            // textSplitContainer.Panel2
            // 
            this.textSplitContainer.Panel2.BackColor = System.Drawing.SystemColors.Control;
            this.textSplitContainer.Panel2.Controls.Add(this.codeSplitContainer);
            this.textSplitContainer.Panel2.Controls.Add(this.gameSelectorPanel);
            this.textSplitContainer.Size = new System.Drawing.Size(761, 560);
            this.textSplitContainer.SplitterDistance = 535;
            this.textSplitContainer.TabIndex = 6;
            // 
            // previewSplitContainer
            // 
            this.previewSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.previewSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.previewSplitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.previewSplitContainer.Location = new System.Drawing.Point(0, 0);
            this.previewSplitContainer.Name = "previewSplitContainer";
            this.previewSplitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // previewSplitContainer.Panel1
            // 
            this.previewSplitContainer.Panel1.AutoScroll = true;
            this.previewSplitContainer.Panel1.Controls.Add(this.ebString);
            this.previewSplitContainer.Panel1.Controls.Add(this.m12String);
            this.previewSplitContainer.Panel1.Controls.Add(this.m12StringEnglish);
            this.previewSplitContainer.Size = new System.Drawing.Size(535, 560);
            this.previewSplitContainer.SplitterDistance = 432;
            this.previewSplitContainer.TabIndex = 5;
            // 
            // ebString
            // 
            this.ebString.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ebString.Location = new System.Drawing.Point(3, 6);
            this.ebString.Multiline = true;
            this.ebString.Name = "ebString";
            this.ebString.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ebString.Size = new System.Drawing.Size(525, 128);
            this.ebString.TabIndex = 2;
            // 
            // m12String
            // 
            this.m12String.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12String.Location = new System.Drawing.Point(3, 140);
            this.m12String.Multiline = true;
            this.m12String.Name = "m12String";
            this.m12String.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12String.Size = new System.Drawing.Size(525, 128);
            this.m12String.TabIndex = 3;
            // 
            // m12StringEnglish
            // 
            this.m12StringEnglish.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12StringEnglish.Location = new System.Drawing.Point(3, 274);
            this.m12StringEnglish.Multiline = true;
            this.m12StringEnglish.Name = "m12StringEnglish";
            this.m12StringEnglish.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12StringEnglish.Size = new System.Drawing.Size(525, 128);
            this.m12StringEnglish.TabIndex = 4;
            // 
            // codeSplitContainer
            // 
            this.codeSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.codeSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.codeSplitContainer.Location = new System.Drawing.Point(0, 33);
            this.codeSplitContainer.Name = "codeSplitContainer";
            this.codeSplitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // codeSplitContainer.Panel1
            // 
            this.codeSplitContainer.Panel1.Controls.Add(this.codeList);
            this.codeSplitContainer.Panel1.Controls.Add(this.label2);
            // 
            // codeSplitContainer.Panel2
            // 
            this.codeSplitContainer.Panel2.Controls.Add(this.referenceList);
            this.codeSplitContainer.Panel2.Controls.Add(this.label3);
            this.codeSplitContainer.Size = new System.Drawing.Size(222, 527);
            this.codeSplitContainer.SplitterDistance = 245;
            this.codeSplitContainer.TabIndex = 1;
            // 
            // codeList
            // 
            this.codeList.BackColor = System.Drawing.SystemColors.Window;
            this.codeList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.codeList.Location = new System.Drawing.Point(0, 19);
            this.codeList.Multiline = true;
            this.codeList.Name = "codeList";
            this.codeList.ReadOnly = true;
            this.codeList.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.codeList.Size = new System.Drawing.Size(218, 222);
            this.codeList.TabIndex = 1;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Dock = System.Windows.Forms.DockStyle.Top;
            this.label2.Location = new System.Drawing.Point(0, 0);
            this.label2.Margin = new System.Windows.Forms.Padding(0);
            this.label2.Name = "label2";
            this.label2.Padding = new System.Windows.Forms.Padding(3);
            this.label2.Size = new System.Drawing.Size(46, 19);
            this.label2.TabIndex = 0;
            this.label2.Text = "Codes:";
            // 
            // referenceList
            // 
            this.referenceList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.referenceList.FormattingEnabled = true;
            this.referenceList.Location = new System.Drawing.Point(0, 19);
            this.referenceList.Name = "referenceList";
            this.referenceList.Size = new System.Drawing.Size(218, 255);
            this.referenceList.TabIndex = 2;
            this.referenceList.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.referenceList_MouseDoubleClick);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Dock = System.Windows.Forms.DockStyle.Top;
            this.label3.Location = new System.Drawing.Point(0, 0);
            this.label3.Name = "label3";
            this.label3.Padding = new System.Windows.Forms.Padding(3);
            this.label3.Size = new System.Drawing.Size(71, 19);
            this.label3.TabIndex = 1;
            this.label3.Text = "References:";
            // 
            // gameSelectorPanel
            // 
            this.gameSelectorPanel.AutoSize = true;
            this.gameSelectorPanel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.gameSelectorPanel.Controls.Add(this.ebSelector);
            this.gameSelectorPanel.Controls.Add(this.m12Selector);
            this.gameSelectorPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.gameSelectorPanel.Location = new System.Drawing.Point(0, 0);
            this.gameSelectorPanel.Name = "gameSelectorPanel";
            this.gameSelectorPanel.Size = new System.Drawing.Size(222, 33);
            this.gameSelectorPanel.TabIndex = 0;
            // 
            // ebSelector
            // 
            this.ebSelector.Appearance = System.Windows.Forms.Appearance.Button;
            this.ebSelector.Location = new System.Drawing.Point(3, 3);
            this.ebSelector.Name = "ebSelector";
            this.ebSelector.Size = new System.Drawing.Size(64, 23);
            this.ebSelector.TabIndex = 0;
            this.ebSelector.Text = "EB";
            this.ebSelector.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.ebSelector.UseVisualStyleBackColor = true;
            this.ebSelector.CheckedChanged += new System.EventHandler(this.gameSelector_CheckedChanged);
            // 
            // m12Selector
            // 
            this.m12Selector.Appearance = System.Windows.Forms.Appearance.Button;
            this.m12Selector.Checked = true;
            this.m12Selector.Location = new System.Drawing.Point(73, 3);
            this.m12Selector.Name = "m12Selector";
            this.m12Selector.Size = new System.Drawing.Size(64, 23);
            this.m12Selector.TabIndex = 1;
            this.m12Selector.TabStop = true;
            this.m12Selector.Text = "M12";
            this.m12Selector.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.m12Selector.UseVisualStyleBackColor = true;
            this.m12Selector.CheckedChanged += new System.EventHandler(this.gameSelector_CheckedChanged);
            // 
            // backButton
            // 
            this.backButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.backButton.Location = new System.Drawing.Point(683, 3);
            this.backButton.Name = "backButton";
            this.backButton.Size = new System.Drawing.Size(75, 23);
            this.backButton.TabIndex = 7;
            this.backButton.Text = "Back";
            this.backButton.UseVisualStyleBackColor = true;
            this.backButton.Click += new System.EventHandler(this.backButton_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.BackColor = System.Drawing.SystemColors.Control;
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileMenu});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(761, 24);
            this.menuStrip1.TabIndex = 8;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // panel1
            // 
            this.panel1.AutoSize = true;
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.backButton);
            this.panel1.Controls.Add(this.tptSelector);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(0, 24);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(761, 29);
            this.panel1.TabIndex = 9;
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.textSplitContainer);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel2.Location = new System.Drawing.Point(0, 53);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(761, 560);
            this.panel2.TabIndex = 10;
            // 
            // fileMenu
            // 
            this.fileMenu.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.saveMenu});
            this.fileMenu.Name = "fileMenu";
            this.fileMenu.Size = new System.Drawing.Size(37, 20);
            this.fileMenu.Text = "File";
            // 
            // saveMenu
            // 
            this.saveMenu.Name = "saveMenu";
            this.saveMenu.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.saveMenu.Size = new System.Drawing.Size(152, 22);
            this.saveMenu.Text = "Save";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(761, 613);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "MOTHER 1+2 Funland";
            this.textSplitContainer.Panel1.ResumeLayout(false);
            this.textSplitContainer.Panel2.ResumeLayout(false);
            this.textSplitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.textSplitContainer)).EndInit();
            this.textSplitContainer.ResumeLayout(false);
            this.previewSplitContainer.Panel1.ResumeLayout(false);
            this.previewSplitContainer.Panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.previewSplitContainer)).EndInit();
            this.previewSplitContainer.ResumeLayout(false);
            this.codeSplitContainer.Panel1.ResumeLayout(false);
            this.codeSplitContainer.Panel1.PerformLayout();
            this.codeSplitContainer.Panel2.ResumeLayout(false);
            this.codeSplitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.codeSplitContainer)).EndInit();
            this.codeSplitContainer.ResumeLayout(false);
            this.gameSelectorPanel.ResumeLayout(false);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox tptSelector;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer textSplitContainer;
        private System.Windows.Forms.SplitContainer previewSplitContainer;
        private System.Windows.Forms.TextBox ebString;
        private System.Windows.Forms.TextBox m12String;
        private System.Windows.Forms.TextBox m12StringEnglish;
        private System.Windows.Forms.FlowLayoutPanel gameSelectorPanel;
        private System.Windows.Forms.RadioButton ebSelector;
        private System.Windows.Forms.RadioButton m12Selector;
        private System.Windows.Forms.SplitContainer codeSplitContainer;
        private System.Windows.Forms.TextBox codeList;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox referenceList;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button backButton;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.ToolStripMenuItem fileMenu;
        private System.Windows.Forms.ToolStripMenuItem saveMenu;
    }
}

