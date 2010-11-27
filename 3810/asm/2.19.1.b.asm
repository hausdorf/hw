# Iterates through the Fibonacci sequence.
# fib_iter(int a, int b, int c)
# int a = $a0; int b = $a1; int n = $a2

main:
	li $a0, 1
	li $a1, 2
	li $a2, 3
	jal fib_iter
	li $v0, 10
	syscall

fib_iter:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	addi $s0, $a0, 0
	addi $s1, $a1, 0
	addi $s2, $a2, 0
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	bne $a2, $0, else  # test n==0
	addi $v0, $a1, 0
	addi $sp, $sp, 16
	jr $ra
else:
	add $a0, $s0, $s1
	addi $a1, $s0, 0
	addi $a2, $s2, -1

	jal fib_iter

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)

	addi $sp, $sp, 16
	
	jr $ra

