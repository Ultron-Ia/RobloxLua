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

            // Prioritize the same folder as the .exe
            string dllPath = Path.Combine(Application.StartupPath, "EternalDLL.dll");
            
            if (!File.Exists(dllPath))
            {
                lblStatus.Text = "Status: DLL Not Found!";
                btnInject.Text = "⚡ INJECT";
                MessageBox.Show("Arquivo 'EternalDLL.dll' não encontrado!\n\nCertifique-se de que a DLL está na MESMA PASTA que este executável.", "Erro de Injeção", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            bool success = Injector.Inject(dllPath);

            if (success)
            {
                btnInject.Text = "⚡ INJECTED";
                btnInject.ForeColor = Color.SpringGreen;
                lblStatus.Text = "Status: Injected & Ready";
            }
            else
            {
                lblStatus.Text = "Status: Injection Failed (Roblox open?)";
                btnInject.Text = "⚡ INJECT";
                MessageBox.Show("Falha ao injetar! Certifique-se de que o Roblox (RobloxPlayerBeta) está aberto.", "Erro de Injeção", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private async void btnExecute_Click(object sender, EventArgs e)
        {
            string script = scriptEditor.Text;
            try
            {
                using (NamedPipeClientStream pipeClient = new NamedPipeClientStream(".", PipeName, PipeDirection.Out))
                {
                    await pipeClient.ConnectAsync(1000);
                    using (StreamWriter sw = new StreamWriter(pipeClient))
                    {
                        sw.Write(script);
                    }
                }
                lblStatus.Text = "Status: Script Sent!";
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Status: DLL Not Found (Attach first)";
                MessageBox.Show("Você precisa injetar a DLL no Roblox antes de executar!", "ETERNAL Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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
