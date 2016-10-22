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
using System.Runtime.InteropServices;
using System.Reflection;
using System.Drawing;

namespace Lerch.PowerShell
{
    public class Win32
    {
        public const int SM_CYBORDER = 6;
        public const int SM_CYCAPTION = 4;
        public const int SM_CYSIZEFRAME = 33;

        public const int SM_CXBORDER = 5;
        public const int SM_CXSIZEFRAME = 32;

        public static Size GetCurrentFontSize()
        {
            //Need to use reflection to obtain pointer to the console output buffer
            Type consoleType = typeof(Console);

            IntPtr _consoleOutputHandle = (IntPtr)consoleType.InvokeMember(
              "ConsoleOutputHandle",
              BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.GetProperty,
              null,
              null,
              null);

            //Obtain the current console font index
            CONSOLE_FONT_INFO currentFont;
            bool success = GetCurrentConsoleFont(
            _consoleOutputHandle,
            false,
            out currentFont);

            //Use that index to obtain font size
            Coord coord = GetConsoleFontSize(_consoleOutputHandle, currentFont.nFont);
            return new Size(coord.X, coord.Y);
        }

        public static int GetWindowVerticalOffset()
        {
            int border = GetSystemMetrics(SM_CYBORDER);
            int caption = GetSystemMetrics(SM_CYCAPTION);
            int sizableBorder = GetSystemMetrics(SM_CYSIZEFRAME);
            return border + caption + sizableBorder;
        }

        public static int GetWindowHorizontalOffset()
        {
            int border = GetSystemMetrics(SM_CYBORDER);
            int sizableBorder = GetSystemMetrics(SM_CYSIZEFRAME);
            return border + sizableBorder;
        }

        public static Point GetWindowLocation(IntPtr windowHandle)
        {
            RECT rect;
            GetWindowRect(windowHandle, out rect);
            return rect.Location;
        }

        [DllImport("user32.dll")]
        public static extern int GetSystemMetrics(int smIndex);

        [DllImport("kernel32.dll")]
        public static extern bool GetCurrentConsoleFont(
            IntPtr hConsoleOutput,
            bool bMaximumWindow,
            out CONSOLE_FONT_INFO lpConsoleCurrentFont);

        //[DllImport("kernel32.dll")]
        //public static extern bool GetCurrentConsoleFontEx(
        //    IntPtr hConsoleOutput,
        //    bool bMaximumWindow,
        //    out CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx);

        [DllImport("kernel32.dll")]
        public static extern Coord GetConsoleFontSize(
            IntPtr hConsoleOutput,
            Int32 nFont);

        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

        [StructLayout(LayoutKind.Sequential)]
        public struct CONSOLE_FONT_INFO
        {
            public int nFont;
            public Coord dwFontSize;
        }

        //[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Auto)]
        //public struct CONSOLE_FONT_INFOEX
        //{
        //    public const int LF_FACESIZE = 32;
        //    public uint cbSize;
        //    public uint nFont;
        //    public Coord dwFontSize;
        //    public uint FontFamily;
        //    public uint FontWeight;
        //    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=LF_FACESIZE)]
        //    public string FaceName;
        //}

        [StructLayout(LayoutKind.Sequential)]
        public struct Coord
        {
            public short X;
            public short Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;

            public RECT(int left_, int top_, int right_, int bottom_)
            {
                Left = left_;
                Top = top_;
                Right = right_;
                Bottom = bottom_;
            }

            public int Height { get { return Bottom - Top; } }
            public int Width { get { return Right - Left; } }
            public Size Size { get { return new Size(Width, Height); } }

            public Point Location { get { return new Point(Left, Top); } }

            // Handy method for converting to a System.Drawing.Rectangle
            public Rectangle ToRectangle()
            { return Rectangle.FromLTRB(Left, Top, Right, Bottom); }

            public static RECT FromRectangle(Rectangle rectangle)
            {
                return new RECT(rectangle.Left, rectangle.Top, rectangle.Right, rectangle.Bottom);
            }

            public override int GetHashCode()
            {
                return Left ^ ((Top << 13) | (Top >> 0x13))
                  ^ ((Width << 0x1a) | (Width >> 6))
                  ^ ((Height << 7) | (Height >> 0x19));
            }

            #region Operator overloads

            public static implicit operator Rectangle(RECT rect)
            {
                return rect.ToRectangle();
            }

            public static implicit operator RECT(Rectangle rect)
            {
                return FromRectangle(rect);
            }

            #endregion
        }
    }
}
