.data
	array : .align 2
		.space 40  #40 bytes de espaço armazenado
	
	msg : .asciiz "Elementos do vetor: "
	space : .asciiz  " "
.text

main:
	
	
	li $a1, 255	#Numero max dos numeros aleatorios
	li $t1, 40	#Tamanho do vetor
	
	#prencher vetor com valores aleatorios
	prencherVetor:
		move $t0, $zero 	#iterador i para preenchimento do vetor com numeros aleatorios
		loop_prencher:
			beq $t0, $t1, ordenarVetor # if i == len(vetor) , isso diz que o vetor está totalmente preenchido, logo chamara o bloco ordenarVetor
			
			li $v0, 42	#gera o numero pseudo-aleatorio com intervalo de [0,$a1]
			syscall
			
			move $s0, $a0	#move o numero aleatorio para o reg $s0
		
			sw $s0, array($t0) # Adicionando o numero aleatorio ao vetor na posicao $t0
	
			addi $t0, $t0, 4 #Atualizando o interador do vetor
			j loop_prencher	#retorna para o bloco loop_preecher
		
	
	#ordenar o vetor
	ordenarVetor:
		move $t0, $zero 	#iterador i
		
		loop_i:
			move $t2, $zero 	#iterador j
			subi  $t4 , $t1 , 4	#Condição de parada do loop i
			blt $t0, $t4 , loop_j	#Comparação i < N-1
			beq $t0, $t4, imprimirVetor	#sai do loop i e vai para bloco imprimirVetor
		
		loop_j:
			
			addi $t3, $t2, 4	#iterador j+1
			sub $t5 , $t1 , $t0	#realizar a subtração len(vetor) - i
			subi $t5, $t5 , 4 	#Condição de parada do loop j, ou seja , len(v) - i - 1
			
			beq $t2 , $t5 , soma_i	#Comparação j < N-i-1, ou seja quando j for igual a N-i-1 o loop mais interno acaba e vai para o bloco soma_i
				
				
			lw $t6 , array($t2)	#v[j]
			lw $t7 , array($t3)	#v[j+1]
			
			#if v[j] > v[j+1]
			bgt $t6, $t7 , troca #Caso a comparação seja True, vai para o Bloco troca
			
			addi $t2, $t2 , 4 #j++
				
			j loop_j #Retorna para o bloco loop_j
			
			troca:
				move $s5 , $t6		#aux = v[j]
				sw $t7 , array($t2)	#v[j] = v[j+1]
				sw $s5 , array($t3)	#v[j+1] = aux
				addi $t2, $t2 , 4 	#j++
				j loop_j	#Retorna para o bloco loop_j
			
			
		soma_i:
			addi $t0 , $t0, 4	#i++
			j loop_i	#Retorna para o bloco loop_i
			
			
		
	#imprimir o vetor
	imprimirVetor:
		move $t0, $zero 	#iterador
		
		#imprimindo mensagem
		li $v0 , 4
		la $a0 , msg
		syscall
		
		loop_imprimir:
			beq $t0, $t1, fim # comparação
			
			#imprimindo elemento do array
			li $v0, 1
			lw $a0, array($t0)
			syscall 
			
			#imprimindo o space entre os elementos
			li $v0, 4
			la $a0,space
			syscall 
			
			addi $t0, $t0, 4 #Atualizando o interador do vetor
			
			j loop_imprimir
			
				
fim:
	li $v0, 10	#Fim do progama
	syscall 
