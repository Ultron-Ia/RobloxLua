using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;
using FastColoredTextBoxNS; // Uses FCTB package

namespace PunkXInjector
{
    public class MainForm : Form
    {
        [DllImport("user32.dll")] static extern bool ReleaseCapture();
        [DllImport("user32.dll")] static extern int SendMessage(IntPtr h, int msg, int w, int l);
        [DllImport("Gdi32.dll", EntryPoint = "CreateRoundRectRgn")]
        static extern IntPtr CreateRoundRectRgn(int l, int t, int r, int b, int w, int h_);

        static readonly Color BG         = Color.FromArgb(0x10, 0x10, 0x16);
        static readonly Color SIDEBAR_BG = Color.FromArgb(0x0C, 0x0C, 0x12);
        static readonly Color CARD_BG    = Color.FromArgb(0x16, 0x16, 0x20);
        static readonly Color PURPLE     = Color.FromArgb(0x8A, 0x4B, 0xFF);
        static readonly Color PURPLE_DIM = Color.FromArgb(0x28, 0x1C, 0x40);
        static readonly Color RED        = Color.FromArgb(0xEC, 0x45, 0x45);
        static readonly Color RED_DIM    = Color.FromArgb(0x40, 0x1C, 0x20);
        static readonly Color GREEN      = Color.FromArgb(0x38, 0xD1, 0x6B);
        static readonly Color TEXT_DIM   = Color.FromArgb(0x78, 0x78, 0x90);
        static readonly Color TEXT_BRIGHT= Color.FromArgb(0xF0, 0xF0, 0xFF);
        static readonly Color BORDER     = Color.FromArgb(0x24, 0x24, 0x34);

        private string _dllPath = "";
        
        // Views
        private Panel _pnlInjector = null!;
        private Panel _pnlExecutor = null!;
        private Panel _navInjector = null!;
        private Panel _navExecutor = null!;
        private FastColoredTextBox _editor = null!;

        bool _sidebarVisible = true;
        bool _alwaysOnTop    = false;
        bool _autoRefresh    = true;
        bool _settingsOpen   = false;
        bool _keyStatusOpen  = false;
        int  _injectedCount  = 0;

        readonly List<RobloxInstance> _instances = new();
        System.Windows.Forms.Timer? _refreshTimer;

        Label  _lblInstances = null!;
        Label  _lblInjected  = null!;
        Label  _lblSubtitle  = null!;
        Label  _lblDllPath   = null!;
        Label  _lblExecStatus = null!;
        Panel  _sidebar      = null!;
        Panel  _mainArea     = null!;
        Panel  _processPanel = null!;
        Panel  _titleBar     = null!;

