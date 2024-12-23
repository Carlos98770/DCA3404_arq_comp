# Coloque seu nome	Carlos Eduardo Medeiros da Silva
# Coloque sua matrícula		20220010155

# Segmento de dados --------------

.data

	msg_codificada: .word 0x00051010, 0x116A23B1, 0x21347582, 0x10061231, 0x11642467, 0x008695AB, 0x21CD6EEF, 0x00071323
                	.word 0x11264517, 0x2089A2B0, 0x00E5F601, 0x212360F1, 0x11624533, 0x21676455, 0x00627089, 0x20AB8691
                	.word 0x10A6CDB3, 0x21EF6C5D, 0x10E701F2, 0x00071423, 0x0162F345, 0x21677455, 0x10628971, 0x1082AB90
                	.word 0x10A4CDB6, 0x016C9DEF, 0x21016031, 0x212362F3, 0x01745545, 0x10626770, 0x10868993, 0x21AB6AFB
                	.word 0x00C6DDCD, 0x00E2F0EF, 0x116001E1, 0x0162F323, 0x20454754, 0x00667167, 0x20898290, 0x113AAB1B
                	.word 0x113CCD0D, 0x000211EF
                	
        array_decodificado: .align 2
			     .space 336       #Array de elementos decodificados separados por posicao
			
	array_decodificado_concat: .align 2
			     .space 168      #Array de elementos decodificados concatenados
                
	msg: .asciiz "Mensagem decodificada: "    # Mensagem para indicar os elementos do vetor
	space: .asciiz " "                     # Espaço em branco entre os elementos
	MAX: .word 42                       # Define o tamanho máximo do vetor codificado
	MAX_decoder: .word 84                      # Define o tamanho máximo do vetor decodificado 	tamanho do vetor codificado x 2

# Segmento de texto (instruções)

.text

