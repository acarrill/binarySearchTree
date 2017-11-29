##      $v0 - syscall parameter and return value 
	.data 
msg: .asciiz "Introduce a string of numbers, the program will create a treesort and give back ur numbers's string in order \n"
	.text 
	 
##	$s0 - root
##	$s1 - next chart introduced by the user
##	$s2 - stop value
main:     
	#Creating a root node
	li $s2, 0 	# We establish our stop number
	move $a0, $s2	# Now we move this to $a0 for pass like an argument to tree_node_create
	li $a1, 0
	li $a2, 0
		
	jal tree_node_create
	
	move $s0, $v0 	# Store root node in $s0
	# We ask for the string
	la $a0, msg 
	li $v0, 4 	# Load syscall print-string into $v0 
	syscall
	 
	li $v0, 5	# Read number's string
	syscall
	
	move $s1, $v0	# We check condition for continuing reading the command line
	bne $s1, 0, read_numbers_loop  
	
	li $v0, 10
	syscall

read_numbers_loop:
	move $a0, $s1	# We pass arguments from static register to $a's registers
	move $a1, $s0
	jal tree_insert
	
	li $v0, 5	# Read number's string
	syscall
	
	move $s1, $v0	# We check condition for continuing reading the command line
	bne $s1, 0, read_numbers_loop 
	 
	move $a0, $s0 	# Move root to $a0 in order to tree_print use it like argument 
	jal tree_print
	li $v0, 10
	syscall	
	
##	$a0 - value of the new node
##	$a1 - root
tree_insert:
	subu $sp, $sp, 32
	sw $ra, 20($sp)  
	sw $fp, 16($sp)
	addiu $fp, $sp, 24	#24 ya que guardaremos 2 numero = dos palabras = 8 bytes  
	sw $a0, 0($fp)
	sw $a1, 4($fp)
	
	li $a1, 0
	li $a2, 0
	jal tree_node_create
	lw $a0, 0($fp)		# Restore $a0
	lw $a1, 4($fp)		# Restore $a1
	
	move $a2, $v0		# We pass the new node like argument
	jal read_right_left_tree
	
	# liberar pila
	lw $ra, 20($sp) 
	lw $fp, 16($sp) 
	addiu $sp, $sp, 32 
	jr $ra

## $a0 - value	
## $a1 - root
## $a2 - new node	
read_right_left_tree:
	lw $t0, 0($a1)		# cargamos valor del nodo
	ble $a0, $t0, read_left_tree	
	# else, we read right tree
	lw $t0, 8($a1)
	bnez $t0, continue_tree_insert
	sw $a2, 8($a1)		# Store new node
	jr $ra
	
read_left_tree:
	lw $t0, 4($a1)
	bnez $t0, continue_tree_insert
	sw $a2, 4($a1)		# Store new node
	jr $ra

# ISSUE I USE A TEMPORAL REGISTER LIKE AN ARGUMENT
continue_tree_insert:
#	lw $t0, 4($a1)		# hay que hacer esto o puedo usar temporal
	move $a1, $t0
	# We create a stack for store jump direction in $ra
	subu $sp, $sp, 32
	sw $ra, 20($sp)  
	jal read_right_left_tree
	# liberar pila
	lw $ra, 20($sp) 
	addiu $sp, $sp, 32 
	jr $ra
																									
##	$a0 - value of the new node
##	$a1 - left son
##	$a2 - right son
tree_node_create:
	move $t0, $a0	# We put $a0 in a safe place before calling the system
	
	li $a0, 12
	li $v0, 9
	syscall 	# Return through $v0 the address direction of reserved memory
# COMPROBAR SI QUEDA MEMORIA ??????
	move $a0, $t0 	# Restore $a0's value
	
	sw $a0, 0($v0) 	# Establish value of the node
	sw $a1, 4($v0) 	# Establish value of the left node
	sw $a2, 8($v0)	# Establish value of the right node
	
	jr $ra 

##	$a0 - tree COMO PASAMOS EL ARBOL??????
tree_print:
	# Create stack
	subu $sp, $sp, 32
	sw $ra, 20($sp)  
	sw $fp, 16($sp)
	addiu $fp, $sp, 28	#24 ya que guardaremos 2 numero = dos palabras = 8 bytes  
	sw $a0, 0($fp)
	
	bnez $a0, print_tree_value
	
	# Delete stack
	lw $ra, 20($sp) 
	lw $fp, 16($sp) 
	addiu $sp, $sp, 32 
	jr $ra

print_tree_value:
	lw $a0, 4($a0)	# We print first the left (minor number)
	jal tree_print
	lw $a0, 0($fp)	# Restore
	
	lw $a0, 0($a0)	# Now print
	li $v0, 1
	syscall
	lw $a0, 0($fp)

	lw $a0, 8($a0)
	jal tree_print
	
	# Delete stack
	lw $ra, 20($sp) 
	lw $fp, 16($sp) 
	addiu $sp, $sp, 32 
	jr $ra