        public MainForm()
        {
            AutoScaleMode   = AutoScaleMode.None;
            FormBorderStyle = FormBorderStyle.None;
            BackColor       = BG;
            Size            = new Size(1020, 660);
            MinimumSize     = new Size(800, 540);
            StartPosition   = FormStartPosition.CenterScreen;
            DoubleBuffered  = true;

            BuildLayout();

            _refreshTimer = new System.Windows.Forms.Timer { Interval = 4000 };
            _refreshTimer.Tick += (_, _) => { if (_autoRefresh) RefreshInstances(); };
            _refreshTimer.Start();

            Load     += (_, _) => { RefreshInstances(); AutoFindDll(); SwitchView(true); };
            Resize   += (_, _) => Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, Width, Height, 14, 14));
            Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, Width, Height, 14, 14));
        }

        void AutoFindDll()
        {
            var p = Path.Combine(Application.StartupPath, "EternalDLL.dll");
            if (File.Exists(p)) SetDll(p);
            else {
                var devP = Path.Combine(Application.StartupPath, @"..\..\..\..\x64\Release\EternalDLL.dll");
                if (File.Exists(devP)) SetDll(devP);
            }
        }

        void SetDll(string path)
        {
            _dllPath = path;
            _lblDllPath.Text = Path.GetFileName(path);
            _lblDllPath.ForeColor = TEXT_BRIGHT;
            _lblDllPath.Font = new Font("Segoe UI", 9, FontStyle.Bold);
        }

        void BuildLayout()
        {
            SuspendLayout();
            _titleBar = new Panel { Dock = DockStyle.Top, Height = 56, BackColor = SIDEBAR_BG };
            _titleBar.MouseDown += (_, e) => { if (e.Button == MouseButtons.Left) { ReleaseCapture(); SendMessage(Handle, 0xA1, 0x2, 0); } };
            Controls.Add(_titleBar);
            BuildTitleBar();

            _sidebar = new Panel { Dock = DockStyle.Left, Width = 232, BackColor = SIDEBAR_BG };
            Controls.Add(_sidebar);
            BuildSidebar();

            _mainArea = new Panel { Dock = DockStyle.Fill, BackColor = BG };
            Controls.Add(_mainArea);
            
            _pnlInjector = new Panel { Dock = DockStyle.Fill, BackColor = BG, Visible = true };
            _pnlExecutor = new Panel { Dock = DockStyle.Fill, BackColor = BG, Visible = false };
            _mainArea.Controls.Add(_pnlExecutor);
            _mainArea.Controls.Add(_pnlInjector);
            
            BuildInjectorView();
            BuildExecutorView();

            ResumeLayout(true);
        }

        void SwitchView(bool showInjector)
        {
            _pnlInjector.Visible = showInjector;
            _pnlExecutor.Visible = !showInjector;
            
            // Update Nav visual states
            StyleNavButton(_navInjector, showInjector);
            StyleNavButton(_navExecutor, !showInjector);
        }

        void StyleNavButton(Panel nav, bool active)
        {
            nav.BackColor = active ? PURPLE_DIM : SIDEBAR_BG;
            var accent = nav.Controls[0];
            accent.Visible = active;
            nav.Cursor = active ? Cursors.Default : Cursors.Hand;
        }

        Panel CreateNavBtn(string icon, string text, int y, Action onClick)
        {
            var nav = new Panel { Location = new Point(12, y), Size = new Size(208, 44), BackColor = SIDEBAR_BG, Cursor = Cursors.Hand };
            nav.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, nav.Width, nav.Height, 8, 8));
            var accent = new Panel { Location = new Point(0, 10), Size = new Size(4, 24), BackColor = PURPLE, Visible = false };
            accent.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, 4, 24, 4, 4));
            nav.Controls.Add(accent);
            nav.Controls.Add(Lbl(icon, new Font("Segoe UI", 12), PURPLE, new Point(16, 9)));
            nav.Controls.Add(Lbl(text, new Font("Segoe UI", 9, FontStyle.Bold), Color.White, new Point(44, 13)));
            
            // Click on components passing through
            nav.Click += (_, _) => onClick();
            foreach (Control c in nav.Controls) c.Click += (_, _) => onClick();
            return nav;
        }

        // ════════════════════════════════════════════════════════════════════════
        // TITLE BAR
        // ════════════════════════════════════════════════════════════════════════
        void BuildTitleBar()
        {
            _titleBar.Controls.Add(new PxLogoLabel { Location = new Point(16, 12), Size = new Size(32, 32) });
            _titleBar.Controls.Add(Lbl("PUNK X", new Font("Segoe UI", 11, FontStyle.Bold), PURPLE, new Point(56, 12)));
            _titleBar.Controls.Add(Lbl("v1.0.0", new Font("Segoe UI", 7), TEXT_DIM, new Point(58, 32)));

            var pill = new Button
            {
                Text = "  Authenticated", Font = new Font("Segoe UI", 9, FontStyle.Bold), ForeColor = TEXT_BRIGHT,
                BackColor = Color.FromArgb(0x19, 0x19, 0x22), FlatStyle = FlatStyle.Flat,
                Size = new Size(180, 32), Cursor = Cursors.Hand, Anchor = AnchorStyles.Top
            };
            pill.FlatAppearance.BorderColor = BORDER; pill.FlatAppearance.BorderSize = 1;
            pill.Click += (_, _) => ShowKeyStatus();
            void PlacePill() { pill.Location = new Point((_titleBar.Width - pill.Width) / 2, 12); }
            _titleBar.Resize += (_, _) => PlacePill();
            
            pill.Controls.Add(new Panel { BackColor = GREEN, Size = new Size(8, 8), Location = new Point(14, 12), Region = Region.FromHrgn(CreateRoundRectRgn(0,0,8,8,8,8)) });
            _titleBar.Controls.Add(pill);

            var btnClose   = TitleBtn("✕", RED,      _ => Application.Exit());
            var btnMin     = TitleBtn("─", TEXT_DIM, _ => WindowState = FormWindowState.Minimized);
            var btnGear    = TitleBtn("⚙", TEXT_DIM, _ => ShowSettings());
            var btnSidebar = TitleBtn("≡", TEXT_DIM, _ => ToggleSidebar());

            void PlaceTitleBtns()
            {
                int rx = _titleBar.Width - 12;
                foreach (var b in new[] { btnClose, btnMin, btnGear, btnSidebar })
                {
                    b.Location = new Point(rx - b.Width, 12);
                    rx -= b.Width + 4;
                }
            }
            _titleBar.Resize += (_, _) => PlaceTitleBtns();
            _titleBar.Controls.AddRange(new Control[] { btnClose, btnMin, btnGear, btnSidebar });

            PlacePill(); PlaceTitleBtns();
        }

        // ════════════════════════════════════════════════════════════════════════
        // SIDEBAR
        // ════════════════════════════════════════════════════════════════════════
        void BuildSidebar()
        {
            int y = 16;
            _sidebar.Controls.Add(SectionLabel("MENU", y)); y += 28;

            _navInjector = CreateNavBtn("⚡", "INJECTOR", y, () => SwitchView(true));
            _sidebar.Controls.Add(_navInjector); y += 48;
            
            _navExecutor = CreateNavBtn("📄", "EXECUTOR", y, () => SwitchView(false));
            _sidebar.Controls.Add(_navExecutor); y += 64;

            _sidebar.Controls.Add(SectionLabel("STATISTICS", y)); y += 28;

            _lblInstances = AddInfoCard(y, "INSTANCES", "0"); y += 80;
            _lblInjected  = AddInfoCard(y, "INJECTED",  "0");
            
            var footer = Lbl("Punk X Internal\nBuild 3.0 - Script Hub", new Font("Segoe UI", 7), Color.FromArgb(0x55,0x55,0x66), new Point(12, 0));
            footer.Anchor = AnchorStyles.Bottom | AnchorStyles.Left;
            _sidebar.Resize += (_, _) => footer.Location = new Point(12, _sidebar.Height - 40);
            _sidebar.Controls.Add(footer);
        }

        Label AddInfoCard(int y, string title, string val)
        {
            var card = new Panel { Location = new Point(12, y), Size = new Size(208, 70), BackColor = CARD_BG };
            card.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, card.Width, card.Height, 10, 10));
            card.Controls.Add(Lbl(title, new Font("Segoe UI", 7, FontStyle.Bold), TEXT_DIM, new Point(12, 10)));
            var num = new Label { Text = val, Font = new Font("Segoe UI", 22, FontStyle.Bold), ForeColor = TEXT_BRIGHT,
                                  AutoSize = false, Size = new Size(184, 38), Location = new Point(10, 26),
                                  TextAlign = ContentAlignment.MiddleLeft, BackColor = Color.Transparent };
            card.Controls.Add(num);
            _sidebar.Controls.Add(card);
            return num;
        }

        // ════════════════════════════════════════════════════════════════════════
        // INJECTOR VIEW
        // ════════════════════════════════════════════════════════════════════════
        void BuildInjectorView()
        {
            int padX = 28, y = 24;

            _pnlInjector.Controls.Add(Lbl("Target Application", new Font("Segoe UI", 16, FontStyle.Bold), Color.White, new Point(padX, y)));
            var btnRefresh = Btn("↻  Refresh Processes", new Font("Segoe UI", 8, FontStyle.Bold), TEXT_DIM, new Size(130, 32), CARD_BG);
            btnRefresh.FlatAppearance.BorderColor = BORDER; btnRefresh.FlatAppearance.BorderSize = 1;
            btnRefresh.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnRefresh.Click += (_, _) => RefreshInstances();
            void PlaceRefresh() { btnRefresh.Location = new Point(_pnlInjector.Width - btnRefresh.Width - padX, 26); }
            _pnlInjector.Resize += (_, _) => PlaceRefresh();
            _pnlInjector.Controls.Add(btnRefresh);

            y += 42;
            _lblSubtitle = Lbl("Waiting for Roblox...", new Font("Segoe UI", 9), TEXT_DIM, new Point(padX, y));
            _pnlInjector.Controls.Add(_lblSubtitle);

            y += 34;

            var pnlDll = new Panel { Location = new Point(padX, y), Size = new Size(_pnlInjector.Width - padX * 2, 54), BackColor = CARD_BG, Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right };
            pnlDll.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, pnlDll.Width, pnlDll.Height, 10, 10));
            pnlDll.Resize += (_, _) => pnlDll.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, pnlDll.Width, pnlDll.Height, 10, 10));

            pnlDll.Controls.Add(Lbl("📄", new Font("Segoe UI", 16), PURPLE, new Point(16, 12)));
            pnlDll.Controls.Add(Lbl("CHEAT MODULE", new Font("Segoe UI", 7, FontStyle.Bold), TEXT_DIM, new Point(54, 10)));
            
            _lblDllPath = Lbl("Click browse to select a cheat DLL...", new Font("Segoe UI", 9, FontStyle.Italic), TEXT_DIM, new Point(54, 24));
            pnlDll.Controls.Add(_lblDllPath);

            var btnBrowse = Btn("Browse...", new Font("Segoe UI", 8, FontStyle.Bold), Color.White, new Size(90, 32), PURPLE_DIM);
            btnBrowse.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            void PlaceBrowse() { btnBrowse.Location = new Point(pnlDll.Width - btnBrowse.Width - 12, 11); }
            pnlDll.Resize += (_, _) => PlaceBrowse();
            btnBrowse.Click += (_, _) =>
            {
                using var ofd = new OpenFileDialog { Filter = "Dynamic Link Library (*.dll)|*.dll", Title = "Select Cheat DLL" };
                if (ofd.ShowDialog() == DialogResult.OK) SetDll(ofd.FileName);
            };
            pnlDll.Controls.Add(btnBrowse); PlaceBrowse();
            _pnlInjector.Controls.Add(pnlDll);

            y += 74;

            var btnIA = Btn("⚡  Inject All", new Font("Segoe UI", 9, FontStyle.Bold), Color.White, new Size(130, 40), PURPLE);
            btnIA.Location = new Point(padX, y);
            btnIA.Click += (_, _) => InjectAll();

            var btnKA = Btn("✕  Kill All", new Font("Segoe UI", 9, FontStyle.Bold), RED, new Size(110, 40), RED_DIM);
            btnKA.Location = new Point(padX + 130 + 12, y);
            btnKA.Click += (_, _) => KillAll();
            
            var btnUnload = Btn("⏏  Unload Driver", new Font("Segoe UI", 9, FontStyle.Bold), TEXT_DIM, new Size(140, 40), CARD_BG);
            btnUnload.FlatAppearance.BorderColor = BORDER; 
            btnUnload.FlatAppearance.BorderSize = 1;
            btnUnload.Location = new Point(btnKA.Right + 12, y);
            btnUnload.Click += (_, _) => 
            {
                if (NativeKernel.Unload(out var err)) MessageBox.Show(err, "Punk X", MessageBoxButtons.OK, MessageBoxIcon.Information);
                else MessageBox.Show(err, "Punk X Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            };
            
            _pnlInjector.Controls.AddRange(new Control[] { btnIA, btnKA, btnUnload });

            y += 56;

            _processPanel = new Panel
            {
                Location = new Point(padX, y),
                Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right,
                BackColor = Color.Transparent, AutoScroll = true
            };
            void PlaceList() { _processPanel.Size = new Size(_pnlInjector.Width - padX * 2, _pnlInjector.Height - y - 20); }
            _pnlInjector.Resize += (_, _) => PlaceList();
            _pnlInjector.Controls.Add(_processPanel);

            PlaceRefresh(); PlaceList();
        }

        // ════════════════════════════════════════════════════════════════════════
        // EXECUTOR VIEW
        // ════════════════════════════════════════════════════════════════════════
        void BuildExecutorView()
        {
            int padX = 28, y = 24;

            _pnlExecutor.Controls.Add(Lbl("Lua Executor", new Font("Segoe UI", 16, FontStyle.Bold), Color.White, new Point(padX, y)));
            
            _lblExecStatus = Lbl("Ready to execute scripts.", new Font("Segoe UI", 9), TEXT_DIM, new Point(padX, y + 36));
            _pnlExecutor.Controls.Add(_lblExecStatus);

            var btnOpenLua = Btn("📂  Open Script", new Font("Segoe UI", 8, FontStyle.Bold), TEXT_DIM, new Size(120, 32), CARD_BG);
            btnOpenLua.FlatAppearance.BorderColor = BORDER; btnOpenLua.FlatAppearance.BorderSize = 1;
            btnOpenLua.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnOpenLua.Click += (_, _) =>
            {
                using var ofd = new OpenFileDialog { Filter = "Lua Scripts (*.lua;*.txt)|*.lua;*.txt|All Files (*.*)|*.*", Title = "Open Lua File" };
                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    _editor.Text = File.ReadAllText(ofd.FileName);
                    _lblExecStatus.Text = "Loaded " + Path.GetFileName(ofd.FileName);
                }
            };
            void PlaceOpenLua() { btnOpenLua.Location = new Point(_pnlExecutor.Width - btnOpenLua.Width - padX, 26); }
            _pnlExecutor.Resize += (_, _) => PlaceOpenLua();
            _pnlExecutor.Controls.Add(btnOpenLua);

            y += 66;

            // FCTB Editor Container
            var editorContainer = new Panel {
                Location = new Point(padX, y),
                BackColor = CARD_BG,
                Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right
            };
            editorContainer.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, editorContainer.Width, editorContainer.Height, 10, 10));
            editorContainer.Paint += (s, e) => {
                e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                using var p = new Pen(BORDER, 1);
                e.Graphics.DrawRoundedRect(p, new RectangleF(0,0,editorContainer.Width-1,editorContainer.Height-1), 10);
            };

            _editor = new FastColoredTextBox
            {
                Language = Language.Lua,
                BackColor = CARD_BG,
                ForeColor = TEXT_BRIGHT,
                IndentBackColor = Color.FromArgb(0x13, 0x13, 0x1A),
                LineNumberColor = TEXT_DIM,
                ServiceLinesColor = BORDER,
                SelectionColor = Color.FromArgb(60, PURPLE),
                CaretColor = Color.White,
                Font = new Font("Consolas", 11f),
                Text = "-- PUNK X LUA EXECUTOR\n-- Type your script or load a file\n\nprint(\"Hello from Punk X!\")",
                Dock = DockStyle.Fill,
                BorderStyle = BorderStyle.None
            };
            editorContainer.Controls.Add(_editor);
            _pnlExecutor.Controls.Add(editorContainer);

            // Action Buttons Row (bottom anchored)
            var actionY = _pnlExecutor.Height - 64;
            var btnExec = Btn("⚡  Execute", new Font("Segoe UI", 9, FontStyle.Bold), Color.White, new Size(130, 40), PURPLE);
            btnExec.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            btnExec.Click += ExecuteScript;
            _pnlExecutor.Controls.Add(btnExec);

            var btnClear = Btn("🗑  Clear", new Font("Segoe UI", 9, FontStyle.Bold), RED, new Size(110, 40), RED_DIM);
            btnClear.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            btnClear.Click += (_, _) => { _editor.Clear(); _lblExecStatus.Text = "Editor cleared."; };
            _pnlExecutor.Controls.Add(btnClear);

            void PlaceExecControls()
            {
                editorContainer.Size = new Size(_pnlExecutor.Width - padX * 2, _pnlExecutor.Height - y - 84);
                editorContainer.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, editorContainer.Width, editorContainer.Height, 10, 10));
                editorContainer.Invalidate();
                
                btnExec.Location = new Point(_pnlExecutor.Width - padX - btnExec.Width, _pnlExecutor.Height - 60);
                btnClear.Location = new Point(btnExec.Left - btnClear.Width - 12, _pnlExecutor.Height - 60);
            }
            _pnlExecutor.Resize += (_, _) => PlaceExecControls();

            PlaceOpenLua(); PlaceExecControls();
        }

        private async void ExecuteScript(object? sender, EventArgs e)
        {
            string script = _editor.Text;
            if (string.IsNullOrWhiteSpace(script)) return;

            _lblExecStatus.Text = "Sending script...";
            try
            {
                using (var pipeClient = new NamedPipeClientStream(".", "EternalPipe", PipeDirection.Out))
                {
                    await pipeClient.ConnectAsync(5000);
                    using (var sw = new StreamWriter(pipeClient))
                    {
                        await sw.WriteAsync(script);
                    }
                }
                _lblExecStatus.Text = "Script executed successfully!";
            }
            catch (TimeoutException)
            {
                _lblExecStatus.Text = "Connection timed out.";
                MessageBox.Show("Timed out waiting for DLL pipe. Did you inject the DLL?", "Punk X Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (Exception ex)
            {
                _lblExecStatus.Text = "Failed to send script.";
                MessageBox.Show("Communication error:\n" + ex.Message, "Punk X Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }


        // ════════════════════════════════════════════════════════════════════════
        // LOGIC
        // ════════════════════════════════════════════════════════════════════════
        void RefreshInstances()
        {
            if (InvokeRequired) { Invoke(RefreshInstances); return; }
            var procs = Process.GetProcessesByName("RobloxPlayerBeta");
            _instances.Clear();
            foreach (var p in procs) _instances.Add(new RobloxInstance { Pid = (uint)p.Id, Name = "RobloxPlayerBeta" });
            Sync();
        }

        void Sync()
        {
            if (InvokeRequired) { Invoke(Sync); return; }
            _lblInstances.Text  = _instances.Count.ToString();
            _lblInjected.Text   = _injectedCount.ToString();
            _lblSubtitle.Text   = _instances.Count > 0 ? $"Found {_instances.Count} active standard ro-execution process{(_instances.Count == 1 ? "" : "es")}." : "Waiting for Roblox player to start...";
            _lblSubtitle.ForeColor = _instances.Count > 0 ? Color.White : TEXT_DIM;
            RebuildCards();
        }

        void RebuildCards()
        {
            _processPanel.Controls.Clear();
            int y = 0;
            foreach (var inst in _instances)
            {
                var card = MakeCard(inst, y);
                _processPanel.Controls.Add(card);
                y += card.Height + 12; // Gap between cards
            }
        }

        Panel MakeCard(RobloxInstance inst, int yPos)
        {
            var card = new Panel
            {
                Location  = new Point(0, yPos),
                Size      = new Size(_processPanel.ClientSize.Width - 4, 76),
                BackColor = CARD_BG,
                Anchor    = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right
            };
            card.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, card.Width, 76, 12, 12));
            card.Paint += (s, e) => {
                e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                using var p = new Pen(BORDER, 1);
                e.Graphics.DrawRoundedRect(p, new RectangleF(0,0,card.Width-1,card.Height-1), 12);
            };

            var avatar = new Panel { Location = new Point(14, 14), Size = new Size(48, 48), BackColor = PURPLE_DIM, Region = Region.FromHrgn(CreateRoundRectRgn(0,0,48,48,24,24)) };
            avatar.Controls.Add(CentredLbl(48, "R", new Font("Segoe UI", 16, FontStyle.Bold), PURPLE, 11));
            card.Controls.Add(avatar);

            card.Controls.Add(Lbl(inst.Name, new Font("Segoe UI", 10, FontStyle.Bold), Color.White, new Point(76, 16)));

            var badge = new BadgeLabel
            {
                Text     = inst.Injected ? "INJECTED" : "IDLE",
                Location = new Point(76 + TextRenderer.MeasureText(inst.Name, new Font("Segoe UI", 10, FontStyle.Bold)).Width + 8, 18),
                Injected = inst.Injected
            };
            card.Controls.Add(badge);

            card.Controls.Add(Lbl($"PID  {inst.Pid}", new Font("Segoe UI", 8), TEXT_DIM, new Point(76, 38)));

            var btnInj = Btn("⚡  Inject", new Font("Segoe UI", 8, FontStyle.Bold), Color.White, new Size(96, 34), PURPLE);
            btnInj.Click += (_, _) => DoInject(inst, badge, btnInj);

            var btnKill = Btn("✕  Kill", new Font("Segoe UI", 8, FontStyle.Bold), RED, new Size(74, 34), RED_DIM);
            btnKill.Click += (_, _) => DoKill(inst);

            card.Controls.AddRange(new Control[] { btnInj, btnKill });

            void PlaceCardBtns()
            {
                btnKill.Location = new Point(card.Width - btnKill.Width - 14, 21);
                btnInj.Location  = new Point(btnKill.Left - btnInj.Width - 10, 21);
            }
            
            _processPanel.Resize += (_, _) =>
            {
                card.Width  = _processPanel.ClientSize.Width - 4;
                card.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, card.Width, 76, 12, 12));
                card.Invalidate();
                PlaceCardBtns();
            };
            
            card.Resize += (_, _) => PlaceCardBtns();
            PlaceCardBtns();
            return card;
        }

        void DoInject(RobloxInstance inst, BadgeLabel badge, Button btnInj)
        {
            if (string.IsNullOrEmpty(_dllPath) || !File.Exists(_dllPath)) { 
                MessageBox.Show("Please select a valid DLL to inject first from the Browse menu.", "Punk X", MessageBoxButtons.OK, MessageBoxIcon.Warning); 
                return; 
            }
            if (Injector.Inject(_dllPath, inst.Pid))
            {
                inst.Injected = true; badge.Text = "INJECTED"; badge.Injected = true; badge.Invalidate();
                btnInj.Text = "✔ Done"; btnInj.BackColor = GREEN; _injectedCount++; Sync();
            }
            else MessageBox.Show("Injection failed:\n" + Injector.LastError, "Punk X Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        void DoKill(RobloxInstance inst)
        {
            try { Process.GetProcessById((int)inst.Pid).Kill(); } catch { }
            if (inst.Injected) _injectedCount = Math.Max(0, _injectedCount - 1);
            RefreshInstances();
        }

        void InjectAll() { foreach (var inst in _instances.Where(i => !i.Injected).ToList()) DoInject(inst, new BadgeLabel(), new Button()); RebuildCards(); }
        void KillAll() { foreach (var inst in _instances.ToList()) DoKill(inst); }
        
        // ════════════════════════════════════════════════════════════════════════
        // MODALS
        // ════════════════════════════════════════════════════════════════════════
        void ShowKeyStatus() { if (_keyStatusOpen) return; _keyStatusOpen = true; var ov = Overlay(); var dlg = ModalPanel(ov, 420, 390); dlg.Controls.Add(ModalClose(dlg, () => { _keyStatusOpen = false; CloseOverlay(ov); })); var c = RoundPanel(new Size(72, 72), Color.FromArgb(0x2A, 0x16, 0x4A)); c.Location = new Point((dlg.Width - 72)/2, 28); c.Controls.Add(CentredLbl(72, "🔑", new Font("Segoe UI", 26), PURPLE, 14)); dlg.Controls.Add(c); dlg.Controls.Add(CentredLbl(dlg.Width, "KEY STATUS", new Font("Segoe UI", 14, FontStyle.Bold), Color.White, 116)); dlg.Controls.Add(CentredLbl(dlg.Width, "License & authentication information", new Font("Segoe UI", 8), TEXT_DIM, 144)); InfoRow(dlg, 178, "STATUS", "● Authenticated", GREEN); InfoRow(dlg, 248, "TIME REMAINING", "No expiry", Color.White); var br = Btn("🗑  Remove Key", new Font("Segoe UI", 10, FontStyle.Bold), RED, new Size(380, 44), RED_DIM); br.Location = new Point(20, 322); br.Click += (_, _) => { _keyStatusOpen = false; CloseOverlay(ov); }; dlg.Controls.Add(br); ov.Controls.Add(dlg); }
        void ShowSettings() { if (_settingsOpen) return; _settingsOpen = true; var ov = Overlay(); var dlg = ModalPanel(ov, 440, 360); dlg.Controls.Add(ModalClose(dlg, () => { _settingsOpen = false; CloseOverlay(ov); })); var c = RoundPanel(new Size(72, 72), Color.FromArgb(0x22, 0x22, 0x35)); c.Location = new Point((dlg.Width - 72)/2, 24); c.Controls.Add(CentredLbl(72, "⚙", new Font("Segoe UI", 26), TEXT_BRIGHT, 14)); dlg.Controls.Add(c); dlg.Controls.Add(CentredLbl(dlg.Width, "SETTINGS", new Font("Segoe UI", 14, FontStyle.Bold), Color.White, 108)); dlg.Controls.Add(CentredLbl(dlg.Width, "Application preferences", new Font("Segoe UI", 8), TEXT_DIM, 134)); SettingRow(dlg, 164, "▷  Always on Top", "Keep window above all others", on => { _alwaysOnTop = on; TopMost = on; }, _alwaysOnTop); SettingRow(dlg, 244, "↻  Auto Refresh", "Scan for Roblox every 4 seconds", on => _autoRefresh = on, _autoRefresh); ov.Controls.Add(dlg); }
        
        Panel Overlay() { var ov = new Panel { Dock = DockStyle.Fill, BackColor = Color.FromArgb(160, 0, 0, 0) }; Controls.Add(ov); ov.BringToFront(); return ov; }
        void CloseOverlay(Panel ov) { Controls.Remove(ov); ov.Dispose(); }
        Panel ModalPanel(Panel overlay, int w, int h) { var dlg = new Panel { Size = new Size(w, h), BackColor = Color.FromArgb(0x13, 0x13, 0x1A) }; dlg.Location = new Point((overlay.Width - w) / 2, (overlay.Height - h) / 2); dlg.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, w, h, 20, 20)); dlg.Paint += (_, e) => { e.Graphics.SmoothingMode = SmoothingMode.AntiAlias; using var pen = new Pen(BORDER, 2); e.Graphics.DrawRoundedRect(pen, new RectangleF(1, 1, dlg.Width - 2, dlg.Height - 2), 18); }; return dlg; }
        Button ModalClose(Panel dlg, Action oc) { var b = TitleBtn("✕", TEXT_DIM, _ => oc()); b.Location = new Point(dlg.Width - 40, 12); return b; }
        void InfoRow(Panel p, int y, string lbl, string val, Color vc) { var row = RoundPanel(new Size(380, 58), CARD_BG); row.Location = new Point(20, y); row.Controls.Add(Lbl(lbl, new Font("Segoe UI", 7, FontStyle.Bold), TEXT_DIM, new Point(14, 10))); row.Controls.Add(Lbl(val, new Font("Segoe UI", 11, FontStyle.Bold), vc, new Point(14, 26))); p.Controls.Add(row); }
        void SettingRow(Panel p, int y, string t, string s, Action<bool> ot, bool init) { var row = RoundPanel(new Size(400, 64), CARD_BG); row.Location = new Point(20, y); row.Controls.Add(Lbl(t, new Font("Segoe UI", 10, FontStyle.Bold), TEXT_BRIGHT, new Point(14, 14))); row.Controls.Add(Lbl(s, new Font("Segoe UI", 8), TEXT_DIM, new Point(14, 36))); var tog = new ToggleSwitch { Location = new Point(334, 19), Size = new Size(48, 26), IsOn = init }; tog.Toggled += ot; row.Controls.Add(tog); p.Controls.Add(row); }
        void ToggleSidebar() { _sidebarVisible = !_sidebarVisible; _sidebar.Visible = _sidebarVisible; }

        static Label Lbl(string text, Font font, Color fore, Point loc) => new Label { Text = text, Font = font, ForeColor = fore, AutoSize = true, Location = loc, BackColor = Color.Transparent };
        static Label SectionLabel(string text, int y) => new Label { Text = text, Font = new Font("Segoe UI", 8, FontStyle.Bold), ForeColor = Color.FromArgb(0x60, 0x60, 0x75), AutoSize = true, Location = new Point(12, y), BackColor = Color.Transparent };
        static Label CentredLbl(int pw, string text, Font font, Color fore, int y) => new Label { Text = text, Font = font, ForeColor = fore, AutoSize = false, Size = new Size(pw, 40), Location = new Point(0, y), TextAlign = ContentAlignment.MiddleCenter, BackColor = Color.Transparent };
        static Button Btn(string text, Font font, Color fore, Size size, Color back) { var b = new Button { Text = text, Font = font, ForeColor = fore, Size = size, BackColor = back, FlatStyle = FlatStyle.Flat, Cursor = Cursors.Hand }; b.FlatAppearance.BorderSize = 0; b.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, size.Width, size.Height, 8, 8)); return b; }
        static Button TitleBtn(string text, Color fore, Action<object> oc) { var b = new Button { Text = text, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 12), ForeColor = fore, BackColor = Color.Transparent, Size = new Size(32, 32), Cursor = Cursors.Hand }; b.FlatAppearance.BorderSize = 0; b.FlatAppearance.MouseOverBackColor = Color.FromArgb(40, 255, 255, 255); b.Click += (s, _) => oc(s!); return b; }
        static Panel RoundPanel(Size sz, Color bk) { var p = new Panel { Size = sz, BackColor = bk }; p.Region = Region.FromHrgn(CreateRoundRectRgn(0, 0, sz.Width, sz.Height, sz.Height / 2, sz.Height / 2)); return p; }
    }

    public class RobloxInstance { public uint Pid { get; set; } public string Name { get; set; } = "RobloxPlayerBeta"; public bool Injected { get; set; } }
    public class PxLogoLabel : Control { public PxLogoLabel() { SetStyle(ControlStyles.SupportsTransparentBackColor | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.DoubleBuffer, true); BackColor = Color.Transparent; } protected override void OnPaint(PaintEventArgs e) { var g = e.Graphics; g.SmoothingMode = SmoothingMode.AntiAlias; var cx = Width / 2f; var cy = Height / 2f; float r = Math.Min(Width, Height) / 2f - 1; var pts = Enumerable.Range(0, 6).Select(i => { double a = Math.PI / 180 * (60 * i - 30); return new PointF(cx + r * (float)Math.Cos(a), cy + r * (float)Math.Sin(a)); }).ToArray(); using var br = new LinearGradientBrush(new Rectangle(0, 0, Width, Height), Color.FromArgb(0x8A, 0x4B, 0xFF), Color.FromArgb(0x55, 0x16, 0xD0), 45f); g.FillPolygon(br, pts); using var sf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center }; g.DrawString("PX", new Font("Segoe UI", 7, FontStyle.Bold), Brushes.White, new RectangleF(0, 0, Width, Height), sf); } }
    public class BadgeLabel : Control { public bool Injected { get; set; } public BadgeLabel() { SetStyle(ControlStyles.SupportsTransparentBackColor | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.DoubleBuffer, true); BackColor = Color.Transparent; Size = new Size(72, 22); } protected override void OnPaint(PaintEventArgs e) { var g = e.Graphics; g.SmoothingMode = SmoothingMode.AntiAlias; using var br = new SolidBrush(Injected ? Color.FromArgb(0x22, 0x80, 0x50) : Color.FromArgb(0x2A, 0x2A, 0x3A)); g.FillRoundedRect(br, new RectangleF(0, 0, Width, Height), 6); using var sf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center }; using var tb = new SolidBrush(Injected ? Color.FromArgb(0x38, 0xD1, 0x6B) : Color.FromArgb(0x88, 0x88, 0xAA)); g.DrawString(Text, new Font("Segoe UI", 7, FontStyle.Bold), tb, new RectangleF(0, 0, Width, Height), sf); } }
    public class ToggleSwitch : Control { public bool IsOn { get; set; } public event Action<bool>? Toggled; static readonly Color ON = Color.FromArgb(0x8A, 0x4B, 0xFF); static readonly Color OFF = Color.FromArgb(0x33, 0x33, 0x44); public ToggleSwitch() { SetStyle(ControlStyles.SupportsTransparentBackColor | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.DoubleBuffer, true); BackColor = Color.Transparent; Size = new Size(48, 26); Cursor = Cursors.Hand; } protected override void OnClick(EventArgs e) { IsOn = !IsOn; Invalidate(); Toggled?.Invoke(IsOn); } protected override void OnPaint(PaintEventArgs e) { var g = e.Graphics; g.SmoothingMode = SmoothingMode.AntiAlias; using var br = new SolidBrush(IsOn ? ON : OFF); g.FillRoundedRect(br, new RectangleF(0, 2, Width, Height - 4), (Height - 4) / 2); int cx = IsOn ? Width - 14 : 6; using var th = new SolidBrush(Color.White); g.FillEllipse(th, cx, 4, Height - 8, Height - 8); } }
    
    public static class GfxExt { 
        public static void FillRoundedRect(this Graphics g, Brush br, RectangleF r, float rd) { using var path = new GraphicsPath(); path.AddArc(r.X, r.Y, rd * 2, rd * 2, 180, 90); path.AddArc(r.Right - rd * 2, r.Y, rd * 2, rd * 2, 270, 90); path.AddArc(r.Right - rd * 2, r.Bottom - rd * 2, rd * 2, rd * 2, 0, 90); path.AddArc(r.X, r.Bottom - rd * 2, rd * 2, rd * 2, 90, 90); path.CloseFigure(); g.FillPath(br, path); } 
        public static void DrawRoundedRect(this Graphics g, Pen p, RectangleF r, float rd) { using var path = new GraphicsPath(); path.AddArc(r.X, r.Y, rd * 2, rd * 2, 180, 90); path.AddArc(r.Right - rd * 2, r.Y, rd * 2, rd * 2, 270, 90); path.AddArc(r.Right - rd * 2, r.Bottom - rd * 2, rd * 2, rd * 2, 0, 90); path.AddArc(r.X, r.Bottom - rd * 2, rd * 2, rd * 2, 90, 90); path.CloseFigure(); g.DrawPath(p, path); } 
    }
}
