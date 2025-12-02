# Proyecto Final: Procesador MIPS Pipeline de 5 Etapas & Decodificador

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Python](https://img.shields.io/badge/Language-Python-yellow)
![Architecture](https://img.shields.io/badge/Architecture-MIPS32-red)
![Status](https://img.shields.io/badge/Status-Completed-success)

## Descripción General

Este proyecto consiste en el diseño e implementación de un *Procesador MIPS de 32 bits con arquitectura Pipeline de 5 etapas*, desarrollado en Verilog.

Para complementar el hardware, se desarrolló un *Decodificador de Instrucciones (Assembler) en Python*. Esta herramienta toma código ensamblador MIPS personalizado, valida la sintaxis y genera el código máquina (binario) necesario para inicializar la Memoria de Instrucciones del procesador.

El sistema es capaz de ejecutar algoritmos no triviales que involucran aritmética, lógica, acceso a memoria y control de flujo.

---

## Características del Proyecto

### 1. Arquitectura MIPS (Verilog)
El procesador implementa el datapath completo con las 5 etapas clásicas del pipeline, resolviendo la ejecución de instrucciones en paralelo:
* *IF (Instruction Fetch):* Búsqueda de instrucción y actualización del PC.
* *ID (Instruction Decode):* Decodificación y lectura de registros.
* *EX (Execute):* Operaciones ALU y cálculo de direcciones.
* *MEM (Memory Access):* Lectura/Escritura en memoria de datos.
* *WB (Write Back):* Escritura de resultados en el banco de registros.

*Módulos Principales:*
* Unidad de Control y ALU Control.
* Hazard Detection Unit & Forwarding Unit (si aplica).
* Registros de Pipeline (IF/ID, ID/EX, EX/MEM, MEM/WB).
* Memoria de Datos e Instrucciones separadas (Arquitectura Harvard).

### 2. Decodificador de Instrucciones (Python)
Una herramienta de software que actúa como ensamblador.
* *Entrada:* Archivo .asm o texto directo.
* *Salida:* Archivo .txt o .bin con cadenas de 32 bits (Big Endian).
* *Soporte:* Convierte mnemónicos R-Type, I-Type y J-Type a su opcode, rs, rt, rd, shamt, funct o inmediato correspondientes.

---

## Conjunto de Instrucciones Soportado (ISA)

| Tipo | Instrucciones | Descripción |
| :--- | :--- | :--- |
| *R-Type* | ADD, SUB, AND, OR, SLT | Operaciones aritméticas y lógicas entre registros. |
| *I-Type* | ADDI, ANDI, ORI, XORI, SLTI | Operaciones con inmediatos. |
| *I-Type* | LW, SW | Carga y almacenamiento en memoria (Load/Store). |
| *I-Type* | BEQ | Salto condicional (Branch if Equal). |
| *J-Type* | J | Salto incondicional (Jump). |

---

## Algoritmo de Prueba: Cifrado y Checksum

Para validar el funcionamiento del pipeline, se diseñó un algoritmo en ensamblador que realiza una transformación de datos (cifrado simple) y verificación de integridad. El algoritmo evita recursiones simples como Fibonacci, optando por un uso intensivo de memoria y saltos.

*Lógica del Programa:*
1.  *Iteración:* Recorre un arreglo de 5 palabras en memoria.
2.  *Transformación:* A cada dato leído le aplica:
    * OR con una llave dinámica (Key).
    * Suma aritmética (ADDI +10).
    * Enmascaramiento de bits (ANDI 0xFF).
3.  *Checksum:* Acumula el resultado en un registro para verificar la integridad de los datos procesados.
4.  *Almacenamiento:* Guarda el dato cifrado nuevamente en memoria.
5.  *Bucle:* Utiliza SLT y BEQ para el control del bucle y J para reiniciar o terminar.

### Código Fuente (Fragmento)
```assembly
# Cuerpo del Bucle
LW   $t4, 0($t3)        # Cargar dato
OR   $t4, $t4, $t1      # Cifrado: Dato OR Key
ADDI $t4, $t4, 10       # Desplazamiento
ANDI $t4, $t4, 255      # Máscara (Byte bajo)
ADD  $t2, $t2, $t4      # Actualizar Checksum
SW   $t4, 0($t3)        # Guardar dato