main:
	la $s0, msg_codificada  # Carrega o endereço base do array em $s0
	lw $t1, MAX
	la $s6 , array_decodificado	#Carrega o endereço base do array_decodificado em $s6
	add $s7, $s7, $zero		#inicializa o indice do array_decodifcado 
	
	move $t0, $zero          # Inicializa o iterador $t0 com zero i = 0, pro loop de varredura
	move $s1, $zero          # Inicializa o índice do vetor $s1 com zero, indice do vetor codificado
	move $t6, $zero 		#inicializa o interador do vetor decodificado
	
	varredura:
			
			
			sll $s1, $t0, 2          # Calcula o deslocamento: $s1 = $t0 * 4
			add $s1, $s0, $s1        # Endereço do elemento do vetor: $s1 = endereço base + deslocamento
			beq $t0, $t1, concatenar_elemetos       # Se $t0 == MAX, o loop termina e vai para o fim
			
			# Vetor que vai armazenar os caracteres decodificados
			sll $s7, $t6, 2          # Calcula o deslocamento: $s7 = $t0 * 4
			add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento

			addi $t0, $t0, 1         # Incrementa o iterador do loop de impressão
			#j loop_imprimir          # Retorna para o início do loop de impressão
			
			byte3:
				lui $t2, 0xFF00  		# Carrega os 16 bits mais significativos (0xFF00) no registrador
				ori $t2, $t2, 0x0000  		# Carrega os 16 bits menos significativos (0x0000)

				lw $s2 , 0($s1) 		#Carrega a i-esima posição do vetor codificado em $s2
											#byte 3   #byte 2    #byte 1    #byte 0
				and $s3, $s2, $t2    # $t1 = $t0 AND 0xFF000000(11111111  00000000   00000000   00000000) (isola os 4 bits mais significativos)
    				srl  $s3, $s3, 24        # Desloca para a direita 24 bits para colocar na posição 0-7		-> Byte 3
				andi $s4, $s3, 0xF0    # $t2 = $t0 AND 0x0F(11110000) (isola os 4 bits mais significativos)    -> S4 é o nibble 1 do byte 3
				srl $s4, $s4, 4		# Desloca para a direita 4 bits para colocar na posição 0-3
				andi $s5, $s3, 0x0F	 # $t2 = $t0 AND 0x0F(00001111) (isola os 4 bits menos significativos) 	 -> S5 é o nibble 0 do byte 3
				
			byte2:
				srl $t2, $t2 , 8	#Caso seja valido, faz o deslocamneto dos 1s da mascara
				beq $s4, 2,byte1	#Verifica se o byte 2 é invalido
				
		
				and $t3, $s2, $t2    # $t1 = $t0 AND 0x00FF0000(00000000 11111111 00000000   00000000) (isola os 4 bits mais significativos)
    				srl $t3, $t3, 16        # Desloca para a direita 24 bits para colocar na posição 0-7		-> Byte 2
				andi $t4, $t3, 0xF0    # $t2 = $t0 AND 0x0F(11110000) (isola os 4 bits mais significativos)    -> S4 é o nibble 1 do byte 2
				srl $t4, $t4, 4		# Desloca para a direita 4 bits para colocar na posição 0-3
				andi $t5, $t3, 0x0F	 # $t2 = $t0 AND 0x0F(00001111) (isola os 4 bits menos significativos) 	 -> S5 é o nibble 0 do byte 2
				
				beq $s5 , 0, nibble_byte2	#Verifica qual nibble  é valido
				
				sw $t4 ,0($s7)		#move o simbolo para o vetor decodifcador	caso o nibble 0 do byte 3 seja 1
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
				j byte1			#jumper para proximo byte
				
			nibble_byte2:
				sw $t5 , 0($s7)		#move o simbolo para o vetor decodifcador	caso o nibble 0 do byte 3 seja 0
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
					
			byte1:
				srl $t2, $t2 , 8	#Caso seja valido, faz o deslocamneto dos 1s da mascara
				beq $s4, 1,byte0	#Verifica se o byte 1 é invalido
				# Vetor que vai armazenar os caracteres decodificados
				sll $s7, $t6, 2          # Calcula o deslocamento: $s7 = $t0 * 4
				add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento

				
				and $t3, $s2, $t2    # $t1 = $t0 AND 0x00FF0000(00000000 00000000 11111111 00000000) (isola os 4 bits mais significativos)
    				srl $t3, $t3, 8        # Desloca para a direita 24 bits para colocar na posição 0-7		-> Byte 1
				andi $t4, $t3, 0xF0    # $t2 = $t0 AND 0x0F(11110000) (isola os 4 bits mais significativos)    -> S4 é o nibble 1 do byte 1
				srl $t4, $t4, 4		# Desloca para a direita 4 bits para colocar na posição 0-3
				andi $t5, $t3, 0x0F	 # $t2 = $t0 AND 0x0F(00001111) (isola os 4 bits menos significativos) 	 -> S5 é o nibble 0 do byte 1
				
				beq $s5 , 0, nibble_byte1	#Verifica qual nibble  é valido
				
				sw $t4 ,0($s7)		#move o simbolo para o vetor decodifcador	caso o nibble 0 do byte 3 seja 1
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
				j byte0			#jumper para proximo byte
				
			
			nibble_byte1:
				sw $t5 , 0($s7)		#move o simbolo para o vetor decodifcador caso o nibble 0 do byte 3 seja 0
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
			
			byte0:
				srl $t2, $t2 , 8	#Caso seja valido, faz o deslocamneto dos 1s da mascara
				beq $s4, 0,varredura	#Verifica se o byte 0 é invalido
				# Vetor que vai armazenar os caracteres decodificados
				sll $s7, $t6, 2          # Calcula o deslocamento: $s7 = $t0 * 4
				add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento
				
				
				and $t3, $s2, $t2    # $t1 = $t0 AND 0x00FF0000(00000000 00000000 00000000 11111111) (isola os 4 bits mais significativos)
    				#srl $t3, $t3, 24        # Desloca para a direita 24 bits para colocar na posição 0-7		-> Byte 1
				andi $t4, $t3, 0xF0    # $t2 = $t0 AND 0x0F(11110000) (isola os 4 bits mais significativos)    -> S4 é o nibble 1 do byte 1
				srl $t4, $t4, 4		# Desloca para a direita 4 bits para colocar na posição 0-3
				andi $t5, $t3, 0x0F	 # $t2 = $t0 AND 0x0F(00001111) (isola os 4 bits menos significativos) 	 -> S5 é o nibble 0 do byte 1
				
				beq $s5 , 0, nibble_byte0	#Verifica qual nibble  é valido
				
				sw $t4 ,0($s7)		#move o simbolo para o vetor decodifcador	caso o nibble 0 do byte 3 seja 1
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
				# Vetor que vai armazenar os caracteres decodificados
				sll $s7, $t6, 2          # Calcula o deslocamento: $s7 = $t0 * 4
				add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento
				j varredura		#jumper para varredura
				
			

			nibble_byte0:
				sw $t5 , 0($s7)		#move o simbolo para o vetor decodifcador	caso o nibble 0 do byte 3 seja 0
				addi $t6,$t6,1		#Adiciona o interador do vetor do vetor codificado
				# Vetor que vai armazenar os caracteres decodificados
				sll $s7, $t6, 2          # Calcula o deslocamento: $s7 = $t0 * 4
				add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento
				j varredura		#jumper para varredura
			
			
	concatenar_elemetos:
						#vetor com elementos a ser concatenado $s6
		la $t2, array_decodificado_concat	#Carrega o endereço base do vetor_decodficado_concat
		
		lw $t1 , MAX		#Tamanho do vetor_decodificado_concat
		
		add $s5, $s5, $zero		#inicializa o indice do array_decodifcado_concat
		move $t6, $zero 	#inicializa o interador do vetor_decodificado_concat
		
		add $s7, $s7, $zero		#inicializa o indice do array_decodifcado 
		move $t0, $zero          # Inicializa o iterador do $s6		array_decoficado
		
		loop:
			#vetor_decodificado_concat
			sll $s5, $t6, 2          # Calcula o deslocamento: $s1 = $t0 * 4
			add $s5, $t2, $s5        # Endereço do elemento do vetor: $s1 = endereço base + deslocamento
			
			#vetor_decodificado
			sll $s7, $t0, 2          # Calcula o deslocamento: $s7 = $t0 * 4
			add $s7, $s6, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento
			
			beq $t6, $t1, imprimir_mensagem
			
			lw $s0, 0($s7)		#Armazena a posicao i do vetor_decodificado
			lw $s1, 4($s7)		#Armazena a posicao i + 1 do vetor_decodificado
			
			# Concatenação dos dois elementos
      	 		sll $s0, $s0, 4                 # Desloca o elemento i (em $s0) 16 bits para a esquerda
        		or $s0, $s0, $s1                 # Combina os elementos i e i+1 em um único valor no registrador $s0
        		
        		sw $s0, 0($s5)                   # Armazena o valor concatenado no vetor de destino

        		addi $t0, $t0, 2                 # Incrementa o iterador do vetor origem (avança para o próximo par)
       		 	addi $t6, $t6, 1                 # Incrementa o índice do vetor destino
       		 	
        
        		j loop                           # Volta ao início do loop
			
			
			
	imprimir_mensagem:
			move $t0, $zero          # Inicializa o iterador $t0 com zero
			move $s7, $zero          # Inicializa o índice do vetor $s7 com zero

			# Imprime a mensagem inicial
			li $v0, 4
			la $a0, msg
			syscall

		loop_imprimir:
			sll $s7, $t0, 2          # Calcula o deslocamento: $s7 = $t0 * 4
			add $s7, $t2, $s7        # Endereço do elemento do vetor: $s7 = endereço base + deslocamento

			beq $t0, $t1, exit       # Se $t0 == MAX, o loop termina e vai para o fim

			# Imprime o elemento atual do array
			li $v0, 11
			lw $a0, 0($s7)
			syscall 

			# Imprime um espaço entre os elementos
			li $v0, 4
			la $a0, space
			syscall 

			addi $t0, $t0, 1         # Incrementa o iterador do loop de impressão
			j loop_imprimir          # Retorna para o início do loop de impressão
			
				
# Exit()
	exit:
		li $v0, 10
		syscall
