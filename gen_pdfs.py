import os
from fpdf import FPDF

LOGO_PATH = r"c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\Logo_Opcao2_Azul.png"

class EternalPDF(FPDF):
    def __init__(self, title_text):
        super().__init__()
        self.title_text = title_text

    def header(self):
        self.set_fill_color(20, 24, 30) # Very dark slate blue/grey
        self.rect(0, 0, 210, 35, 'F')
        
        if os.path.exists(LOGO_PATH):
            self.image(LOGO_PATH, 10, 5, 25)
            
        self.set_font('helvetica', 'B', 20)
        self.set_text_color(240, 240, 240)
        self.cell(32)
        self.cell(0, 15, "ETERNAL HUB", border=0, ln=1, align='L', fill=False)
        
        self.set_font('helvetica', '', 11)
        self.set_text_color(160, 170, 180)
        self.cell(32)
        self.cell(0, 5, self.title_text, border=0, ln=1, align='L', fill=False)
        self.ln(20)

    def footer(self):
        self.set_y(-15)
        self.set_font('helvetica', 'I', 9)
        self.set_text_color(150, 150, 150)
        self.cell(0, 10, f'Pagina {self.page_no()} - Documentacao Oficial | Desenvolvido pela Equipe Eternal', 0, 0, 'C')

def create_guide():
    pdf = EternalPDF('Manual do Usuario')
    pdf.add_page()
    
    # 1. Introdução
    pdf.set_fill_color(30, 144, 255) # Blue header
    pdf.set_text_color(255, 255, 255)
    pdf.set_font("helvetica", 'B', 12)
    pdf.cell(0, 8, "  1. Introducao", ln=True, fill=True)
    pdf.ln(3)
    pdf.set_text_color(50, 50, 50)
    pdf.set_font("helvetica", '', 11)
    pdf.multi_cell(0, 6, "O Eternal Hub eh uma ferramenta avancada, desenvolvida com foco em estabilidade e compatibilidade universal na plataforma Roblox. Este documento detalha seus principais recursos e funcionalidades disponiveis para os usuarios.")
    
    pdf.ln(5)
    
    # 2. Skin Changer
    pdf.set_fill_color(30, 144, 255)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font("helvetica", 'B', 12)
    pdf.cell(0, 8, "  2. Sistema de Customizacao (Skin Changer)", ln=True, fill=True)
    pdf.ln(3)
    pdf.set_text_color(50, 50, 50)
    pdf.set_font("helvetica", '', 11)
    pdf.multi_cell(0, 6, "O sistema permite ampla modificacao estetica do personagem:\n- Insercao Manual (Manual Injection): Substituicao direta de identificadores de textura e malhas. Altamente recomendado para contornar restricoes visuais em jogos especificos, como Brookhaven.\n- Analise de Objetos (GetObjects): Processamento automatizado de texturas e imagens diretas.\n- Suporte: Compatibilidade padronizada para itens de vestuario (Camisas, Calcas) e acessorios.")

    pdf.ln(5)
    
    # 3. Ferramentas adicionais
    pdf.set_fill_color(30, 144, 255)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font("helvetica", 'B', 12)
    pdf.cell(0, 8, "  3. Modulos de Visualizacao e Combate", ln=True, fill=True)
    pdf.ln(3)
    pdf.set_text_color(50, 50, 50)
    pdf.set_font("helvetica", '', 11)
    pdf.multi_cell(0, 6, "- Assistencia de Mira (Aimbot): Ajuste de campo de visao (FOV), interrupcao de barreira visual (Wall Check) e rastreamento silencioso.\n- Interface Sensorial (ESP): Monitoramento completo atraves de delimitadores visuais (Boxes), rastreamento direcional (Tracers) e analise de estrutura (Skeleton).\n- Modificadores de Fisica: Manipulacao de parametros do cliente, como velocidade de movimento (WalkSpeed), aceleracao de salto (JumpPower) e desativacao de oclusao (NoClip).")

    pdf.output("EternalHub_Guide.pdf")

def create_compatibility():
    pdf = EternalPDF('Lista de Compatibilidade de Servidor')
    pdf.add_page()
    
    # Intro
    pdf.set_font("helvetica", '', 11)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 6, "A visibilidade das alteracoes esteticas efetuadas pelo modulo 'Skin Changer' esta condicionada a implementacao e seguranca de rede (Server-Side) estabelecida por cada desenvolvedor. A relacao a seguir descreve a compatibilidade operacional nas sessoes testadas.")
    pdf.ln(6)

    # Visão Global
    pdf.set_fill_color(46, 139, 87) # Sea green
    pdf.set_font("helvetica", 'B', 12)
    pdf.set_text_color(255, 255, 255)
    pdf.cell(0, 8, "  Visao Global (Sincronizado para Terceiros)", ln=True, fill=True)
    pdf.ln(3)

    pdf.set_text_color(40, 40, 40)
    pdf.set_font("helvetica", '', 11)
    global_games = [
        "Brookhaven RP (Sincronizacao estabelecida via Manual Injection)",
        "Berry Avenue RP",
        "Bloxburg",
        "Catalog Avatar Creator",
        "Livetopia",
        "MeepCity e roleplays casuais similares"
    ]
    for game in global_games:
        pdf.cell(8)
        pdf.cell(0, 6, f"+ {game}", ln=True)
        
    pdf.ln(8)

    # Visão Local
    pdf.set_fill_color(205, 92, 92) # Soft red
    pdf.set_font("helvetica", 'B', 12)
    pdf.set_text_color(255, 255, 255)
    pdf.cell(0, 8, "  Visao Local (Sincronizacao Restrita ao Usuario)", ln=True, fill=True)
    pdf.ln(3)

    pdf.set_text_color(40, 40, 40)
    pdf.set_font("helvetica", '', 11)
    local_games = [
        "Murder Mystery 2 (MM2)",
        "Jailbreak / Mad City",
        "Blox Fruits / King Legacy",
        "BedWars / Arsenal",
        "Ecossistemas orientados a combate e simuladores restritivos"
    ]
    for game in local_games:
        pdf.cell(8)
        pdf.cell(0, 6, f"- {game}", ln=True)

    pdf.ln(12)
    
    # Dica Téncica
    pdf.set_fill_color(240, 240, 245)
    y_start = pdf.get_y()
    pdf.rect(10, y_start, 190, 22, 'F')
    
    pdf.set_font("helvetica", 'B', 10)
    pdf.set_text_color(70, 90, 120)
    pdf.set_y(y_start + 4)
    pdf.cell(10)
    pdf.cell(0, 5, "Recomendacao Tecnica:", ln=True)
    
    pdf.set_font("helvetica", '', 10)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(10)
    pdf.multi_cell(170, 5, "Para testar a compatibilidade em experiencias nao relatadas nesta documentacao, aconselha-se utilizar a funcao 'Copy Outfit'. A estabilidade e a ausencia de erros de processamento nessa funcao servem como indicador primario de suporte as requisicoes globais.")

    pdf.output("EternalHub_Compatibility.pdf")

if __name__ == "__main__":
    create_guide()
    create_compatibility()
    print("PDFs re-gerados com layout premium e tom formal!")
