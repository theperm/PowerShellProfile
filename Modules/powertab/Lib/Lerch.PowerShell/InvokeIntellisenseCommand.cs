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
using System.Text;
using System.Management.Automation;
using System.Drawing;

namespace Lerch.PowerShell.Commands
{
    [Cmdlet("Invoke", "Intellisense", DefaultParameterSetName = "ExistingText")]
    public class InvokeIntellisenseCommand : Cmdlet
    {
        #region Parameters

        [Parameter(Position = 0,
            Mandatory = false, 
            ParameterSetName = "ExistingText",
            ValueFromPipeline = false)]
        public string ExistingText
        {
            get { return _existingText; }
            set
            {
                _existingText = String.IsNullOrEmpty(value) ? String.Empty : value;
            }
        }

        [Parameter(Position = 0,
            Mandatory = false,
            ValueFromPipeline = false)]
        public bool ShowGUI
        {
            get { return _showGUI; }
            set { _showGUI = value; }
        }

        [Parameter(Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string[] Choices
        {
            get { return _choices; }
            set { _choices = value; }
        }

        #endregion Parameters

        #region Private Data

        private string _existingText = String.Empty;
        private bool _showGUI = true;
        private string[] _choices = null;

        private int _validItemCount = 0;
        private string _firstValidItem = null;

        private Size _fontSize = Size.Empty;
        private IntPtr _consoleHandle = IntPtr.Zero;
        private Point _windowLocation = Point.Empty;

        private Intellisense _intellisense = null;

        #endregion Private Data

        protected override void BeginProcessing()
        {
            if (_showGUI)
            {
                _validItemCount = 0;
                _firstValidItem = null;

                _fontSize = Win32.GetCurrentFontSize();
                _consoleHandle = Win32.GetConsoleWindow();
                _windowLocation = Win32.GetWindowLocation(_consoleHandle);

                _intellisense = new Intellisense();
                System.Management.Automation.Host.PSHostRawUserInterface rawUI = this.CommandRuntime.Host.UI.RawUI;
                _intellisense.SetPositionForConsole(_windowLocation, rawUI.CursorPosition.X + 1 - rawUI.WindowPosition.X, rawUI.CursorPosition.Y - rawUI.WindowPosition.Y, _fontSize);
                _intellisense.SetPrefix(_existingText);
            }
        }

        protected override void ProcessRecord()
        {
            if (_showGUI)
            {
                WriteDebug("ShowGUI is true, enumerating list and adding to intellisense GUI");
                foreach (string choice in _choices)
                {
                    if (!String.IsNullOrEmpty(choice))
                    {
                        _intellisense.Add(choice);
                        _validItemCount++;
                        if (String.IsNullOrEmpty(_firstValidItem))
                        {
                            _firstValidItem = choice;
                        }
                    }
                }
            }
            else
            {
                WriteDebug("ShowGUI is false, passing pipeline data on through");
                WriteObject(_choices, true);
            }
        }

        protected override void EndProcessing()
        {
            if (_showGUI)
            {
                if (_validItemCount > 2)
                {
                    WriteDebug("More than 2 valid items, displaying intellisense");
                    if (_intellisense.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        if (!String.IsNullOrEmpty(_intellisense.SelectedValue))
                        {
                            WriteObject(_intellisense.SelectedValue);
                        }
                    }
                    else
                    {
                        WriteDebug("Intellisense cancelled");
                    }
                }
                else if (_firstValidItem != null)
                {
                    WriteDebug("2 or less valid items given, returning the first vlaid item found");
                    WriteObject(_firstValidItem);
                }
            }
        }
    }
}
