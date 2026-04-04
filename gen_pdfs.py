import os
from fpdf import FPDF

# Absolute path to the logo
LOGO_PATH = r"C:\Users\hoff\.gemini\antigravity\brain\9f3c40b5-4f9d-4337-b20e-b21688ef64c0\eternal_hub_logo_1774920550239.png"

class EternalPDF(FPDF):
    def __init__(self, title_text):
        super().__init__()
        self.title_text = title_text

    def header(self):
        if os.path.exists(LOGO_PATH):
            self.image(LOGO_PATH, 10, 8, 25)
        self.set_font('helvetica', 'B', 16)
        self.cell(80)
        self.cell(30, 10, self.title_text, border=0, align='C')
        self.ln(25)

    def footer(self):
        self.set_y(-15)
        self.set_font('helvetica', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()} | Eternal Hub Team', 0, 0, 'C')

def create_guide():
    pdf = EternalPDF('Guia de Usuario - Eternal Hub')
    pdf.add_page()
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(0, 10, "1. Visao Geral", ln=True)
    pdf.set_font("helvetica", size=11)
    pdf.multi_cell(0, 8, "Eternal Hub eh um conjunto de scripts premium para Roblox, focado em performance, precisao e controle. Oferecemos ferramentas de combate, visualizacao e customizacao de ponta.")
    
    pdf.ln(5)
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(0, 10, "2. Recurso: Skin Changer Avançado", ln=True)
    pdf.set_font("helvetica", size=11)
    pdf.multi_cell(0, 8, "- Manual Injection: Metodo agressivo que limpa o personagem e injeta IDs direto (Estilo Brookhaven).\n- GetObjects: Resolve IDs de imagem e texturas automaticamente.\n- Suporte Universal: Funciona com camisas, calças, camisetas e acessórios.")

    pdf.ln(5)
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(0, 10, "3. Outros Recursos", ln=True)
    pdf.set_font("helvetica", size=11)
    pdf.multi_cell(0, 8, "- Aimbot: Silent Aim e FOV customizavel.\n- Visuals: ESP completo (Boxes e Tracers).\n- Local: WalkSpeed, JumpPower, Spinbot e NoClip.")

    pdf.ln(10)
    pdf.set_font("helvetica", 'B', 12)
    pdf.cell(0, 10, "Copyright 2026 Eternal Hub. Todos os direitos reservados.", ln=True, align='C')
    
    pdf.output("EternalHub_Guide.pdf")

def create_compatibility():
    pdf = EternalPDF('Lista de Compatibilidade - Skin Changer')
    pdf.add_page()
    
    pdf.set_text_color(0, 150, 0) # Green for global
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(0, 10, "[GLOBAL/VISIVEL] Jogos que suportam visualizacao total:", ln=True)
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("helvetica", size=11)
    pdf.multi_cell(0, 8, "- Brookhaven RP (Total)\n- Berry Avenue RP (Total)\n- Bloxburg (Alto)\n- Catalog Avatar Creator (Total)\n- Livetopia\n- Berry Avenue")

    pdf.ln(10)
    pdf.set_text_color(200, 0, 0) # Red for local
    pdf.set_font("helvetica", 'B', 14)
    pdf.cell(0, 10, "[LOCAL/CLIENT-SIDE] Jogos restritos (apenas voce ve):", ln=True)
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("helvetica", size=11)
    pdf.multi_cell(0, 8, "- Murder Mystery 2 (MM2)\n- Jailbreak / Mad City\n- Blox Fruits\n- BedWars\n- Pet Simulator 99\n- A maioria dos simuladores de combate.")

    pdf.ln(15)
    pdf.set_font("helvetica", 'I', 10)
    pdf.multi_cell(0, 8, "Dica: Sempre tente usar o 'Copy Outfit' em um jogo novo. Se funcionar perfeitamente, o jogo provavelmente permite visibilidade global.")

    pdf.output("EternalHub_Compatibility.pdf")

if __name__ == "__main__":
    create_guide()
    create_compatibility()
    print("PDFs gerados com sucesso!")
