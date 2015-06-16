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
            this.components = new System.ComponentModel.Container();
            this.mainMenu = new System.Windows.Forms.MenuStrip();
            this.fileMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.saveMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.toolsMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.resolveDuplicateLabelsMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.checkCompletionMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.autosaveMenu = new System.Windows.Forms.ToolStripMenuItem();
            this.topPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.collectionSelector = new System.Windows.Forms.ComboBox();
            this.groupSelector = new System.Windows.Forms.ComboBox();
            this.prevButton = new System.Windows.Forms.Button();
            this.nextButton = new System.Windows.Forms.Button();
            this.backButton = new System.Windows.Forms.Button();
            this.mainPanel = new System.Windows.Forms.Panel();
            this.mainSplitContainer = new System.Windows.Forms.SplitContainer();
            this.leftSplitContainer = new System.Windows.Forms.SplitContainer();
            this.textBoxPanel = new System.Windows.Forms.Panel();
            this.ebString = new System.Windows.Forms.TextBox();
            this.m12String = new System.Windows.Forms.TextBox();
            this.m12StringEnglish = new System.Windows.Forms.TextBox();
            this.lineOpsPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.copyCodesButton = new System.Windows.Forms.Button();
            this.previewButton = new System.Windows.Forms.Button();
            this.previewer = new ScriptToolGui.StringPreviewer();
            this.codeSplitContainer = new System.Windows.Forms.SplitContainer();
            this.codeList = new System.Windows.Forms.ListBox();
            this.label2 = new System.Windows.Forms.Label();
            this.referenceList = new System.Windows.Forms.ListBox();
            this.label3 = new System.Windows.Forms.Label();
            this.gameSelectorPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.ebSelector = new System.Windows.Forms.RadioButton();
            this.m12Selector = new System.Windows.Forms.RadioButton();
            this.statusBar = new System.Windows.Forms.StatusStrip();
            this.writeLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.writeTimer = new System.Windows.Forms.Timer(this.components);
            this.mainMenu.SuspendLayout();
            this.topPanel.SuspendLayout();
            this.mainPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.mainSplitContainer)).BeginInit();
            this.mainSplitContainer.Panel1.SuspendLayout();
            this.mainSplitContainer.Panel2.SuspendLayout();
            this.mainSplitContainer.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.leftSplitContainer)).BeginInit();
            this.leftSplitContainer.Panel1.SuspendLayout();
            this.leftSplitContainer.Panel2.SuspendLayout();
            this.leftSplitContainer.SuspendLayout();
            this.textBoxPanel.SuspendLayout();
            this.lineOpsPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.codeSplitContainer)).BeginInit();
            this.codeSplitContainer.Panel1.SuspendLayout();
            this.codeSplitContainer.Panel2.SuspendLayout();
            this.codeSplitContainer.SuspendLayout();
            this.gameSelectorPanel.SuspendLayout();
            this.statusBar.SuspendLayout();
            this.SuspendLayout();
            // 
            // mainMenu
            // 
            this.mainMenu.BackColor = System.Drawing.SystemColors.Control;
            this.mainMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileMenu,
            this.toolsMenu});
            this.mainMenu.Location = new System.Drawing.Point(0, 0);
            this.mainMenu.Name = "mainMenu";
            this.mainMenu.Size = new System.Drawing.Size(1026, 24);
            this.mainMenu.TabIndex = 8;
            this.mainMenu.Text = "menuStrip1";
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
            this.saveMenu.Size = new System.Drawing.Size(138, 22);
            this.saveMenu.Text = "Save";
            this.saveMenu.Click += new System.EventHandler(this.saveMenu_Click);
            // 
            // toolsMenu
            // 
            this.toolsMenu.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.resolveDuplicateLabelsMenu,
            this.checkCompletionMenu,
            this.autosaveMenu});
            this.toolsMenu.Name = "toolsMenu";
            this.toolsMenu.Size = new System.Drawing.Size(48, 20);
            this.toolsMenu.Text = "Tools";
            // 
            // resolveDuplicateLabelsMenu
            // 
            this.resolveDuplicateLabelsMenu.Name = "resolveDuplicateLabelsMenu";
            this.resolveDuplicateLabelsMenu.Size = new System.Drawing.Size(214, 22);
            this.resolveDuplicateLabelsMenu.Text = "Resolve duplicate labels...";
            this.resolveDuplicateLabelsMenu.Click += new System.EventHandler(this.resolveDuplicateLabelsMenu_Click);
            // 
            // checkCompletionMenu
            // 
            this.checkCompletionMenu.Name = "checkCompletionMenu";
            this.checkCompletionMenu.Size = new System.Drawing.Size(214, 22);
            this.checkCompletionMenu.Text = "Check completion status...";
            this.checkCompletionMenu.Click += new System.EventHandler(this.checkCompletionMenu_Click);
            // 
            // autosaveMenu
            // 
            this.autosaveMenu.Checked = true;
            this.autosaveMenu.CheckOnClick = true;
            this.autosaveMenu.CheckState = System.Windows.Forms.CheckState.Checked;
            this.autosaveMenu.Name = "autosaveMenu";
            this.autosaveMenu.Size = new System.Drawing.Size(214, 22);
            this.autosaveMenu.Text = "Autosave";
            this.autosaveMenu.Click += new System.EventHandler(this.autosaveMenu_Click);
            // 
            // topPanel
            // 
            this.topPanel.AutoSize = true;
            this.topPanel.Controls.Add(this.label1);
            this.topPanel.Controls.Add(this.collectionSelector);
            this.topPanel.Controls.Add(this.groupSelector);
            this.topPanel.Controls.Add(this.prevButton);
            this.topPanel.Controls.Add(this.nextButton);
            this.topPanel.Controls.Add(this.backButton);
            this.topPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.topPanel.Location = new System.Drawing.Point(0, 24);
            this.topPanel.Name = "topPanel";
            this.topPanel.Size = new System.Drawing.Size(1026, 29);
            this.topPanel.TabIndex = 10;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 8);
            this.label1.Margin = new System.Windows.Forms.Padding(3, 8, 0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(39, 13);
            this.label1.TabIndex = 13;
            this.label1.Text = "Group:";
            // 
            // collectionSelector
            // 
            this.collectionSelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.collectionSelector.FormattingEnabled = true;
            this.collectionSelector.Location = new System.Drawing.Point(45, 4);
            this.collectionSelector.Margin = new System.Windows.Forms.Padding(3, 4, 3, 3);
            this.collectionSelector.Name = "collectionSelector";
            this.collectionSelector.Size = new System.Drawing.Size(157, 21);
            this.collectionSelector.TabIndex = 14;
            this.collectionSelector.SelectionChangeCommitted += new System.EventHandler(this.collectionSelector_SelectionChangeCommitted);
            // 
            // groupSelector
            // 
            this.groupSelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.groupSelector.FormattingEnabled = true;
            this.groupSelector.Location = new System.Drawing.Point(208, 4);
            this.groupSelector.Margin = new System.Windows.Forms.Padding(3, 4, 3, 3);
            this.groupSelector.Name = "groupSelector";
            this.groupSelector.Size = new System.Drawing.Size(238, 21);
            this.groupSelector.TabIndex = 10;
            this.groupSelector.SelectionChangeCommitted += new System.EventHandler(this.groupSelector_SelectionChangeCommitted);
            // 
            // prevButton
            // 
            this.prevButton.Location = new System.Drawing.Point(452, 3);
            this.prevButton.Name = "prevButton";
            this.prevButton.Size = new System.Drawing.Size(45, 23);
            this.prevButton.TabIndex = 16;
            this.prevButton.Text = "˄";
            this.prevButton.UseVisualStyleBackColor = true;
            this.prevButton.Click += new System.EventHandler(this.prevButton_Click);
            // 
            // nextButton
            // 
            this.nextButton.Location = new System.Drawing.Point(503, 3);
            this.nextButton.Name = "nextButton";
            this.nextButton.Size = new System.Drawing.Size(45, 23);
            this.nextButton.TabIndex = 15;
            this.nextButton.Text = "˅";
            this.nextButton.UseVisualStyleBackColor = true;
            this.nextButton.Click += new System.EventHandler(this.nextButton_Click);
            // 
            // backButton
            // 
            this.backButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.backButton.Location = new System.Drawing.Point(554, 3);
            this.backButton.Name = "backButton";
            this.backButton.Size = new System.Drawing.Size(75, 23);
            this.backButton.TabIndex = 12;
            this.backButton.Text = "Back";
            this.backButton.UseVisualStyleBackColor = true;
            this.backButton.Click += new System.EventHandler(this.backButton_Click);
            // 
            // mainPanel
            // 
            this.mainPanel.AutoSize = true;
            this.mainPanel.BackColor = System.Drawing.SystemColors.Control;
            this.mainPanel.Controls.Add(this.mainSplitContainer);
            this.mainPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.mainPanel.Location = new System.Drawing.Point(0, 53);
            this.mainPanel.Name = "mainPanel";
            this.mainPanel.Size = new System.Drawing.Size(1026, 667);
            this.mainPanel.TabIndex = 11;
            // 
            // mainSplitContainer
            // 
            this.mainSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.mainSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.mainSplitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.mainSplitContainer.Location = new System.Drawing.Point(0, 0);
            this.mainSplitContainer.Name = "mainSplitContainer";
            // 
            // mainSplitContainer.Panel1
            // 
            this.mainSplitContainer.Panel1.AutoScroll = true;
            this.mainSplitContainer.Panel1.BackColor = System.Drawing.SystemColors.Control;
            this.mainSplitContainer.Panel1.Controls.Add(this.leftSplitContainer);
            // 
            // mainSplitContainer.Panel2
            // 
            this.mainSplitContainer.Panel2.BackColor = System.Drawing.SystemColors.Control;
            this.mainSplitContainer.Panel2.Controls.Add(this.codeSplitContainer);
            this.mainSplitContainer.Panel2.Controls.Add(this.gameSelectorPanel);
            this.mainSplitContainer.Size = new System.Drawing.Size(1026, 667);
            this.mainSplitContainer.SplitterDistance = 800;
            this.mainSplitContainer.TabIndex = 6;
            // 
            // leftSplitContainer
            // 
            this.leftSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.leftSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.leftSplitContainer.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.leftSplitContainer.Location = new System.Drawing.Point(0, 0);
            this.leftSplitContainer.Name = "leftSplitContainer";
            this.leftSplitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // leftSplitContainer.Panel1
            // 
            this.leftSplitContainer.Panel1.Controls.Add(this.textBoxPanel);
            this.leftSplitContainer.Panel1.Controls.Add(this.lineOpsPanel);
            // 
            // leftSplitContainer.Panel2
            // 
            this.leftSplitContainer.Panel2.Controls.Add(this.previewer);
            this.leftSplitContainer.Size = new System.Drawing.Size(800, 667);
            this.leftSplitContainer.SplitterDistance = 526;
            this.leftSplitContainer.TabIndex = 5;
            // 
            // textBoxPanel
            // 
            this.textBoxPanel.AutoScroll = true;
            this.textBoxPanel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.textBoxPanel.Controls.Add(this.ebString);
            this.textBoxPanel.Controls.Add(this.m12String);
            this.textBoxPanel.Controls.Add(this.m12StringEnglish);
            this.textBoxPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBoxPanel.Location = new System.Drawing.Point(0, 0);
            this.textBoxPanel.Name = "textBoxPanel";
            this.textBoxPanel.Size = new System.Drawing.Size(796, 489);
            this.textBoxPanel.TabIndex = 10;
            // 
            // ebString
            // 
            this.ebString.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ebString.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ebString.Location = new System.Drawing.Point(3, 4);
            this.ebString.Multiline = true;
            this.ebString.Name = "ebString";
            this.ebString.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ebString.Size = new System.Drawing.Size(786, 128);
            this.ebString.TabIndex = 9;
            // 
            // m12String
            // 
            this.m12String.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12String.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.m12String.Location = new System.Drawing.Point(3, 138);
            this.m12String.Multiline = true;
            this.m12String.Name = "m12String";
            this.m12String.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12String.Size = new System.Drawing.Size(786, 128);
            this.m12String.TabIndex = 10;
            // 
            // m12StringEnglish
            // 
            this.m12StringEnglish.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.m12StringEnglish.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.m12StringEnglish.Location = new System.Drawing.Point(3, 272);
            this.m12StringEnglish.Multiline = true;
            this.m12StringEnglish.Name = "m12StringEnglish";
            this.m12StringEnglish.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.m12StringEnglish.Size = new System.Drawing.Size(786, 128);
            this.m12StringEnglish.TabIndex = 11;
            this.m12StringEnglish.MouseClick += new System.Windows.Forms.MouseEventHandler(this.m12StringEnglish_MouseClick);
            // 
            // lineOpsPanel
            // 
            this.lineOpsPanel.AutoSize = true;
            this.lineOpsPanel.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.lineOpsPanel.Controls.Add(this.copyCodesButton);
            this.lineOpsPanel.Controls.Add(this.previewButton);
            this.lineOpsPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.lineOpsPanel.Location = new System.Drawing.Point(0, 489);
            this.lineOpsPanel.Name = "lineOpsPanel";
            this.lineOpsPanel.Size = new System.Drawing.Size(796, 33);
            this.lineOpsPanel.TabIndex = 9;
            // 
            // copyCodesButton
            // 
            this.copyCodesButton.Location = new System.Drawing.Point(3, 3);
            this.copyCodesButton.Name = "copyCodesButton";
            this.copyCodesButton.Size = new System.Drawing.Size(124, 23);
            this.copyCodesButton.TabIndex = 0;
            this.copyCodesButton.Text = "Copy codes and labels";
            this.copyCodesButton.UseVisualStyleBackColor = true;
            this.copyCodesButton.Click += new System.EventHandler(this.copyCodesButton_Click);
            // 
            // previewButton
            // 
            this.previewButton.Location = new System.Drawing.Point(133, 3);
            this.previewButton.Name = "previewButton";
            this.previewButton.Size = new System.Drawing.Size(75, 23);
            this.previewButton.TabIndex = 1;
            this.previewButton.Text = "Preview";
            this.previewButton.UseVisualStyleBackColor = true;
            this.previewButton.Click += new System.EventHandler(this.previewButton_Click);
            // 
            // previewer
            // 
            this.previewer.AutoScroll = true;
            this.previewer.CharLookup = null;
            this.previewer.DisplayedString = null;
            this.previewer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.previewer.Location = new System.Drawing.Point(0, 0);
            this.previewer.M12Compiler = null;
            this.previewer.MaxWidth = 0;
            this.previewer.Name = "previewer";
            this.previewer.Size = new System.Drawing.Size(796, 133);
            this.previewer.TabIndex = 0;
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
            this.codeSplitContainer.Size = new System.Drawing.Size(222, 634);
            this.codeSplitContainer.SplitterDistance = 292;
            this.codeSplitContainer.TabIndex = 1;
            // 
            // codeList
            // 
            this.codeList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.codeList.FormattingEnabled = true;
            this.codeList.HorizontalScrollbar = true;
            this.codeList.Location = new System.Drawing.Point(0, 19);
            this.codeList.Name = "codeList";
            this.codeList.Size = new System.Drawing.Size(218, 269);
            this.codeList.TabIndex = 3;
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
            this.referenceList.HorizontalScrollbar = true;
            this.referenceList.Location = new System.Drawing.Point(0, 19);
            this.referenceList.Name = "referenceList";
            this.referenceList.Size = new System.Drawing.Size(218, 315);
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
            // statusBar
            // 
            this.statusBar.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.writeLabel});
            this.statusBar.Location = new System.Drawing.Point(0, 720);
            this.statusBar.Name = "statusBar";
            this.statusBar.Size = new System.Drawing.Size(1026, 22);
            this.statusBar.TabIndex = 7;
            this.statusBar.Text = "statusStrip1";
            // 
            // writeLabel
            // 
            this.writeLabel.Name = "writeLabel";
            this.writeLabel.Size = new System.Drawing.Size(0, 17);
            // 
            // writeTimer
            // 
            this.writeTimer.Enabled = true;
            this.writeTimer.Interval = 10000;
            this.writeTimer.Tick += new System.EventHandler(this.writeTimer_Tick);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1026, 742);
            this.Controls.Add(this.mainPanel);
            this.Controls.Add(this.topPanel);
            this.Controls.Add(this.mainMenu);
            this.Controls.Add(this.statusBar);
            this.MainMenuStrip = this.mainMenu;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "MOTHER 1+2 Funland";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MainForm_FormClosing);
            this.mainMenu.ResumeLayout(false);
            this.mainMenu.PerformLayout();
            this.topPanel.ResumeLayout(false);
            this.topPanel.PerformLayout();
            this.mainPanel.ResumeLayout(false);
            this.mainSplitContainer.Panel1.ResumeLayout(false);
            this.mainSplitContainer.Panel2.ResumeLayout(false);
            this.mainSplitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.mainSplitContainer)).EndInit();
            this.mainSplitContainer.ResumeLayout(false);
            this.leftSplitContainer.Panel1.ResumeLayout(false);
            this.leftSplitContainer.Panel1.PerformLayout();
            this.leftSplitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.leftSplitContainer)).EndInit();
            this.leftSplitContainer.ResumeLayout(false);
            this.textBoxPanel.ResumeLayout(false);
            this.textBoxPanel.PerformLayout();
            this.lineOpsPanel.ResumeLayout(false);
            this.codeSplitContainer.Panel1.ResumeLayout(false);
            this.codeSplitContainer.Panel1.PerformLayout();
            this.codeSplitContainer.Panel2.ResumeLayout(false);
            this.codeSplitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.codeSplitContainer)).EndInit();
            this.codeSplitContainer.ResumeLayout(false);
            this.gameSelectorPanel.ResumeLayout(false);
            this.statusBar.ResumeLayout(false);
            this.statusBar.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip mainMenu;
        private System.Windows.Forms.ToolStripMenuItem fileMenu;
        private System.Windows.Forms.ToolStripMenuItem saveMenu;
        private System.Windows.Forms.FlowLayoutPanel topPanel;
        private System.Windows.Forms.Button backButton;
        private System.Windows.Forms.ComboBox groupSelector;
        private System.Windows.Forms.Panel mainPanel;
        private System.Windows.Forms.SplitContainer mainSplitContainer;
        private System.Windows.Forms.SplitContainer leftSplitContainer;
        private System.Windows.Forms.SplitContainer codeSplitContainer;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox referenceList;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.FlowLayoutPanel gameSelectorPanel;
        private System.Windows.Forms.RadioButton ebSelector;
        private System.Windows.Forms.RadioButton m12Selector;
        private System.Windows.Forms.StatusStrip statusBar;
        private System.Windows.Forms.ToolStripStatusLabel writeLabel;
        private System.Windows.Forms.Timer writeTimer;
        private System.Windows.Forms.Panel textBoxPanel;
        private System.Windows.Forms.TextBox ebString;
        private System.Windows.Forms.TextBox m12String;
        private System.Windows.Forms.TextBox m12StringEnglish;
        private System.Windows.Forms.FlowLayoutPanel lineOpsPanel;
        private System.Windows.Forms.Button copyCodesButton;
        private System.Windows.Forms.ListBox codeList;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox collectionSelector;
        private System.Windows.Forms.Button previewButton;
        private StringPreviewer previewer;
        private System.Windows.Forms.ToolStripMenuItem toolsMenu;
        private System.Windows.Forms.ToolStripMenuItem resolveDuplicateLabelsMenu;
        private System.Windows.Forms.ToolStripMenuItem checkCompletionMenu;
        private System.Windows.Forms.Button prevButton;
        private System.Windows.Forms.Button nextButton;
        private System.Windows.Forms.ToolStripMenuItem autosaveMenu;
    }
}

