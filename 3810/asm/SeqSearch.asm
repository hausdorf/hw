# Start at A[0]
# Check if we are inside the bounds
# Compare the element
	# if found, return
	# if not, continue
# Increment the element
# Goto beginning

# initialize the array
main:

seq_search:
	# INITIALIZE THE ARRAY
	addi $sp, $sp, -8
	li $s0, 16
	sw $s0, 4($sp)
	li $s0, 32
	sw $s0, 0($sp)

	# SEARCH
	search_loop:
		addi $s1, $s1, 16  # element to search for
		addi $t0, 0  # the counter to iterate through the array

	test:
		slti $t1, $t0, 3  # sets if count < length
		beq $t1, $0, exit_false  # exit if count < length
		li $t2, 4
		mul $t3, $t0, $t2
		add $t2, $sp, $t3
		lw $s0, 0($t2)
		beq $s0, $s1, exit_success
		addi $t0, $t0, 1
		j test

	exit_false:
		li $v0, 0
		jr $ra

	exit_success:
		li $v0, 1
		jr $ra


