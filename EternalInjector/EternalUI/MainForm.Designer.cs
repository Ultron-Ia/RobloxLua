namespace EternalUI
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null)) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.topPanel = new System.Windows.Forms.Panel();
            this.lblTitle = new System.Windows.Forms.Label();
            this.btnMinimize = new System.Windows.Forms.Button();
            this.btnClose = new System.Windows.Forms.Button();
            this.scriptEditor = new FastColoredTextBoxNS.FastColoredTextBox();
            this.bottomPanel = new System.Windows.Forms.Panel();
            this.btnInject = new System.Windows.Forms.Button();
            this.btnUnload = new System.Windows.Forms.Button();
            this.btnExecute = new System.Windows.Forms.Button();
            this.btnClear = new System.Windows.Forms.Button();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.lblStatus = new System.Windows.Forms.ToolStripStatusLabel();

            this.topPanel.SuspendLayout();
            this.bottomPanel.SuspendLayout();
            this.statusStrip.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.scriptEditor)).BeginInit();
            this.SuspendLayout();

            // topPanel
            this.topPanel.BackColor = System.Drawing.Color.FromArgb(20, 20, 20);
            this.topPanel.Controls.Add(this.lblTitle);
            this.topPanel.Controls.Add(this.btnMinimize);
            this.topPanel.Controls.Add(this.btnClose);
            this.topPanel.Dock = System.Windows.Forms.DockStyle.Top;
            this.topPanel.Height = 45;
            this.topPanel.MouseDown += new System.Windows.Forms.MouseEventHandler(this.topPanel_MouseDown);
            this.topPanel.Paint += new System.Windows.Forms.PaintEventHandler(this.Panel_Paint_Gradient);

            // lblTitle
            this.lblTitle.AutoSize = true;
            this.lblTitle.BackColor = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("Segoe UI Semibold", 14F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.Location = new System.Drawing.Point(12, 10);
            this.lblTitle.Text = "ETERNAL";

            // btnClose
            this.btnClose.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnClose.FlatAppearance.BorderSize = 0;
            this.btnClose.BackColor = System.Drawing.Color.Transparent;
            this.btnClose.ForeColor = System.Drawing.Color.White;
            this.btnClose.Location = new System.Drawing.Point(610, 8);
            this.btnClose.Size = new System.Drawing.Size(32, 28);
            this.btnClose.Text = "✕";
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            this.btnClose.MouseEnter += (s, e) => btnClose.BackColor = System.Drawing.Color.Red;
            this.btnClose.MouseLeave += (s, e) => btnClose.BackColor = System.Drawing.Color.Transparent;

            // btnMinimize
            this.btnMinimize.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMinimize.FlatAppearance.BorderSize = 0;
            this.btnMinimize.BackColor = System.Drawing.Color.Transparent;
            this.btnMinimize.ForeColor = System.Drawing.Color.White;
            this.btnMinimize.Location = new System.Drawing.Point(575, 8);
            this.btnMinimize.Size = new System.Drawing.Size(32, 28);
            this.btnMinimize.Text = "—";
            this.btnMinimize.Click += new System.EventHandler(this.btnMinimize_Click);
            this.btnMinimize.MouseEnter += (s, e) => btnMinimize.BackColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnMinimize.MouseLeave += (s, e) => btnMinimize.BackColor = System.Drawing.Color.Transparent;

            // scriptEditor
            this.scriptEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scriptEditor.Location = new System.Drawing.Point(0, 45);
            this.scriptEditor.Name = "scriptEditor";
            this.scriptEditor.Size = new System.Drawing.Size(650, 315);

            // bottomPanel
            this.bottomPanel.BackColor = System.Drawing.Color.FromArgb(20, 20, 20);
            this.bottomPanel.Controls.Add(this.btnInject);
            this.bottomPanel.Controls.Add(this.btnUnload);
            this.bottomPanel.Controls.Add(this.btnExecute);
            this.bottomPanel.Controls.Add(this.btnClear);
            this.bottomPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.bottomPanel.Height = 60;

            // btnExecute
            this.btnExecute.BackColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.btnExecute.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnExecute.FlatAppearance.BorderColor = System.Drawing.Color.Magenta;
            this.btnExecute.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            this.btnExecute.ForeColor = System.Drawing.Color.White;
            this.btnExecute.Location = new System.Drawing.Point(12, 12);
            this.btnExecute.Size = new System.Drawing.Size(130, 36);
            this.btnExecute.Text = "➤ EXECUTE";
            this.btnExecute.Click += new System.EventHandler(this.btnExecute_Click);
            this.btnExecute.MouseEnter += (s, e) => btnExecute.FlatAppearance.BorderSize = 2;
            this.btnExecute.MouseLeave += (s, e) => btnExecute.FlatAppearance.BorderSize = 1;

            // btnInject
            this.btnInject.BackColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.btnInject.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnInject.FlatAppearance.BorderColor = System.Drawing.Color.Cyan;
            this.btnInject.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            this.btnInject.ForeColor = System.Drawing.Color.White;
            this.btnInject.Location = new System.Drawing.Point(150, 12);
            this.btnInject.Size = new System.Drawing.Size(130, 36);
            this.btnInject.Text = "⚡ INJECT";
            this.btnInject.Click += new System.EventHandler(this.btnInject_Click);
            this.btnInject.MouseEnter += (s, e) => btnInject.FlatAppearance.BorderSize = 2;
            this.btnInject.MouseLeave += (s, e) => btnInject.FlatAppearance.BorderSize = 1;

            // btnUnload
            this.btnUnload.BackColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.btnUnload.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnUnload.FlatAppearance.BorderColor = System.Drawing.Color.Orange;
            this.btnUnload.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            this.btnUnload.ForeColor = System.Drawing.Color.White;
            this.btnUnload.Location = new System.Drawing.Point(288, 12);
            this.btnUnload.Size = new System.Drawing.Size(130, 36);
            this.btnUnload.Text = "⚠ UNLOAD";
            this.btnUnload.Click += new System.EventHandler(this.btnUnload_Click);
            this.btnUnload.MouseEnter += (s, e) => btnUnload.FlatAppearance.BorderSize = 2;
            this.btnUnload.MouseLeave += (s, e) => btnUnload.FlatAppearance.BorderSize = 1;

            // btnClear
            this.btnClear.BackColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.btnClear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnClear.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.btnClear.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            this.btnClear.ForeColor = System.Drawing.Color.Gray;
            this.btnClear.Location = new System.Drawing.Point(508, 12);
            this.btnClear.Size = new System.Drawing.Size(130, 36);
            this.btnClear.Text = "🗑 CLEAR";
            this.btnClear.Click += new System.EventHandler(this.btnClear_Click);
            this.btnClear.MouseEnter += (s, e) => btnClear.ForeColor = System.Drawing.Color.White;
            this.btnClear.MouseLeave += (s, e) => btnClear.ForeColor = System.Drawing.Color.Gray;

            // statusStrip
            this.statusStrip.BackColor = System.Drawing.Color.FromArgb(15, 15, 15);
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { this.lblStatus });
            this.statusStrip.Location = new System.Drawing.Point(0, 428);
            this.statusStrip.Size = new System.Drawing.Size(650, 22);

            // lblStatus
            this.lblStatus.ForeColor = System.Drawing.Color.Gray;
            this.lblStatus.Text = "Ready | Eternal Injector v1.0";

            // MainForm
            this.BackColor = System.Drawing.Color.FromArgb(15, 15, 15);
            this.ClientSize = new System.Drawing.Size(650, 450);
            this.Controls.Add(this.scriptEditor);
            this.Controls.Add(this.topPanel);
            this.Controls.Add(this.bottomPanel);
            this.Controls.Add(this.statusStrip);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "MainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ETERNAL INJECTOR";
            this.Load += new System.EventHandler(this.MainForm_Load);

            this.topPanel.ResumeLayout(false);
            this.topPanel.PerformLayout();
            this.bottomPanel.ResumeLayout(false);
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.scriptEditor)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        private System.Windows.Forms.Panel topPanel;
        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.Button btnMinimize;
        private FastColoredTextBoxNS.FastColoredTextBox scriptEditor;
        private System.Windows.Forms.Panel bottomPanel;
        private System.Windows.Forms.Button btnInject;
        private System.Windows.Forms.Button btnUnload;
        private System.Windows.Forms.Button btnExecute;
        private System.Windows.Forms.Button btnClear;
        private System.Windows.Forms.StatusStrip statusStrip;
        private System.Windows.Forms.ToolStripStatusLabel lblStatus;
    }
}
