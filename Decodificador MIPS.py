import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import struct

class MipsDecoderApp:
    REG_MAP = {
        '$zero': 0, '$at': 1, '$v0': 2, '$v1': 3,
        '$a0': 4, '$a1': 5, '$a2': 6, '$a3': 7,
        '$t0': 8, '$t1': 9, '$t2': 10, '$t3': 11, '$t4': 12, '$t5': 13, '$t6': 14, '$t7': 15,
        '$s0': 16, '$s1': 17, '$s2': 18, '$s3': 19, '$s4': 20, '$s5': 21, '$s6': 22, '$s7': 23,
        '$t8': 24, '$t9': 25, '$k0': 26, '$k1': 27, '$gp': 28, '$sp': 29, '$fp': 30, '$ra': 31
    }

    INSTRUCTIONS = {
        "ADD": {"type": "R", "opcode": 0x00, "funct": 0x20},
        "SUB": {"type": "R", "opcode": 0x00, "funct": 0x22},
        "AND": {"type": "R", "opcode": 0x00, "funct": 0x24},
        "OR":  {"type": "R", "opcode": 0x00, "funct": 0x25},
        "NOR": {"type": "R", "opcode": 0x00, "funct": 0x27},
        "SLT": {"type": "R", "opcode": 0x00, "funct": 0x2A},
        "ADDI": {"type": "I", "opcode": 0x08},
        "ANDI": {"type": "I", "opcode": 0x0C},
        "ORI":  {"type": "I", "opcode": 0x0D},
        "XORI": {"type": "I", "opcode": 0x0E},
        "SLTI": {"type": "I", "opcode": 0x0A},
        "BEQ":  {"type": "I_BRANCH", "opcode": 0x04},
        "BNE":  {"type": "I_BRANCH", "opcode": 0x05},
        "LW":   {"type": "I_MEM", "opcode": 0x23},
        "SW":   {"type": "I_MEM", "opcode": 0x2B},
        "J":    {"type": "J", "opcode": 0x02},
        "JAL":  {"type": "J", "opcode": 0x03},
    }

    def __init__(self, master):
        self.master = master
        master.title("MIPS32 Assembler")
        master.geometry("600x600")

        main_frame = tk.Frame(master, padx=10, pady=10)
        main_frame.pack(fill="both", expand=True)

        tk.Label(main_frame, text="Código Ensamblador MIPS:", font=("Arial", 10, "bold")).pack(anchor="w")
        
        self.text_input = scrolledtext.ScrolledText(main_frame, height=15, undo=True, font=("Consolas", 10))
        self.text_input.pack(fill="both", expand=True, pady=5)

        btn_frame = tk.Frame(main_frame)
        btn_frame.pack(fill="x", pady=5)

        tk.Button(btn_frame, text="📂 Cargar .txt", command=self.load_file).pack(side="left", padx=5)
        tk.Button(btn_frame, text="⚙️ Ensamblar y Guardar", command=self.process_and_save, bg="#dddddd").pack(side="right", padx=5, fill="x", expand=True)

        help_frame = tk.LabelFrame(main_frame, text="Referencia Rápida", padx=5, pady=5)
        help_frame.pack(fill="x", pady=10)
        help_text = (
            "R-Type: ADD $t0, $s1, $s2\n"
            "I-Type: ADDI $t0, $s1, -100\n"
            "Memoria: LW $t0, 4($sp)\n"
            "Saltos: J 0x00400000 | BEQ $t0, $t1, 8\n"
        )
        tk.Label(help_frame, text=help_text, justify="left", font=("Consolas", 9)).pack(anchor="w")

        self.status_label = tk.Label(master, text="Listo", bd=1, relief="sunken", anchor="w")
        self.status_label.pack(fill="x", side="bottom")

    def _log(self, msg, error=False):
        color = "red" if error else "green"
        self.status_label.config(text=msg, fg=color)
        if error:
            messagebox.showerror("Error", msg)

    def parse_register(self, reg_str):
        reg_str = reg_str.strip().lower()
        if not reg_str.startswith('$'):
            raise ValueError(f"Registro inválido: {reg_str}")
        
        if reg_str[1:].isdigit():
            val = int(reg_str[1:])
            if 0 <= val <= 31: return val
            raise ValueError(f"Registro fuera de rango: {reg_str}")
        
        if reg_str in self.REG_MAP:
            return self.REG_MAP[reg_str]
        
        raise ValueError(f"Nombre de registro desconocido: {reg_str}")

    def parse_immediate(self, imm_str, bits=16):
        try:
            val = int(imm_str, 0)
            min_val = -(2**(bits-1))
            max_u_val = (2**bits) - 1

            if not (min_val <= val <= max_u_val):
                 raise ValueError(f"Valor {val} fuera de rango para {bits} bits")
            
            return val
        except ValueError:
            raise ValueError(f"Inmediato inválido: {imm_str}")

    def assemble_line(self, line):
        line = line.split('#')[0].strip()
        if not line: return None
        
        parts = line.replace(',', ' ').replace('(', ' ').replace(')', ' ').split()
        if not parts: return None

        op_name = parts[0].upper()
        
        if op_name not in self.INSTRUCTIONS:
            raise ValueError(f"Instrucción desconocida: {op_name}")

        info = self.INSTRUCTIONS[op_name]
        itype = info["type"]
        opcode = info["opcode"]
        
        args = parts[1:]
        instr_int = 0

        try:
            if itype == "R":
                if len(args) != 3: raise ValueError(f"{op_name} requiere 3 operandos")
                rd = self.parse_register(args[0])
                rs = self.parse_register(args[1])
                rt = self.parse_register(args[2])
                shamt = 0 
                funct = info["funct"]
                instr_int = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct

            elif itype == "I":
                if len(args) != 3: raise ValueError(f"{op_name} requiere 3 operandos")
                rt = self.parse_register(args[0])
                rs = self.parse_register(args[1])
                imm = self.parse_immediate(args[2], 16)
                instr_int = (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

            elif itype == "I_MEM":
                if len(args) != 3: raise ValueError(f"{op_name} formato inválido. Use: LW $rt, off($rs)")
                rt = self.parse_register(args[0])
                offset = self.parse_immediate(args[1], 16)
                base = self.parse_register(args[2])
                instr_int = (opcode << 26) | (base << 21) | (rt << 16) | (offset & 0xFFFF)

            elif itype == "I_BRANCH":
                if len(args) != 3: raise ValueError(f"{op_name} requiere 3 operandos")
                rs = self.parse_register(args[0])
                rt = self.parse_register(args[1])
                offset = self.parse_immediate(args[2], 16)
                instr_int = (opcode << 26) | (rs << 21) | (rt << 16) | (offset & 0xFFFF)

            elif itype == "J":
                if len(args) != 1: raise ValueError(f"{op_name} requiere 1 dirección")
                addr = self.parse_immediate(args[0], 26)
                instr_int = (opcode << 26) | (addr & 0x3FFFFFF)

        except Exception as e:
            raise ValueError(f"Error en sintaxis de {op_name}: {str(e)}")

        return instr_int

    def load_file(self):
        path = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt"), ("All", "*.*")])
        if path:
            try:
                with open(path, 'r') as f:
                    self.text_input.delete('1.0', tk.END)
                    self.text_input.insert('1.0', f.read())
                self._log(f"Cargado: {path}")
            except Exception as e:
                self._log(f"Error leyendo archivo: {e}", error=True)

    def process_and_save(self):
        raw_text = self.text_input.get('1.0', tk.END).splitlines()
        binary_instructions = []

        try:
            for i, line in enumerate(raw_text):
                if not line.strip() or line.strip().startswith('#'):
                    continue
                
                val = self.assemble_line(line)
                if val is not None:
                    binary_instructions.append(val)
                
        except ValueError as e:
            self._log(f"Error en línea {i+1}: {e}", error=True)
            return

        if not binary_instructions:
            self._log("No hay instrucciones válidas para guardar.", error=True)
            return

        path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Archivo de Texto", "*.txt"), ("Archivo Binario", "*.bin")]
        )
        
        if not path: return

        try:
            if path.lower().endswith('.bin'):
                with open(path, 'wb') as f:
                    for instr in binary_instructions:
                        f.write(struct.pack('>I', instr))
                self._log(f"Éxito: {len(binary_instructions)} instr. guardadas en .bin")
            
            else:
                with open(path, 'w') as f:
                    lines = []
                    for instr in binary_instructions:
                        bin_str = f"{instr:032b}" 
                        lines.append(bin_str)
                    f.write("\n".join(lines))
                self._log(f"Éxito: {len(binary_instructions)} instr. guardadas en .txt")
            
            messagebox.showinfo("Completado", "Archivo generado correctamente.")

        except Exception as e:
            self._log(f"Error escribiendo archivo: {e}", error=True)

if __name__ == "__main__":
    root = tk.Tk()
    app = MipsDecoderApp(root)
    root.mainloop()