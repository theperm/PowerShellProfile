/******************************************************************\
* Copyright (c) 2007 Aaron Lerch
* http://www.aaronlerch.com/blog
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
\******************************************************************/

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Collections;

namespace Lerch.PowerShell
{
    public partial class Intellisense : Form
    {
        private string _prefix = String.Empty;
        private Point _consoleLocation = Point.Empty;
        private Size _fontSize = Size.Empty;
        private int _x = 0;
        private int _y = 0;

        public Intellisense()
        {
            InitializeComponent();
        }

        protected override void OnLoad(EventArgs e)
        {
            if (autoCompleteItems.Items.Count > 0)
            {
                autoCompleteItems.SelectedIndex = 0;
            }
            autoCompleteItems.Focus();

            // Adjust width to the size of the biggest item (note, this could be dangerous, if an item is huge. Consider a cap?)
            int maxWidth = this.Width;
            Graphics g = Graphics.FromHwnd(this.Handle);
            foreach (object obj in autoCompleteItems.Items)
            {
                try
                {
                    string str = obj.ToString();
                    int itemWidth = g.MeasureString(str, autoCompleteItems.Font).ToSize().Width;
                    if (itemWidth > maxWidth)
                    {
                        maxWidth = itemWidth;
                    }
                }
                catch
                {
                }
            }

            this.Width = maxWidth;

            // Adjust Height for few items
            if (autoCompleteItems.Items.Count > 0)
            {
                int height = autoCompleteItems.ItemHeight * (autoCompleteItems.Items.Count + 1);
                this.Height = ((height < this.Height) && (height > 0)) ? height : this.Height;
            }

            // Adjust Location for screen restrictions
            AdjustLocationForScreen();

            base.OnLoad(e);
        }

        private void AdjustLocationForScreen()
        {
            Screen myScreen = Screen.FromControl(this);
            if (this.Bounds.Bottom > myScreen.WorkingArea.Bottom)
            {
                // Show above text
                this.Top -= this.Height + _fontSize.Height;
            }

            if (this.Bounds.Right > myScreen.WorkingArea.Right)
            {
                // Adjust to edge of screen
                this.Left -= (this.Bounds.Right - myScreen.WorkingArea.Right);
            }
        }

        protected override void OnShown(EventArgs e)
        {
            this.Activate();
            base.OnShown(e);
        }

        private static int horizOffset = Win32.GetWindowHorizontalOffset();
        private static int vertOffset = Win32.GetWindowVerticalOffset();

        public void SetPositionForConsole(Point consoleLocation, int x, int y, Size fontSize)
        {
            _consoleLocation = consoleLocation;
            _fontSize = fontSize;
            _x = x;
            _y = y;

            int offsetX = x * fontSize.Width + horizOffset;
            int offsetY = (y + 1) * fontSize.Height + vertOffset;
            this.Location = this.PointToScreen(new Point(consoleLocation.X + offsetX, consoleLocation.Y + offsetY));
        }

        public void ClearItems()
        {
            autoCompleteItems.Items.Clear();
        }

        public void Add(string value)
        {
            autoCompleteItems.Items.Add(value);
        }

        public void SetPrefix(string prefix)
        {
            if (prefix != null)
            {
                _prefix = prefix;
            }
        }

        public string SelectedValue
        {
            get
            {
                if (autoCompleteItems.SelectedIndex != -1)
                {
                    return autoCompleteItems.SelectedItem as string;
                }
                return String.Empty;
            }
        }

        protected override bool ProcessDialogKey(Keys keyData)
        {
            switch (keyData)
            {
                case Keys.Escape:
                case Keys.Back:
                    autoCompleteItems.Items.Clear();
                    this.Close();
                    this.DialogResult = DialogResult.Cancel;
                    break;
                case Keys.Tab:
                case Keys.Enter:
                    this.DialogResult = DialogResult.OK;
                    break;
            }

            return base.ProcessDialogKey(keyData);
        }

        private void Intellisense_Deactivate(object sender, EventArgs e)
        {
            this.Close();
        }

        private void Intellisense_Leave(object sender, EventArgs e)
        {
            this.Close();
        }

        private void autoCompleteItems_DoubleClick(object sender, EventArgs e)
        {
            this.DialogResult = (autoCompleteItems.SelectedIndex != -1) ? DialogResult.OK : DialogResult.Cancel;
            this.Close();
        }

        private string searchString = String.Empty;

        private void autoCompleteItems_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Add the pressed key to the search string
            searchString += e.KeyChar;

            // Select the item in the combobox (if any) that matches the prefix + search
            int index = autoCompleteItems.FindString(_prefix + searchString);

            if (index != -1)
            {
                autoCompleteItems.SelectedIndex = index;
            }

            resetSearchTextTimer.Stop();
            resetSearchTextTimer.Start();
        }

        private void resetSearchTextTimer_Tick(object sender, EventArgs e)
        {
            ResetSearchData();
        }

        private void ResetSearchData()
        {
            resetSearchTextTimer.Stop();
            searchString = String.Empty;
        }

        private void autoCompleteItems_KeyDown(object sender, KeyEventArgs e)
        {
            // If up or down arrows (or page up or page down) then
            // reset the search data
            if ((e.KeyData == Keys.Up)
                || (e.KeyData == Keys.Down)
                || (e.KeyData == Keys.PageUp)
                || (e.KeyData == Keys.PageDown))
            {
                ResetSearchData();
            }
        }
    }
}