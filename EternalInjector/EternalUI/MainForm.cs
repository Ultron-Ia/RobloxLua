using System;
using System.Drawing;
using System.Windows.Forms;
using FastColoredTextBoxNS;
using System.Runtime.InteropServices;
using System.Drawing.Drawing2D;
using System.IO;
using System.IO.Pipes;
using System.Threading.Tasks;

namespace EternalUI
{
    public partial class MainForm : Form
    {
        private const string PipeName = "EternalPipe";

        // For dragging the chromeless window
        [DllImport("user32.dll")]
        public static extern bool ReleaseCapture();
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

        [DllImport("Gdi32.dll", EntryPoint = "CreateRoundRectRgn")]
        private static extern IntPtr CreateRoundRectRgn(int nLeftRect, int nTopRect, int nRightRect, int nBottomRect, int nWidthEllipse, int nHeightEllipse);

        public MainForm()
        {
            InitializeComponent();
            Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, Width, Height, 20, 20)); // Rounded corners
            SetupEditor();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            StartPipeServer();
        }

        private void SetupEditor()
        {
            scriptEditor.Language = Language.Lua;
            scriptEditor.BackColor = Color.FromArgb(25, 25, 25);
            scriptEditor.ForeColor = Color.Gainsboro;
            scriptEditor.IndentBackColor = Color.FromArgb(30, 30, 30);
            scriptEditor.LineNumberColor = Color.FromArgb(100, 100, 100);
            scriptEditor.ServiceLinesColor = Color.FromArgb(40, 40, 40);
            scriptEditor.SelectionColor = Color.FromArgb(60, 255, 0, 255);
            scriptEditor.CaretColor = Color.White;
            scriptEditor.Font = new Font("Consolas", 10f);
            scriptEditor.Text = "-- ETERNAL INJECTOR\n-- Execute o seu script aqui\n\nloadstring(game:HttpGet(\"https://raw.githubusercontent.com/Ultron-Ia/RobloxLua/main/main.lua\"))()";
        }

        private void topPanel_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                SendMessage(Handle, 0xA1, 0x2, 0);
            }
        }

        private void Panel_Paint_Gradient(object sender, PaintEventArgs e)
        {
            using (LinearGradientBrush brush = new LinearGradientBrush(this.ClientRectangle, Color.FromArgb(40, 40, 40), Color.FromArgb(20, 20, 20), 90F))
            {
                e.Graphics.FillRectangle(brush, this.ClientRectangle);
            }
        }

        private void btnClose_Click(object sender, EventArgs e) => Application.Exit();
        private void btnMinimize_Click(object sender, EventArgs e) => WindowState = FormWindowState.Minimized;

        private void btnInject_Click(object sender, EventArgs e)
        {
            lblStatus.Text = "Status: Injecting...";
            btnInject.Text = "⚡ INJECTING";

            // 1. Try local folder
            string dllPath = Path.Combine(Application.StartupPath, "EternalDLL.dll");
            
            // 2. Try VS Output folders if not found locally (for development)
            if (!File.Exists(dllPath)) {
                string[] searchPaths = {
                    Path.Combine(Application.StartupPath, @"..\..\..\..\x64\Release\EternalDLL.dll"),
                    Path.Combine(Application.StartupPath, @"..\..\..\..\..\x64\Release\EternalDLL.dll"),
                    @"C:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\EternalInjector\x64\Release\EternalDLL.dll"
                };

                foreach (var p in searchPaths) {
                    if (File.Exists(p)) {
                        dllPath = p;
                        break;
                    }
                }
            }
            
            if (!File.Exists(dllPath))
            {
                lblStatus.Text = "Status: DLL Not Found!";
                btnInject.Text = "⚡ INJECT";
                MessageBox.Show($"Arquivo 'EternalDLL.dll' não encontrado!\n\nProcurei em:\n{dllPath}\n\nCertifique-se de que a DLL foi compilada (Release x64) ou está na mesma pasta que o executável.", "Erro de Injeção", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            lblStatus.Text = "Status: Injecting " + Path.GetFileName(dllPath);

            bool success = Injector.Inject(dllPath);

            if (success)
            {
                btnInject.Text = "⚡ INJECTED";
                btnInject.ForeColor = Color.SpringGreen;
                lblStatus.Text = "Status: " + Injector.LastError;
            }
            else
            {
                lblStatus.Text = "Status: Error";
                btnInject.Text = "⚡ INJECT";
                MessageBox.Show("Erro de Injeção: " + Injector.LastError + "\n\nSugestões:\n1. Execute o ETERNAL como Administrador.\n2. Verifique se o Roblox está em execução.\n3. Certifique-se de que a DLL é x64.", "ETERNAL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private async void btnExecute_Click(object sender, EventArgs e)
        {
            string script = scriptEditor.Text;
            lblStatus.Text = "Status: Sending Script...";
            
            try
            {
                using (NamedPipeClientStream pipeClient = new NamedPipeClientStream(".", PipeName, PipeDirection.Out))
                {
                    // Increased timeout to 10 seconds
                    await pipeClient.ConnectAsync(10000);
                    using (StreamWriter sw = new StreamWriter(pipeClient))
                    {
                        sw.Write(script);
                    }
                }
                lblStatus.Text = "Status: Script Executed!";
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Status: Communication Error";
                string detail = ex.Message;
                if (ex.InnerException != null) detail += "\n" + ex.InnerException.Message;
                
                MessageBox.Show($"Ocorreu um erro ao enviar o script para o Roblox:\n\n{detail}\n\nNota: Certifique-se de que a DLL foi realmente injetada e que você viu o MessageBox de DEBUG.", "Erro de Execução", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnUnload_Click(object sender, EventArgs e)
        {
            lblStatus.Text = "Status: Unloading Driver...";
            string error;
            bool success = NativeKernel.Unload(out error);
            
            if (success)
            {
                lblStatus.Text = "Status: Driver Unloaded";
                MessageBox.Show(error, "ETERNAL INJECTOR", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                lblStatus.Text = "Status: Unload Error";
                MessageBox.Show(error, "ETERNAL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            scriptEditor.Clear();
            lblStatus.Text = "Status: Editor Cleared";
        }

        private void StartPipeServer()
        {
            // The C# side sends the script, the DLL side (C++) receives it.
            // We use the button click to send, so no persistent server needed here.
        }
    }
}
