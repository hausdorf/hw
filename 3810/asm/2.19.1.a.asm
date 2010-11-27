.text
main:
	li $a0, 10
	li $a1, 20
	jal compare
	j end

compare:
	addi $s0, $a0, 0
	addi $s1, $a1, 0
	sw $ra, 0($sp)

	jal sub

	lw $ra, 0($sp)
	bltz $v0, else
	addi $v0, $0, 1
	jr $ra
else:
	addi $v0, $0, 0
	jr $ra

sub:
	sub $v0, $a0, $a1
	jr $ra

end:
	li $v0, 10
	syscall
