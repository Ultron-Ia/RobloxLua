using System;
using System.Windows.Forms;

namespace PunkXInjector
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            
            AppDomain.CurrentDomain.UnhandledException += (s, e) => {
                System.IO.File.WriteAllText("crash.txt", "Unhandled:\n" + e.ExceptionObject.ToString());
            };
            Application.ThreadException += (s, e) => {
                System.IO.File.WriteAllText("crash.txt", "Thread:\n" + e.Exception.ToString());
            };

            try
            {
                Application.Run(new MainForm());
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText("crash.txt", "Main:\n" + ex.ToString());
            }
        }
    }
}
