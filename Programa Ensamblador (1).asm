# --- Algoritmo de Cifrado y Checksum ---
# Inicializacion
ADDI $s0, $zero, 0      # Base Address = 0
ADDI $s1, $zero, 5      # Limite del bucle = 5
ADDI $t0, $zero, 0      # Indice i = 0
ADDI $t1, $zero, 55     # Llave inicial (Key)
ADDI $t2, $zero, 0      # Checksum acumulador
ADD  $t3, $s0, $zero    # Puntero de memoria dinámico

# Inicio del Bucle (Direccion virtual 0x18)
SLT  $t5, $t0, $s1      # Comprobar si i < 5
BEQ  $t5, $zero, 9      # Si i >= 5, saltar 9 instrucciones (salir)

# Cuerpo del Bucle
LW   $t4, 0($t3)        # Cargar dato de memoria
OR   $t4, $t4, $t1      # Operacion Logica: Dato OR Key
ADDI $t4, $t4, 10       # Operacion Aritmetica: Dato + 10
ANDI $t4, $t4, 255      # Filtro: Mantener byte bajo (0xFF)
ADD  $t2, $t2, $t4      # Actualizar Checksum
SW   $t4, 0($t3)        # Guardar dato cifrado en memoria

# Actualizacion de contadores
ADDI $t0, $t0, 1        # i++
ADDI $t3, $t3, 4        # Siguiente palabra en memoria
ADDI $t1, $t1, 1        # Modificar llave para siguiente ciclo

# Salto al inicio
J    0x18               # Saltar a la instruccion SLT

# Fin del programa (Direccion virtual 0x48)
J    0x48               # Bucle infinito final