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
            this.ebString = new System.Windows.Forms.TextBox();
            this.m12String = new System.Windows.Forms.TextBox();
            this.m12StringEnglish = new System.Windows.Forms.TextBox();
            this.textSplitContainer = new System.Windows.Forms.SplitContainer();
            this.previewSplitContainer = new System.Windows.Forms.SplitContainer();
            this.controlCodeTabs = new System.Windows.Forms.TabControl();
            this.ebControlCodeTab = new System.Windows.Forms.TabPage();
            this.m12ControlCodeTab = new System.Windows.Forms.TabPage();
            ((System.ComponentModel.ISupportInitialize)(this.textSplitContainer)).BeginInit();
            this.textSplitContainer.Panel1.SuspendLayout();
            this.textSplitContainer.Panel2.SuspendLayout();
            this.textSplitContainer.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.previewSplitContainer)).BeginInit();
            this.previewSplitContainer.Panel1.SuspendLayout();
            this.previewSplitContainer.SuspendLayout();
            this.controlCodeTabs.SuspendLayout();
            this.SuspendLayout();
            // 
            // tptSelector
            // 
            this.tptSelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.tptSelector.FormattingEnabled = true;
            this.tptSelector.Location = new System.Drawing.Point(77, 12);
            this.tptSelector.Name = "tptSelector";
            this.tptSelector.Size = new System.Drawing.Size(238, 21);
            this.tptSelector.TabIndex = 0;
            this.tptSelector.SelectionChangeCommitted += new System.EventHandler(this.tptSelector_SelectionChangeCommitted);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(57, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "TPT entry:";
            // 
            // ebString
            // 
            this.ebString.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ebString.Location = new System.Drawing.Point(3, 3);
            this.ebString.Multiline = true;
            this.ebString.Name = "ebString";
            this.ebString.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ebString.Size = new System.Drawing.Size(344, 86);
            this.ebString.TabIndex = 2;
            // 
            // m12String
            // 
            this.m12String.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12String.Location = new System.Drawing.Point(3, 95);
            this.m12String.Multiline = true;
            this.m12String.Name = "m12String";
            this.m12String.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12String.Size = new System.Drawing.Size(344, 86);
            this.m12String.TabIndex = 3;
            // 
            // m12StringEnglish
            // 
            this.m12StringEnglish.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12StringEnglish.Location = new System.Drawing.Point(3, 187);
            this.m12StringEnglish.Multiline = true;
            this.m12StringEnglish.Name = "m12StringEnglish";
            this.m12StringEnglish.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12StringEnglish.Size = new System.Drawing.Size(344, 86);
            this.m12StringEnglish.TabIndex = 4;
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
            this.textSplitContainer.Panel1.Controls.Add(this.ebString);
            this.textSplitContainer.Panel1.Controls.Add(this.m12StringEnglish);
            this.textSplitContainer.Panel1.Controls.Add(this.m12String);
            // 
            // textSplitContainer.Panel2
            // 
            this.textSplitContainer.Panel2.BackColor = System.Drawing.SystemColors.Control;
            this.textSplitContainer.Panel2.Controls.Add(this.controlCodeTabs);
            this.textSplitContainer.Size = new System.Drawing.Size(582, 299);
            this.textSplitContainer.SplitterDistance = 356;
            this.textSplitContainer.TabIndex = 5;
            // 
            // previewSplitContainer
            // 
            this.previewSplitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.previewSplitContainer.BackColor = System.Drawing.SystemColors.Control;
            this.previewSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.previewSplitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.previewSplitContainer.Location = new System.Drawing.Point(12, 39);
            this.previewSplitContainer.Name = "previewSplitContainer";
            this.previewSplitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // previewSplitContainer.Panel1
            // 
            this.previewSplitContainer.Panel1.Controls.Add(this.textSplitContainer);
            // 
            // previewSplitContainer.Panel2
            // 
            this.previewSplitContainer.Panel2.BackColor = System.Drawing.SystemColors.Control;
            this.previewSplitContainer.Size = new System.Drawing.Size(582, 446);
            this.previewSplitContainer.SplitterDistance = 299;
            this.previewSplitContainer.TabIndex = 6;
            // 
            // controlCodeTabs
            // 
            this.controlCodeTabs.Controls.Add(this.ebControlCodeTab);
            this.controlCodeTabs.Controls.Add(this.m12ControlCodeTab);
            this.controlCodeTabs.Dock = System.Windows.Forms.DockStyle.Fill;
            this.controlCodeTabs.Location = new System.Drawing.Point(0, 0);
            this.controlCodeTabs.Name = "controlCodeTabs";
            this.controlCodeTabs.SelectedIndex = 0;
            this.controlCodeTabs.Size = new System.Drawing.Size(218, 295);
            this.controlCodeTabs.TabIndex = 0;
            // 
            // ebControlCodeTab
            // 
            this.ebControlCodeTab.Location = new System.Drawing.Point(4, 22);
            this.ebControlCodeTab.Name = "ebControlCodeTab";
            this.ebControlCodeTab.Padding = new System.Windows.Forms.Padding(3);
            this.ebControlCodeTab.Size = new System.Drawing.Size(210, 193);
            this.ebControlCodeTab.TabIndex = 0;
            this.ebControlCodeTab.Text = "EB codes";
            this.ebControlCodeTab.UseVisualStyleBackColor = true;
            // 
            // m12ControlCodeTab
            // 
            this.m12ControlCodeTab.Location = new System.Drawing.Point(4, 22);
            this.m12ControlCodeTab.Name = "m12ControlCodeTab";
            this.m12ControlCodeTab.Padding = new System.Windows.Forms.Padding(3);
            this.m12ControlCodeTab.Size = new System.Drawing.Size(210, 269);
            this.m12ControlCodeTab.TabIndex = 1;
            this.m12ControlCodeTab.Text = "M12 codes";
            this.m12ControlCodeTab.UseVisualStyleBackColor = true;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(606, 497);
            this.Controls.Add(this.previewSplitContainer);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tptSelector);
            this.Name = "MainForm";
            this.Text = "MOTHER 1+2 Funland";
            this.textSplitContainer.Panel1.ResumeLayout(false);
            this.textSplitContainer.Panel1.PerformLayout();
            this.textSplitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.textSplitContainer)).EndInit();
            this.textSplitContainer.ResumeLayout(false);
            this.previewSplitContainer.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.previewSplitContainer)).EndInit();
            this.previewSplitContainer.ResumeLayout(false);
            this.controlCodeTabs.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox tptSelector;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox ebString;
        private System.Windows.Forms.TextBox m12String;
        private System.Windows.Forms.TextBox m12StringEnglish;
        private System.Windows.Forms.SplitContainer textSplitContainer;
        private System.Windows.Forms.SplitContainer previewSplitContainer;
        private System.Windows.Forms.TabControl controlCodeTabs;
        private System.Windows.Forms.TabPage ebControlCodeTab;
        private System.Windows.Forms.TabPage m12ControlCodeTab;
    }
}

