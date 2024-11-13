.data
	array: .align 2
		.space 40       # 40 bytes de espaço alocado para armazenar o vetor (10 inteiros)
	
	msg: .asciiz "Elementos do vetor: "    # Mensagem para indicar os elementos do vetor
	space: .asciiz " "                     # Espaço em branco entre os elementos
	MAX: .word 10	                       # Define o tamanho máximo do vetor

.text
main:
	la $s3, array            # Carrega o endereço base do array em $s3
	li $a1, 255              # Define o valor máximo para números aleatórios (0 a 254)
	lw $t1, MAX              # Carrega o tamanho do vetor em $t1 (10 elementos)
	
	# Preencher vetor com valores aleatórios
	prencherVetor:
		move $t0, $zero          # Inicializa o iterador $t0 com zero para o loop de preenchimento
		move $s7, $zero          # Inicializa o índice do vetor $s7 com zero
		
		loop_prencher:
		sll $s7, $t0, 2          # Calcula o deslocamento: $s7 = $t0 * 4 (cada elemento ocupa 4 bytes) ou $s7 = $t0 * 2^$t0
		add $s7, $s3, $s7        # Calcula o endereço atual do vetor: $s7 = endereço base + deslocamento
		beq $t0, $t1, ordenarVetor # Se $t0 == $t1, o vetor está preenchido e chama a função de ordenação

		li $v0, 42               # Syscall para gerar número pseudo-aleatório no intervalo [0, $a1]
		syscall
		move $s0, $a0            # Move o número aleatório gerado em $a0 para $s0

		sw $s0, 0($s7)           # Armazena o número aleatório na posição calculada do vetor
		addi $t0, $t0, 1         # Incrementa o iterador do loop de preenchimento
		j loop_prencher          # Volta para o início do loop de preenchimento


	# Ordenar o vetor
	ordenarVetor:
		move $t0, $zero          # Inicializa o iterador $t0 para o loop externo de ordenação

		loop_i:
			move $t2, $zero          # Inicializa o iterador $t2 para o loop interno de ordenação
			subi $t4, $t1, 1         # Define a condição de parada do loop externo: $t4 = MAX - 1
			move $s6, $zero          # Índice do vetor para a posição atual j (para comparação)
			move $s7, $zero          # Índice do vetor para a posição j+1 (para comparação)
			blt $t0, $t4, loop_j     # Se $t0 < MAX-1, continua o loop externo
			beq $t0, $t4, imprimirVetor # Se $t0 == MAX-1, vai para a impressão do vetor

		loop_j:
			sub $t5, $t1, $t0        # Calcula o limite do loop interno: $t5 = MAX - i
			subi $t5, $t5, 1         # Ajusta o limite do loop interno: $t5 = MAX - i - 1

			sll $s6, $t2, 2          # Calcula o deslocamento para j: $s6 = $t2 * 4
			addi $s7, $s6, 4         # Calcula o deslocamento para j+1: $s7 = $s6 + 4

			add $s6, $s3, $s6        # Endereço do elemento j: $s6 = endereço base + deslocamento j
			add $s7, $s3, $s7        # Endereço do elemento j+1: $s7 = endereço base + deslocamento j+1

			beq $t2, $t5, soma_i     # Se $t2 == MAX - i - 1, o loop interno termina e vai para soma_i

			lw $t6, 0($s6)           # Carrega o valor do vetor na posição j
			lw $t7, 0($s7)           # Carrega o valor do vetor na posição j+1

			# if v[j] > v[j+1]
			bgt $t6, $t7, troca      # Se v[j] > v[j+1], vai para o bloco de troca

			addi $t2, $t2, 1         # Incrementa o iterador do loop interno
			j loop_j                 # Retorna para o início do loop interno

			troca:
				move $s5, $t6            # Armazena v[j] em $s5 (variável auxiliar)
				sw $t7, 0($s6)           # Atribui v[j+1] a v[j]
				sw $s5, 0($s7)           # Atribui aux a v[j+1] (troca completa)
				addi $t2, $t2, 1         # Incrementa o iterador do loop interno
				j loop_j                 # Retorna para o início do loop interno

			soma_i:
				addi $t0, $t0, 1         # Incrementa o iterador do loop externo
				j loop_i                 # Retorna para o início do loop externo

		# Imprimir o vetor
		imprimirVetor:
			move $t0, $zero          # Inicializa o iterador $t0 com zero
			move $s7, $zero          # Inicializa o índice do vetor $s7 com zero

			# Imprime a mensagem inicial
			li $v0, 4
			la $a0, msg
			syscall

		loop_imprimir:
			sll $s7, $t0, 2          # Calcula o deslocamento: $s7 = $t0 * 4
			add $s7, $s3, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento

			beq $t0, $t1, fim        # Se $t0 == MAX, o loop termina e vai para o fim

			# Imprime o elemento atual do array
			li $v0, 1
			lw $a0, 0($s7)
			syscall 

			# Imprime um espaço entre os elementos
			li $v0, 4
			la $a0, space
			syscall 

			addi $t0, $t0, 1         # Incrementa o iterador do loop de impressão
			j loop_imprimir          # Retorna para o início do loop de impressão

fim:
	li $v0, 10               # Syscall para encerrar o programa
	syscall
