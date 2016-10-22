namespace Lerch.PowerShell
{
    partial class Intellisense
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
            this.autoCompleteItems = new System.Windows.Forms.ListBox();
            this.resetSearchTextTimer = new System.Windows.Forms.Timer(this.components);
            this.borderPanel = new System.Windows.Forms.Panel();
            this.backgroundPanel = new System.Windows.Forms.Panel();
            this.borderPanel.SuspendLayout();
            this.backgroundPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // autoCompleteItems
            // 
            this.autoCompleteItems.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.autoCompleteItems.Dock = System.Windows.Forms.DockStyle.Fill;
            this.autoCompleteItems.FormattingEnabled = true;
            this.autoCompleteItems.Location = new System.Drawing.Point(0, 0);
            this.autoCompleteItems.Margin = new System.Windows.Forms.Padding(0);
            this.autoCompleteItems.Name = "autoCompleteItems";
            this.autoCompleteItems.Size = new System.Drawing.Size(178, 195);
            this.autoCompleteItems.TabIndex = 0;
            this.autoCompleteItems.DoubleClick += new System.EventHandler(this.autoCompleteItems_DoubleClick);
            this.autoCompleteItems.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.autoCompleteItems_KeyPress);
            this.autoCompleteItems.KeyDown += new System.Windows.Forms.KeyEventHandler(this.autoCompleteItems_KeyDown);
            // 
            // resetSearchTextTimer
            // 
            this.resetSearchTextTimer.Interval = 3000;
            this.resetSearchTextTimer.Tick += new System.EventHandler(this.resetSearchTextTimer_Tick);
            // 
            // borderPanel
            // 
            this.borderPanel.BackColor = System.Drawing.Color.RoyalBlue;
            this.borderPanel.Controls.Add(this.backgroundPanel);
            this.borderPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.borderPanel.Location = new System.Drawing.Point(0, 0);
            this.borderPanel.Name = "borderPanel";
            this.borderPanel.Size = new System.Drawing.Size(180, 200);
            this.borderPanel.TabIndex = 1;
            // 
            // backgroundPanel
            // 
            this.backgroundPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.backgroundPanel.BackColor = System.Drawing.SystemColors.Window;
            this.backgroundPanel.Controls.Add(this.autoCompleteItems);
            this.backgroundPanel.Location = new System.Drawing.Point(1, 1);
            this.backgroundPanel.Name = "backgroundPanel";
            this.backgroundPanel.Size = new System.Drawing.Size(178, 198);
            this.backgroundPanel.TabIndex = 0;
            // 
            // Intellisense
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Window;
            this.ClientSize = new System.Drawing.Size(180, 200);
            this.Controls.Add(this.borderPanel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "Intellisense";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "Intellisense";
            this.Deactivate += new System.EventHandler(this.Intellisense_Deactivate);
            this.Leave += new System.EventHandler(this.Intellisense_Leave);
            this.borderPanel.ResumeLayout(false);
            this.backgroundPanel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListBox autoCompleteItems;
        private System.Windows.Forms.Timer resetSearchTextTimer;
        private System.Windows.Forms.Panel borderPanel;
        private System.Windows.Forms.Panel backgroundPanel;
    }
}