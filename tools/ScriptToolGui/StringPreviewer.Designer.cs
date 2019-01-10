namespace ScriptToolGui
{
    partial class StringPreviewer
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.stringPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.SuspendLayout();
            // 
            // stringPanel
            // 
            this.stringPanel.AutoSize = true;
            this.stringPanel.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.stringPanel.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            this.stringPanel.Location = new System.Drawing.Point(0, 0);
            this.stringPanel.Name = "stringPanel";
            this.stringPanel.Size = new System.Drawing.Size(0, 0);
            this.stringPanel.TabIndex = 0;
            // 
            // StringPreviewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.Controls.Add(this.stringPanel);
            this.Name = "StringPreviewer";
            this.Size = new System.Drawing.Size(324, 105);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.FlowLayoutPanel stringPanel;

    }
}
